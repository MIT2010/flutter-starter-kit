import 'package:core_l10n/core_l10n.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/email_password_form.dart';
import '../widgets/otp_form.dart';

/// Login page yang mendukung dua pola:
/// - Pola A: tampilkan form nomor HP → OTP
/// - Pola B: tampilkan form email+password → OTP
///
/// [useOtpOnly] = true  → Pola A
/// [useOtpOnly] = false → Pola B (default)
class LoginPage extends StatelessWidget {
  const LoginPage({super.key, this.useOtpOnly = false});

  static const routePath = '/login';

  final bool useOtpOnly;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
            // AuthAuthenticated ditangani oleh auth guard di router
          },
          builder: (context, state) {
            return switch (state) {
              AuthLoading() => const AppLoading(),
              AuthOtpSent(:final otp) => OtpForm(otp: otp),
              _ => useOtpOnly
                  ? _OtpOnlyForm()
                  : const EmailPasswordForm(),
            };
          },
        ),
      ),
    );
  }
}

/// Form untuk Pola A — input nomor HP/email untuk request OTP
class _OtpOnlyForm extends StatefulWidget {
  @override
  State<_OtpOnlyForm> createState() => _OtpOnlyFormState();
}

class _OtpOnlyFormState extends State<_OtpOnlyForm> {
  final _formKey = GlobalKey<FormState>();
  final _destinationController = TextEditingController();

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          AuthRequestOtpEvent(
            destination: _destinationController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.xxl),
            AppText.headingLg(context.t.auth.login),
            const SizedBox(height: AppSpacing.sm),
            AppText.bodyMd(
              context.t.auth.otp.destinationHint,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              label: context.t.auth.otp.phoneOrEmail,
              controller: _destinationController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _onSubmit(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.t.auth.otp.destinationRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: context.t.auth.otp.sendOtp,
              onPressed: _onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
