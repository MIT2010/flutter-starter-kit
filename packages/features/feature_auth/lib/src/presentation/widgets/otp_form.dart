import 'dart:async';
import 'package:core_l10n/core_l10n.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/otp_entity.dart';
import '../bloc/auth_bloc.dart';

/// Form input kode OTP dengan countdown timer
class OtpForm extends StatefulWidget {
  const OtpForm({super.key, required this.otp});

  final OtpEntity otp;

  @override
  State<OtpForm> createState() => _OtpFormState();
}

class _OtpFormState extends State<OtpForm> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  Timer? _timer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.otp.remainingSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        timer.cancel();
        return;
      }
      setState(() => _remainingSeconds--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          AuthVerifyOtpEvent(
            destination: widget.otp.destination,
            code: _otpController.text.trim(),
          ),
        );
  }

  void _onResend() {
    context.read<AuthBloc>().add(
          AuthRequestOtpEvent(destination: widget.otp.destination),
        );
  }

  String get _timerText {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
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
            AppText.headingLg(context.t.auth.otp.title),
            const SizedBox(height: AppSpacing.sm),
            AppText.bodyMd(
              context.t.auth.otp.subtitle(destination: widget.otp.destination),
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              label: context.t.auth.otp.inputLabel,
              controller: _otpController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onSubmitted: (_) => _onSubmit(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.t.auth.otp.required;
                }
                if (value.length != 6) {
                  return context.t.auth.otp.invalidLength;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            // Timer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_remainingSeconds > 0) ...[
                  AppText.bodyMd('${context.t.auth.otp.resendIn} '),
                  AppText.labelMd(
                    _timerText,
                    color: _remainingSeconds <= 10
                        ? AppColors.assessmentTimerCritical
                        : AppColors.assessmentTimer,
                  ),
                ] else
                  TextButton(
                    onPressed: _onResend,
                    child: Text(context.t.auth.otp.resend),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: context.t.auth.otp.verify,
              onPressed: _remainingSeconds > 0 ? _onSubmit : null,
              isDisabled: _remainingSeconds <= 0,
            ),
          ],
        ),
      ),
    );
  }
}
