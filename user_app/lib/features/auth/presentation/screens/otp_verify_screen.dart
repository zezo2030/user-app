import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/custom_button.dart';
import '../widgets/otp_input_field.dart';
import '../widgets/loading_overlay.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String email;
  final bool isRegistration;

  const OtpVerifyScreen({
    super.key,
    required this.email,
    this.isRegistration = false,
  });

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('verify_otp'.tr()), centerTitle: true),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          print('📱 OTP Verify Screen: State changed to ${state.runtimeType}');

          if (state is OtpVerified || state is RegisterSuccess) {
            print(
              '✅ OTP Verify Screen: OTP verified successfully, navigating to profile',
            );
            Navigator.pushReplacementNamed(context, '/main');
          } else if (state is AuthError) {
            print('❌ OTP Verify Screen: Error occurred: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state is AuthLoading,
            message: 'loading'.tr(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Text(
                    'verify_otp'.tr(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'otp_enter_code_message'.tr(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    widget.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // OTP Input Field
                  OtpInputField(
                    controller: _otpController,
                    onCompleted: (otp) {
                      _verifyOtp();
                    },
                  ),

                  const SizedBox(height: 24),

                  // Verify OTP Button
                  CustomButton(
                    text: 'verify_otp',
                    onPressed: () {
                      if (_otpController.text.length == 6) {
                        _verifyOtp();
                      }
                    },
                    icon: const Icon(Icons.verified, size: 20),
                  ),

                  const SizedBox(height: 16),

                  // Resend OTP Button
                  TextButton(
                    onPressed: () {
                      if (!widget.isRegistration) {
                        // Resend login OTP
                        context.read<AuthCubit>().sendOtp(email: widget.email);
                      }
                    },
                    child: Text('resend_otp'.tr()),
                  ),

                  const SizedBox(height: 16),

                  // Back Button
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('back'.tr()),
                  ),

                  const SizedBox(height: 32),

                  // Help Text
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'otp_help_message'.tr(),
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _verifyOtp() {
    print('🔍 OTP Verify Screen: _verifyOtp called');
    print('🔍 Email: ${widget.email}');
    print('🔍 OTP: ${_otpController.text}');
    print('🔍 Is Registration: ${widget.isRegistration}');

    if (widget.isRegistration) {
      print('📤 Calling registerVerifyOtp...');
      context.read<AuthCubit>().registerVerifyOtp(
        email: widget.email,
        otp: _otpController.text,
      );
    } else {
      print('📤 Calling verifyOtp...');
      context.read<AuthCubit>().verifyOtp(
        email: widget.email,
        otp: _otpController.text,
      );
    }
  }
}
