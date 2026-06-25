import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// Nama aplikasi
  ///
  /// In id, this message translates to:
  /// **'Starter Kit'**
  String get appName;

  /// Teks loading umum
  ///
  /// In id, this message translates to:
  /// **'Memuat...'**
  String get loading;

  /// Tombol untuk mencoba ulang
  ///
  /// In id, this message translates to:
  /// **'Coba Lagi'**
  String get retry;

  /// Tombol batal
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get cancel;

  /// Tombol simpan
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get save;

  /// Tombol hapus
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get delete;

  /// Tombol konfirmasi
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi'**
  String get confirm;

  /// Tombol tutup
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get close;

  /// Tombol selanjutnya
  ///
  /// In id, this message translates to:
  /// **'Selanjutnya'**
  String get next;

  /// Tombol kembali
  ///
  /// In id, this message translates to:
  /// **'Kembali'**
  String get back;

  /// Tombol selesai
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get finish;

  /// Pesan error umum
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan, silakan coba lagi'**
  String get errorGeneric;

  /// Pesan error tidak ada internet
  ///
  /// In id, this message translates to:
  /// **'Tidak ada koneksi internet'**
  String get errorNoInternet;

  /// Pesan error timeout
  ///
  /// In id, this message translates to:
  /// **'Koneksi timeout, periksa jaringan kamu'**
  String get errorTimeout;

  /// Pesan error unauthorized
  ///
  /// In id, this message translates to:
  /// **'Sesi kamu telah berakhir, silakan login kembali'**
  String get errorUnauthorized;

  /// Pesan error not found
  ///
  /// In id, this message translates to:
  /// **'Data tidak ditemukan'**
  String get errorNotFound;

  /// Label email
  ///
  /// In id, this message translates to:
  /// **'Email'**
  String get email;

  /// Label password
  ///
  /// In id, this message translates to:
  /// **'Kata Sandi'**
  String get password;

  /// Tombol login
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get login;

  /// Tombol logout
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get logout;

  /// Tombol register
  ///
  /// In id, this message translates to:
  /// **'Daftar'**
  String get register;

  /// Judul halaman login
  ///
  /// In id, this message translates to:
  /// **'Selamat Datang Kembali'**
  String get welcomeBack;

  /// Tombol mulai tes
  ///
  /// In id, this message translates to:
  /// **'Mulai Tes'**
  String get startTest;

  /// Tombol lanjutkan tes
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan Tes'**
  String get continueTest;

  /// Tombol submit tes
  ///
  /// In id, this message translates to:
  /// **'Kirim Jawaban'**
  String get submitTest;

  /// Label waktu tersisa
  ///
  /// In id, this message translates to:
  /// **'Waktu Tersisa'**
  String get timeRemaining;

  /// Label pertanyaan
  ///
  /// In id, this message translates to:
  /// **'Pertanyaan'**
  String get question;

  /// Kata dari untuk progress (contoh: 1 dari 10)
  ///
  /// In id, this message translates to:
  /// **'dari'**
  String get ofWord;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
