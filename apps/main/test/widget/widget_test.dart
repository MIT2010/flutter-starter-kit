import 'package:core_l10n/core_l10n.dart';
import 'package:feature_auth/feature_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'widget_test.mocks.dart';

@GenerateMocks([
  LoginWithEmailPasswordUseCase,
  RequestOtpUseCase,
  VerifyOtpUseCase,
  LogoutUseCase,
  GetCurrentUserUseCase,
  SessionManagerImpl,
])
void main() {
  testWidgets('LoginPage menampilkan form email/password saat pertama dibuka', (
    tester,
  ) async {
    final authBloc = AuthBloc(
      loginWithEmailPassword: MockLoginWithEmailPasswordUseCase(),
      requestOtp: MockRequestOtpUseCase(),
      verifyOtp: MockVerifyOtpUseCase(),
      logout: MockLogoutUseCase(),
      getCurrentUser: MockGetCurrentUserUseCase(),
      sessionManager: MockSessionManagerImpl(),
    );
    addTearDown(authBloc.close);

    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocaleUtils.supportedLocales,
          home: BlocProvider.value(value: authBloc, child: const LoginPage()),
        ),
      ),
    );

    // State awal AuthBloc adalah AuthChecking, yang oleh LoginPage
    // dirender sebagai EmailPasswordForm (Pola B) tanpa perlu
    // menunggu event apa pun.
    expect(find.text(t.auth.welcomeBack), findsOneWidget);
    expect(find.text(t.auth.loginSubtitle), findsOneWidget);
    expect(find.text(t.auth.email), findsOneWidget);
    expect(find.text(t.auth.password), findsOneWidget);
    expect(find.text(t.auth.login), findsOneWidget);
  });
}
