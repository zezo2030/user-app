import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/offer_entity.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/url_utils.dart';

class ModernOfferCard extends StatefulWidget {
  final OfferEntity offer;
  final VoidCallback? onTap;

  const ModernOfferCard({Key? key, required this.offer, this.onTap})
    : super(key: key);

  @override
  State<ModernOfferCard> createState() => _ModernOfferCardState();
}

class _ModernOfferCardState extends State<ModernOfferCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                width: 320,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: _getOfferGradient(),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.luxuryShadowMedium,
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: AppColors.glowPrimary,
                      blurRadius: 30,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Background Image or Pattern
                      widget.offer.imageUrl != null &&
                              widget.offer.imageUrl!.isNotEmpty
                          ? _buildBackgroundImage()
                          : _buildBackgroundPattern(),

                      // Gradient Overlay for better text readability
                      _buildGradientOverlay(),

                      // Main Content
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with Badge
                            _buildHeader(),

                            const SizedBox(height: 16),

                            // Offer Title
                            _buildOfferTitle(),

                            const SizedBox(height: 8),

                            // Offer Description
                            if (widget.offer.description != null &&
                                widget.offer.description!.isNotEmpty)
                              _buildOfferDescription(),

                            const Spacer(),

                            // Footer with CTA
                            _buildFooter(),
                          ],
                        ),
                      ),

                      // Countdown Timer (if applicable)
                      if (widget.offer.endsAt != null) _buildCountdownTimer(),

                      // Hot Deal Badge
                      _buildHotDealBadge(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackgroundImage() {
    return Positioned.fill(
      child: CachedNetworkImage(
        imageUrl: resolveFileUrl(widget.offer.imageUrl),
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          decoration: BoxDecoration(gradient: _getOfferGradient()),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white70),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
          ),
          child: CustomPaint(painter: _OfferPatternPainter()),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.0),
              Colors.black.withOpacity(0.3),
              Colors.black.withOpacity(0.6),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
        ),
        child: CustomPaint(painter: _OfferPatternPainter()),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Discount Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Text(
            _getDiscountText(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // Offer Type Icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.local_offer, color: Colors.white, size: 20),
        ),
      ],
    );
  }

  Widget _buildOfferTitle() {
    return Text(
      widget.offer.title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        height: 1.2,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildOfferDescription() {
    return Text(
      widget.offer.description!,
      style: TextStyle(
        color: Colors.white.withOpacity(0.9),
        fontSize: 14,
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              'claim_offer'.tr(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
        ),
      ],
    );
  }

  Widget _buildCountdownTimer() {
    if (widget.offer.endsAt == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final endTime = widget.offer.endsAt!;
    final difference = endTime.difference(now);

    if (difference.isNegative) return const SizedBox.shrink();

    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _formatCountdown(difference),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildHotDealBadge() {
    return Positioned(
      top: -5,
      left: -5,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: AppColors.luxuryGoldGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.luxuryGold.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          'hot_deal'.tr(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  LinearGradient _getOfferGradient() {
    if (widget.offer.discountValue >= 50) {
      return AppColors.cardGradient;
    } else if (widget.offer.discountValue >= 25) {
      return AppColors.luxuryRoseGradient;
    } else {
      return AppColors.luxuryRedGradient;
    }
  }

  String _getDiscountText() {
    if (widget.offer.discountType == 'percentage') {
      return '${widget.offer.discountValue.toInt()}% ${'off'.tr()}';
    } else {
      return '${widget.offer.discountValue.toInt()} ${'currency'.tr()} ${'off'.tr()}';
    }
  }

  String _formatCountdown(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    if (days > 0) {
      return '${days}d ${hours}h';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}

class _OfferPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw circles pattern
    for (int i = 0; i < 5; i++) {
      final radius = (i + 1) * 20.0;
      final center = Offset(
        size.width * 0.8 - (i * 15),
        size.height * 0.2 + (i * 10),
      );

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
