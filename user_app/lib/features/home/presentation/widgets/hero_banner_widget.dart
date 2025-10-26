import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';

class HeroBannerWidget extends StatelessWidget {
  final String? backgroundImageUrl;
  final String? title;
  final String? subtitle;
  final VoidCallback? onTap;
  final double height;
  final EdgeInsets? padding;
  final List<String>? amenities;

  const HeroBannerWidget({
    Key? key,
    this.backgroundImageUrl,
    this.title,
    this.subtitle,
    this.onTap,
    this.height = 200.0,
    this.padding,
    this.amenities,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveTitle = title ?? 'want_to_change_mood'.tr();
    final effectiveSubtitle = subtitle ?? 'with_tornado_entertainment'.tr();
    final effectivePadding = padding ?? const EdgeInsets.all(20);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          gradient: backgroundImageUrl != null
              ? null
              : AppColors.heroGradient,
          image: backgroundImageUrl != null
              ? DecorationImage(
                  image: NetworkImage(backgroundImageUrl!),
                  fit: BoxFit.cover,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            gradient: backgroundImageUrl != null
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  )
                : null,
          ),
          child: Padding(
            padding: effectivePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        effectiveTitle,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.start,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        effectiveSubtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.start,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      
                      // Amenities Section
                      if (amenities != null && amenities!.isNotEmpty) ...[
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: amenities!.take(3).map((amenity) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                amenity,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),
                
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'book_now'.tr(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HeroBannerWithImageWidget extends StatelessWidget {
  final String imageUrl;
  final String? title;
  final String? subtitle;
  final VoidCallback? onTap;
  final double height;
  final EdgeInsets? padding;
  final List<String>? amenities;

  const HeroBannerWithImageWidget({
    Key? key,
    required this.imageUrl,
    this.title,
    this.subtitle,
    this.onTap,
    this.height = 200.0,
    this.padding,
    this.amenities,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeroBannerWidget(
      backgroundImageUrl: imageUrl,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
      height: height,
      padding: padding,
      amenities: amenities,
    );
  }
}
