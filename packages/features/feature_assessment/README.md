# feature_assessment

Fitur pengerjaan tes psikologi — dari intro sampai selesai, mendukung 4
tipe soal, kirim jawaban offline-resilient, dan resume kalau app
di-kill di tengah pengerjaan. Ini fitur kedua yang dibangun lengkap
setelah `feature_auth`, jadi bukti bahwa pola Clean Architecture +
BLoC + Melos di starter kit ini memang bisa diulang untuk fitur
berikutnya, bukan cuma kebetulan cocok untuk auth.

## Alur

```
AssessmentIntroReady  ──(mulai tes)──▶  AssessmentInProgress  ──(submit di soal terakhir)──▶  AssessmentCompleted
       ▲                                      │  ▲
       │                                      │  │ (next/previous)
       └──────────────(resume, ada sesi lama)─┘  │
                                                  └─ (jawab soal → tetap di soal yang sama, tersimpan)
```

Kalau `AssessmentLoadRequested` menemukan sesi yang belum selesai di
cache lokal untuk assessment yang sama, langsung lompat ke
`AssessmentInProgress` di posisi terakhir — bukan mulai dari intro lagi.

## Struktur

```
lib/
├── feature_assessment.dart                      # barrel export
└── src/
    ├── data/
    │   ├── assessment_endpoints.dart              # daftar endpoint — ubah sesuai backend kamu
    │   ├── mappers/                                # JSON <-> sealed entity (bukan Model class terpisah)
    │   │   ├── question_mapper.dart                 # -> QuestionEntity (4 varian)
    │   │   ├── answer_mapper.dart                   # <-> UserAnswerEntity (4 varian)
    │   │   └── content_mapper.dart                  # -> AssessmentContentEntity
    │   ├── models/                                  # AssessmentModel, ChapterModel, AssessmentSessionModel
    │   ├── datasources/
    │   │   ├── assessment_remote_datasource.dart     # panggil ApiClient
    │   │   └── assessment_local_datasource.dart      # cache sesi aktif via HiveStorage — untuk resume
    │   └── repositories/assessment_repository_impl.dart
    ├── domain/
    │   ├── repositories/assessment_repository.dart
    │   └── usecases/
    │       ├── get_assessment_usecase.dart
    │       ├── start_assessment_session_usecase.dart
    │       ├── get_active_session_usecase.dart        # cek sesi resumable
    │       ├── save_session_progress_usecase.dart      # tulis ke cache lokal tiap jawab/pindah soal
    │       ├── complete_assessment_session_usecase.dart
    │       └── submit_answer_usecase.dart              # wrapper tipis ke AnswerSubmissionService (queue)
    ├── presentation/
    │   ├── bloc/assessment_bloc.dart (+ _event.dart, _state.dart)
    │   ├── pages/
    │   │   ├── assessment_page.dart                   # shell yang di-routing, switch atas AssessmentState
    │   │   ├── assessment_intro_page.dart
    │   │   ├── assessment_question_page.dart
    │   │   └── assessment_complete_page.dart
    │   └── widgets/
    │       ├── question_answer_view.dart              # dispatcher — switch exhaustive atas QuestionEntity
    │       ├── single_choice_answer_widget.dart
    │       ├── multiple_choice_answer_widget.dart
    │       ├── matrix_answer_widget.dart
    │       └── open_ended_answer_widget.dart
    └── queue/
        ├── answer_submission_service.dart              # entry point submit jawaban (dibangun sebelum layer di atas)
        └── answer_queue_handler.dart                    # QueueHandler untuk tipe 'assessment_answer'

test/unit/    # get_assessment_usecase_test, submit_answer_usecase_test, assessment_bloc_test (26 test)
```

## Kenapa strukturnya begini

- **Tidak ada `QuestionModel`/`UserAnswerModel` terpisah.** Karena
  `QuestionEntity`/`UserAnswerEntity` (di `shared_assessment`) sudah
  cukup sebagai data holder, mapper (`question_mapper.dart`,
  `answer_mapper.dart`) langsung menghasilkan entity dari JSON — bukan
  duplikasi hierarchy sealed class jadi dua kali.
- **`SubmitAnswerUseCase` tidak mengembalikan `FutureEither`** seperti
  use case lain. Dia cuma wrapper tipis ke `AnswerSubmissionService`
  (queue offline) — dari sudut pandang pemanggil, "submit" selalu
  berhasil (masuk antrian); gagal-kirim-ke-server ditangani penuh oleh
  retry otomatis di `core_network`'s `QueueSyncManager`, bukan di sini.
- **`queue/` dibangun lebih dulu** dari layer data/domain/presentation
  di atasnya (lihat riwayat commit) — `AnswerSubmissionService` dan
  `AnswerQueueHandler` sudah ada dan teruji sebelum sisanya
  ditambahkan, dan layer di atasnya memakainya lewat
  `SubmitAnswerUseCase`, bukan menduplikasi logic queue.
- **Resume pakai cache lokal, bukan endpoint khusus.** Posisi terakhir
  (`currentChapterId`/`currentQuestionId`) dan semua jawaban disimpan
  ke `HiveStorage` tiap kali user menjawab/pindah soal
  (`SaveSessionProgressUseCase`) — ini konsumen pertama `HiveStorage`
  di seluruh workspace. Tidak perlu endpoint "sync progress" terpisah
  karena progress bisa direkonstruksi dari jawaban yang sudah ada.

## Navigasi soal

`AssessmentBloc` meratakan semua soal lintas bab jadi satu list terurut
(`_navigableQuestions`), **melewati soal dengan `showQuestion == false`**
(soal yang informasinya cuma ada di media, bukan teks) saat
next/previous — tapi tetap ikut tersimpan dalam data. Tidak ada logic
skip bersyarat berdasarkan jawaban sebelumnya (branching survey) — di
luar scope saat ini.

## Endpoint (ubah sesuai backend kamu)

```
GET  /assessment/{assessmentId}                  -> konten assessment
POST /assessment/{assessmentId}/sessions          -> mulai sesi baru
POST /assessment/sessions/{sessionId}/complete    -> selesaikan sesi
POST /assessment/sessions/{sessionId}/answers     -> submit satu jawaban (lewat queue)
```

Tidak ada backend nyata yang tersambung ke starter kit ini — endpoint
di atas didesain mengikuti pola `feature_auth`'s `AuthEndpoints`, siap
dipakai begitu kamu punya backend beneran. Tanpa backend, network call
akan gagal dan `AssessmentBloc` mengembalikan `AssessmentError`
(dirender sebagai `AppErrorView` dengan tombol "Coba Lagi") — sudah
diverifikasi manual, tidak crash.

## Testing

```bash
cd packages/features/feature_assessment
dart run build_runner build
flutter test test/unit
```

`assessment_bloc_test.dart` memakai `seed:` (bloc_test) untuk menguji
tiap handler event secara terisolasi tanpa perlu replay urutan event
penuh, kecuali untuk `AssessmentStartRequested` yang memang butuh
`AssessmentLoadRequested` jalan lebih dulu (mengisi field privat
`_assessment`).
