import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class OffersSection extends StatelessWidget {
  final List<dynamic>? offers;

  const OffersSection({super.key, this.offers});

  @override
  Widget build(BuildContext context) {
    final list = offers ?? const [];
    if (list.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 120,
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
          return Container(
            width: 220,
            padding: const EdgeInsets.all(16),
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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEDEA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Iconsax.discount_shape,
                    color: Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (discount != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          discount,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: list.length,
      ),
    );
  }
}
