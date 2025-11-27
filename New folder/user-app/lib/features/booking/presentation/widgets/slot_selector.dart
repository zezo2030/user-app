// Slot Selector Widget - Presentation Layer
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../domain/entities/time_slot_entity.dart';

class SlotSelector extends StatelessWidget {
  final List<TimeSlotEntity> slots;
  final TimeSlotEntity? selectedSlot;
  final int slotMinutes;
  final int selectedDurationHours;
  final bool isLoading;
  final String? errorMessage;
  final ValueChanged<TimeSlotEntity> onSlotSelected;

  const SlotSelector({
    super.key,
    required this.slots,
    required this.selectedSlot,
    required this.slotMinutes,
    required this.selectedDurationHours,
    required this.isLoading,
    required this.errorMessage,
    required this.onSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          errorMessage!,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.red),
        ),
      );
    }

    if (slots.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'hall_not_available'.tr(),
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.grey.shade600),
        ),
      );
    }

    final requiredSlots = (selectedDurationHours * 60 / slotMinutes).ceil();
    final selectedIdx = selectedSlot == null
        ? -1
        : slots.indexWhere(
            (s) => s.start.isAtSameMomentAs(selectedSlot!.start),
          );
    // اقفل فقط الفتحات التالية مباشرة بعد الفتحة المختارة بعدد (requiredSlots - 1)
    // ولا تقفل لا من البداية ولا من النهاية البعيدة
    final nextToLock = <int>{};
    if (selectedIdx >= 0 && requiredSlots > 1) {
      final maxChain = (selectedSlot!.consecutiveSlots - 1).clamp(0, 1 << 30);
      final toLock = (requiredSlots - 1).clamp(0, maxChain);
      for (int i = 1; i <= toLock; i++) {
        final idx = selectedIdx + i;
        if (idx < slots.length) nextToLock.add(idx);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: slots.map((slot) {
            final isSelected =
                selectedSlot != null && slot.start.isAtSameMomentAs(selectedSlot!.start);
            final idx = slots.indexOf(slot);
            // اقفل فقط الفتحات التالية المحجوزة ضمن المدة المطلوبة
            final isLockedByRange = nextToLock.contains(idx);
            final isEnabled = slot.available && !isLockedByRange;
            final startLabel = DateFormat('HH:mm').format(slot.start);
            final slotDuration = Duration(minutes: slotMinutes);
            final endLabel =
                DateFormat('HH:mm').format(slot.start.add(slotDuration));

            return ChoiceChip(
              label: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$startLabel - $endLabel'),
                  if (slot.consecutiveSlots > 1)
                    Text(
                      '${slot.consecutiveSlots} ${'hours'.tr()}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                ],
              ),
              selected: isSelected,
              onSelected: isEnabled
                  ? (_) => onSlotSelected(slot)
                  : null,
              disabledColor: Colors.grey.shade300,
            );
          }).toList(),
        ),
      ],
    );
  }
}

