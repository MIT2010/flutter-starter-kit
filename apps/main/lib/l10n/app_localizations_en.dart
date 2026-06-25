// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Starter Kit';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get finish => 'Finish';

  @override
  String get errorGeneric => 'Something went wrong, please try again';

  @override
  String get errorNoInternet => 'No internet connection';

  @override
  String get errorTimeout => 'Connection timeout, please check your network';

  @override
  String get errorUnauthorized =>
      'Your session has expired, please login again';

  @override
  String get errorNotFound => 'Data not found';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get register => 'Register';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get startTest => 'Start Test';

  @override
  String get continueTest => 'Continue Test';

  @override
  String get submitTest => 'Submit Answers';

  @override
  String get timeRemaining => 'Time Remaining';

  @override
  String get question => 'Question';

  @override
  String get ofWord => 'of';
}
