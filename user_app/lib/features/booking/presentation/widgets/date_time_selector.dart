// Date Time Selector Widget - Presentation Layer
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:iconsax/iconsax.dart';

class DateTimeSelector extends StatelessWidget {
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final Function(DateTime) onDateChanged;
  final Function(TimeOfDay) onTimeChanged;

  const DateTimeSelector({
    Key? key,
    required this.selectedDate,
    required this.selectedTime,
    required this.onDateChanged,
    required this.onTimeChanged,
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
              'select_date_time'.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDateSelector(context),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimeSelector(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Iconsax.calendar_1, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selectedDate != null
                    ? DateFormat('yyyy/MM/dd').format(selectedDate!)
                    : 'select_date'.tr(),
                style: TextStyle(
                  color: selectedDate != null ? null : Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector(BuildContext context) {
    return InkWell(
      onTap: () => _selectTime(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Iconsax.clock, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selectedTime != null
                    ? selectedTime!.format(context)
                    : 'select_time'.tr(),
                style: TextStyle(
                  color: selectedTime != null ? null : Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != selectedDate) {
      onDateChanged(picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime) {
      onTimeChanged(picked);
    }
  }
}
