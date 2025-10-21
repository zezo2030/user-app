import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/otp_input_field.dart';
import '../widgets/loading_overlay.dart';

class OtpLoginScreen extends StatefulWidget {
  const OtpLoginScreen({Key? key}) : super(key: key);

  @override
  State<OtpLoginScreen> createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends State<OtpLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _nameController = TextEditingController();
  bool _otpSent = false;
  bool _isNewUser = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('login_with_otp'.tr()), centerTitle: true),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          print('📱 OTP Login Screen: State changed to ${state.runtimeType}');

          if (state is OtpSent) {
            print('✅ OTP Login Screen: OTP sent successfully');
            setState(() {
              _otpSent = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('otp_sent'.tr()),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is OtpVerified) {
            print('✅ OTP Login Screen: OTP verified successfully');
            if (state.authResponse.isNewUser == true) {
              setState(() {
                _isNewUser = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('new_user_detected'.tr()),
                  backgroundColor: Colors.blue,
                ),
              );
            } else {
              Navigator.pushReplacementNamed(context, '/main');
            }
          } else if (state is Authenticated) {
            Navigator.pushReplacementNamed(context, '/main');
          } else if (state is AuthError) {
            print('❌ OTP Login Screen: Error occurred: ${state.message}');
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Text(
                      'login_with_otp'.tr(),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      _otpSent
                          ? 'otp_enter_code_message'.tr()
                          : 'otp_login_subtitle'.tr(),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    if (!_otpSent) ...[
                      // Email Field
                      CustomTextField(
                        label: 'email'.tr(),
                        hint: 'email_hint'.tr(),
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'email_required'.tr();
                          }
                          if (!value.contains('@')) {
                            return 'email_invalid'.tr();
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Send OTP Button
                      CustomButton(
                        text: 'send_otp',
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthCubit>().sendOtp(
                              email: _emailController.text.trim(),
                            );
                          }
                        },
                        icon: const Icon(Icons.send, size: 20),
                      ),
                    ] else ...[
                      // OTP Input Field
                      OtpInputField(
                        controller: _otpController,
                        onCompleted: (otp) {
                          if (_isNewUser) {
                            // Show name field for new users
                            _showNameDialog();
                          } else {
                            _verifyOtp();
                          }
                        },
                      ),

                      const SizedBox(height: 24),

                      // Verify OTP Button
                      CustomButton(
                        text: 'verify_otp',
                        onPressed: () {
                          if (_otpController.text.length == 6) {
                            if (_isNewUser) {
                              _showNameDialog();
                            } else {
                              _verifyOtp();
                            }
                          }
                        },
                        icon: const Icon(Icons.verified, size: 20),
                      ),

                      const SizedBox(height: 16),

                      // Resend OTP Button
                      TextButton(
                        onPressed: () {
                          context.read<AuthCubit>().sendOtp(
                            email: _emailController.text.trim(),
                          );
                        },
                        child: Text('resend_otp'.tr()),
                      ),

                      const SizedBox(height: 16),

                      // Back Button
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _otpSent = false;
                            _otpController.clear();
                          });
                        },
                        child: Text('back'.tr()),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _verifyOtp() {
    context.read<AuthCubit>().verifyOtp(
      email: _emailController.text.trim(),
      otp: _otpController.text,
      name: _isNewUser ? _nameController.text.trim() : null,
    );
  }

  void _showNameDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('name_required'.tr()),
        content: CustomTextField(
          label: 'name'.tr(),
          controller: _nameController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'name_required'.tr();
            }
            return null;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _verifyOtp();
            },
            child: Text('confirm'.tr()),
          ),
        ],
      ),
    );
  }
}
