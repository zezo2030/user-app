import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            print('✅ [Welcome Screen] User authenticated, navigating to /main');
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, '/main');
            });
          }
        },
        builder: (context, state) {
          // Check if already authenticated when screen is built
          if (state is Authenticated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              print(
                '✅ [Welcome Screen] Already authenticated, navigating to /main',
              );
              Navigator.pushReplacementNamed(context, '/main');
            });
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Directionality(
            textDirection: TextDirection.rtl,
            child: Stack(
              children: [
                // White background
                Positioned.fill(
                  child: Container(color: theme.colorScheme.background),
                ),

                // Bottom large red/orange wave
                Positioned(
                  left: -24,
                  right: -24,
                  bottom: -80,
                  child: _BottomWave(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFE91E63), // pink
                        Color(0xFFFF6A00), // orange
                      ],
                    ),
                    height: 260,
                  ),
                ),

                // Removed purple overlay per new design

                // Content column
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 90),
                        // Logo - Centered
                        Center(
                          child: Image.asset(
                            'assets/imgs/kinetic.png',
                            width: 160,
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Primary Login button
                        _GradientButton(
                          text: 'تسجيل دخول',
                          onTap: () => Navigator.pushNamed(context, '/login'),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF5CAB), Color(0xFFFF6A00)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Register button (white with shadow)
                        _OutlinedSoftButton(
                          text: 'تسجيل حساب',
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/otp-login-kinetic',
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Forgot password link
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/otp-login'),
                          child: Text(
                            'هل نسيت كلمة السر',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF8D8D8D),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final LinearGradient gradient;

  const _GradientButton({
    required this.text,
    required this.onTap,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = screenWidth * 0.70; // 70% of screen width

    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: buttonWidth,
          height: 80,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6A00).withOpacity(0.25),
                offset: const Offset(0, 12),
                blurRadius: 24,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlinedSoftButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _OutlinedSoftButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = screenWidth * 0.70; // 70% of screen width

    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: buttonWidth,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 20,
                offset: Offset(0, 12),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF4A4A4A),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// Removed guest pill button per latest design

class _BottomWave extends StatelessWidget {
  final LinearGradient gradient;
  final double height;

  const _BottomWave({required this.gradient, required this.height});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _WaveClipper(),
      child: Container(
        height: height,
        decoration: BoxDecoration(gradient: gradient),
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.25);
    path.quadraticBezierTo(
      size.width * 0.10,
      size.height * 0.05,
      size.width * 0.35,
      size.height * 0.18,
    );
    path.quadraticBezierTo(
      size.width * 0.60,
      size.height * 0.35,
      size.width * 0.75,
      size.height * 0.22,
    );
    path.quadraticBezierTo(
      size.width * 0.92,
      size.height * 0.12,
      size.width,
      size.height * 0.26,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// Removed _RoundedBlob widget (no longer used after design update)
