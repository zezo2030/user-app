import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class HallFeaturesList extends StatelessWidget {
  final List<String> features;

  const HallFeaturesList({
    Key? key,
    required this.features,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'hall_features'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Features grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: features.length,
              itemBuilder: (context, index) {
                final feature = features[index];
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getFeatureIcon(feature),
                        size: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).primaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFeatureIcon(String feature) {
    final featureLower = feature.toLowerCase();
    
    if (featureLower.contains('sound') || featureLower.contains('audio')) {
      return Icons.volume_up;
    } else if (featureLower.contains('projector') || featureLower.contains('screen')) {
      return Icons.video_library;
    } else if (featureLower.contains('air') || featureLower.contains('conditioning')) {
      return Icons.ac_unit;
    } else if (featureLower.contains('stage') || featureLower.contains('platform')) {
      return Icons.stairs;
    } else if (featureLower.contains('lighting') || featureLower.contains('light')) {
      return Icons.lightbulb;
    } else if (featureLower.contains('wifi') || featureLower.contains('internet')) {
      return Icons.wifi;
    } else if (featureLower.contains('parking')) {
      return Icons.local_parking;
    } else if (featureLower.contains('security')) {
      return Icons.security;
    } else if (featureLower.contains('catering') || featureLower.contains('food')) {
      return Icons.restaurant;
    } else if (featureLower.contains('decoration') || featureLower.contains('decor')) {
      return Icons.palette;
    } else {
      return Icons.check_circle;
    }
  }
}
