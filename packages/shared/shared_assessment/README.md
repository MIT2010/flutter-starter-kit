# shared_assessment

Entity domain untuk fitur assessment (tes psikologi) — dipisah dari
`feature_assessment` supaya fitur lain (mis. `feature_dashboard` yang
nanti menampilkan riwayat/ringkasan hasil tes) bisa memakai entity yang
sama tanpa bergantung ke seluruh implementasi `feature_assessment`.

## Struktur

```
lib/
├── shared_assessment.dart              # barrel export
└── src/
    ├── enums/
    │   └── assessment_enums.dart        # MediaType, ContentFormat, SessionStatus
    └── entities/
        ├── assessment_entity.dart        # satu tes lengkap (kumpulan bab)
        ├── chapter_entity.dart           # satu bab/section dalam tes
        ├── question_entity.dart          # sealed class — 4 tipe soal
        ├── user_answer_entity.dart       # sealed class — 4 tipe jawaban (paralel dengan soal)
        ├── assessment_session_entity.dart # state progress pengerjaan (untuk resume)
        ├── answer_option_entity.dart
        ├── matrix_row_entity.dart
        ├── media_content_entity.dart
        └── assessment_content_entity.dart
```

## Sealed class: `QuestionEntity` & `UserAnswerEntity`

Ini pola paling penting di package ini. Keduanya `sealed class` dengan
4 varian yang berpasangan satu-satu:

| Tipe soal | Varian `QuestionEntity` | Varian `UserAnswerEntity` |
|---|---|---|
| Pilihan tunggal | `SingleChoiceQuestion` (options) | `SingleChoiceAnswer` (selectedOptionId) |
| Pilihan ganda | `MultipleChoiceQuestion` (options) | `MultipleChoiceAnswer` (selectedOptionIds) |
| Matriks/grid | `MatrixQuestion` (rows) | `MatrixAnswer` (selections: rowId -> optionId) |
| Jawaban bebas | `OpenEndedQuestion` | `OpenEndedAnswer` (text) |

Karena `sealed`, setiap `switch` yang menangani `QuestionEntity`/
`UserAnswerEntity` **wajib** exhaustive — compiler langsung menandai
kalau ada tipe yang belum ditangani. Ini yang membuat renderer soal di
`feature_assessment` (`QuestionAnswerView`) dan mapper JSON
(`question_mapper.dart`, `answer_mapper.dart`) aman ditambah tipe baru
tanpa takut ada cabang yang lolos tak tertangani.

Kalau menambah tipe soal ke-5, tambahkan varian baru di kedua sealed
class ini dulu — compiler akan menunjukkan semua tempat di
`feature_assessment` yang perlu diupdate untuk menanganinya.

## Entity pendukung lain

- **`AssessmentEntity`** — id, title, list `ChapterEntity`, intro &
  instruksi opsional. Punya getter `totalQuestions` dan `hasTimed`.
- **`ChapterEntity`** — satu bab, list `QuestionEntity`, `timeLimit`
  opsional (`hasTimer` getter).
- **`AssessmentSessionEntity`** — state progress satu sesi pengerjaan:
  posisi terakhir (`currentChapterId`/`currentQuestionId`), semua
  jawaban terisi, sisa waktu per bab, status
  (`inProgress`/`completed`/`expired`/`abandoned`). Didesain untuk
  di-cache lokal supaya bisa di-resume — lihat pemakaiannya di
  `feature_assessment`'s `AssessmentLocalDataSource` (via
  `HiveStorage`).

Semua entity `extends Equatable`, immutable (const constructor kalau
memungkinkan).

## Testing

Package ini murni entity, tidak ada logic langsung untuk diuji —
perilakunya diuji lewat pemakainya (`feature_assessment`'s
`test/unit/assessment_bloc_test.dart`, dll).
