import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class KineticOtpLoginScreen extends StatefulWidget {
  const KineticOtpLoginScreen({super.key});

  @override
  State<KineticOtpLoginScreen> createState() => _KineticOtpLoginScreenState();
}

class _KineticOtpLoginScreenState extends State<KineticOtpLoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _localPhoneController = TextEditingController();

  @override
  void dispose() {
    _localPhoneController.dispose();
    super.dispose();
  }

  String _normalizeToKsa(String raw) {
    final String digitsOnly = raw.replaceAll(RegExp(r'[^0-9]'), '');
    String local = digitsOnly;
    if (local.startsWith('0')) {
      local = local.substring(1);
    }
    // Return E.164 without plus (backend expects plain digits in this app)
    return '966$local';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is OtpSent) {
              Navigator.pushNamed(
                context,
                '/otp-verify-kinetic',
                arguments: <String, dynamic>{
                  'phone': state.phone,
                  'isRegistration': false,
                },
              );
            } else if (state is AuthError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            final bool isLoading = state is AuthLoading;

            return Column(
              children: [
                // Header gradient with white logo - takes remaining space
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[
                          Color(0xFFE6003A), // deep red
                          Color(0xFFFF2871), // pink
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/imgs/kinetic.png',
                            height: 180,
                            // Tint PNG to white to match header
                            color: Colors.white,
                            colorBlendMode: BlendMode.srcIn,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'عالم من المرح',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Card body at bottom - extends to bottom of screen
                Expanded(
                  child: Transform.translate(
                    offset: const Offset(0, -36),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 32,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    'assets/imgs/kinetic.png',
                                    height: 72,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'حياكم الله في تطبيق كينتك',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: Color(0xFF2B2B2B),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'تسجيل الدخول',
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                  color: Color(0xFF8D8D8D),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'مرحبا في عالم كينتك عالم من المرح',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: Color(0xFF9AA0A6),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Phone input row with +966
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 68,
                                    height: 48,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8F9FC),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: const Text(
                                      '+966',
                                      style: TextStyle(
                                        color: Color(0xFF4A4A4A),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _localPhoneController,
                                      keyboardType: TextInputType.phone,
                                      decoration: InputDecoration(
                                        hintText: 'رقم الجوال',
                                        filled: true,
                                        fillColor: const Color(0xFFF8F9FC),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 14,
                                            ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE6003A),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'من فضلك أدخل رقم الجوال';
                                        }
                                        if (value.trim().length < 8) {
                                          return 'رقم الجوال غير صحيح';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Submit button (gradient)
                              SizedBox(
                                height: 52,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Ink(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: <Color>[
                                            Color(0xFFFF5CAB), // pink
                                            Color(0xFFFF6A00), // orange
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                      ),
                                      child: InkWell(
                                        onTap: isLoading
                                            ? null
                                            : () {
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  final String
                                                  phone = _normalizeToKsa(
                                                    _localPhoneController.text,
                                                  );
                                                  context
                                                      .read<AuthCubit>()
                                                      .sendOtp(phone: phone);
                                                }
                                              },
                                        child: Center(
                                          child: isLoading
                                              ? const SizedBox(
                                                  width: 22,
                                                  height: 22,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2.5,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(Colors.white),
                                                  ),
                                                )
                                              : const Text(
                                                  'تسجيل الدخول',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
