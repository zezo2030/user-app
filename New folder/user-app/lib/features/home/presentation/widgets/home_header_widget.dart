import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Home header widget matching Figma design with gradient background,
/// notification bell, and Kinetic logo.
class HomeHeaderWidget extends StatelessWidget {
  const HomeHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Header height – slightly reduced to tighten space between sections
    final headerHeight = screenHeight * 0.25;

    return Container(
      height: headerHeight,
      decoration: BoxDecoration(
        // Gradient tweaked to match Figma (pink → red → orange)
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF4B8B), // Pink
            Color(0xFFFF1744), // Deep red
            Color(0xFFFF9100), // Orange
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Decorative background shapes
          _buildDecorativeShapes(screenWidth, headerHeight),

          // Top row: logo + notification button
          SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo section (left) with specific padding from edges
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
                  child: _buildLogoSection(),
                ),

                // Notification bell icon on the opposite side
                Padding(
                  padding: const EdgeInsets.only(right: 16, top: 16, left: 16),
                  child: _buildNotificationButton(context),
                ),
              ],
            ),
          ),

          // Middle title text
          Positioned(
            left: 16,
            right: 16,
            bottom: 72, // just above booking options row
            child: Align(
              alignment: Alignment.center,
              child: Text(
                'وش ودك تحجز اليوم؟',
                textAlign: TextAlign.center,
                style:
                    Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ) ??
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ),

          // Bottom booking options row (tickets / school trips / events)
          Positioned(
            left: 16,
            right: 16,
            bottom: 12,
            child: _buildBookingOptionsRow(),
          ),
        ],
      ),
    );
  }

  /// Builds the notification bell button in the top-left
  Widget _buildNotificationButton(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Navigate to notifications page
          },
          borderRadius: BorderRadius.circular(22),
          child: const Icon(
            Iconsax.notification,
            color: Color(0xFFFF1744), // Match Figma primary red
            size: 24,
          ),
        ),
      ),
    );
  }

  /// Builds the logo section in the top-right
  Widget _buildLogoSection() {
    return SizedBox(
      height: 100, // Slightly larger logo as requested
      child: ColorFiltered(
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        child: Image.asset('assets/imgs/logoheader.png', fit: BoxFit.contain),
      ),
    );
  }

  /// Booking options row (tickets / school trips / private events)
  Widget _buildBookingOptionsRow() {
    return Row(
      children: [
        // First item uses the provided image (log1.png) instead of the card UI
        Expanded(
          child: SizedBox(
            height: 48,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Image.asset('assets/imgs/log1.png'),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Second item uses the provided image (log2.png) for school trips
        Expanded(
          child: SizedBox(
            height: 48,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Image.asset('assets/imgs/log2.png'),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Third item uses the provided image (log3.png) for special events
        Expanded(
          child: SizedBox(
            height: 48,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Image.asset('assets/imgs/log3.png'),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds decorative background shapes
  Widget _buildDecorativeShapes(double width, double height) {
    return Stack(
      children: [
        // Large curved shape in top-right
        Positioned(
          top: -height * 0.3,
          right: -width * 0.1,
          child: Container(
            width: width * 0.6,
            height: height * 0.8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Colors.white.withOpacity(0.1), Colors.transparent],
              ),
            ),
          ),
        ),
        // Medium curved shape in top-left
        Positioned(
          top: -height * 0.2,
          left: -width * 0.15,
          child: Container(
            width: width * 0.4,
            height: height * 0.6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Colors.white.withOpacity(0.08), Colors.transparent],
              ),
            ),
          ),
        ),
        // Small accent shapes
        Positioned(
          top: height * 0.15,
          right: width * 0.15,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ),
        Positioned(
          top: height * 0.25,
          left: width * 0.2,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ),
      ],
    );
  }
}
