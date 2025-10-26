// Persons Input Widget - Presentation Layer
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:iconsax/iconsax.dart';

class PersonsInput extends StatelessWidget {
  final int personsCount;
  final Function(int) onPersonsChanged;

  const PersonsInput({
    Key? key,
    required this.personsCount,
    required this.onPersonsChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'number_of_persons'.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Iconsax.people, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('$personsCount ${'persons'.tr()}'),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: personsCount > 1 ? () => onPersonsChanged(personsCount - 1) : null,
                      icon: const Icon(Iconsax.minus),
                      style: IconButton.styleFrom(
                        backgroundColor: personsCount > 1 ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.grey.shade200,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: personsCount < 200 ? () => onPersonsChanged(personsCount + 1) : null,
                      icon: const Icon(Iconsax.add),
                      style: IconButton.styleFrom(
                        backgroundColor: personsCount < 200 ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.grey.shade200,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'persons_note'.tr(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
