import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/utils/url_utils.dart';

class OffersSection extends StatelessWidget {
  final List<dynamic>? offers;

  const OffersSection({super.key, this.offers});

  @override
  Widget build(BuildContext context) {
    final list = offers ?? const [];
    if (list.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 140,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, i) {
          final offer = list[i];
          final title = (offer is Map && offer['title'] != null)
              ? offer['title'].toString()
              : 'Offer';
          final discount = (offer is Map && offer['discount'] != null)
              ? offer['discount'].toString()
              : null;
          final imageUrl = (offer is Map && offer['imageUrl'] != null)
              ? offer['imageUrl'].toString()
              : null;
          return Container(
            width: 240,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Background Image
                  if (imageUrl != null && imageUrl.isNotEmpty)
                    Positioned.fill(
                      child: CachedNetworkImage(
                        imageUrl: resolveFileUrl(imageUrl),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: const Color(0xFFFFEDEA),
                          child: const Center(
                            child: Icon(
                              Iconsax.discount_shape,
                              color: Color(0xFFEF4444),
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      color: const Color(0xFFFFEDEA),
                      child: const Center(
                        child: Icon(
                          Iconsax.discount_shape,
                          color: Color(0xFFEF4444),
                          size: 40,
                        ),
                      ),
                    ),

                  // Gradient Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.0),
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        if (discount != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            discount,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: list.length,
      ),
    );
  }
}
