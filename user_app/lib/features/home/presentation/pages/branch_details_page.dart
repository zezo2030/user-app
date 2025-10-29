import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/theme/app_colors.dart';
import '../../di/home_injection.dart';
import '../../domain/usecases/get_branch_details_usecase.dart';
import '../../domain/usecases/get_halls_by_branch_usecase.dart';
import '../../domain/entities/branch_entity.dart';
import '../../domain/entities/hall_entity.dart';
import '../cubit/branch_details_cubit.dart';
import '../cubit/branch_details_state.dart';
import '../cubit/halls_cubit.dart';
import '../cubit/halls_state.dart';
import '../widgets/hero_banner_widget.dart';
import '../../../../core/utils/url_utils.dart';

class BranchDetailsPage extends StatelessWidget {
  final String branchId;

  const BranchDetailsPage({Key? key, required this.branchId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => BranchDetailsCubit(
            getBranchDetailsUseCase: sl<GetBranchDetailsUseCase>(),
          )..loadBranchDetails(branchId),
        ),
        BlocProvider(
          create: (context) =>
              HallsCubit(getHallsByBranchUseCase: sl<GetHallsByBranchUseCase>())
                ..loadHallsByBranch(branchId),
        ),
      ],
      child: BranchDetailsView(branchId: branchId),
    );
  }
}

class BranchDetailsView extends StatefulWidget {
  final String branchId;

  const BranchDetailsView({Key? key, required this.branchId}) : super(key: key);

  @override
  State<BranchDetailsView> createState() => _BranchDetailsViewState();
}

class _BranchDetailsViewState extends State<BranchDetailsView> {
  bool _isWorkingHoursExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: BlocBuilder<BranchDetailsCubit, BranchDetailsState>(
        builder: (context, state) {
          if (state is BranchDetailsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryRed),
            );
          }

          if (state is BranchDetailsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.info_circle,
                    size: 64,
                    color: AppColors.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.errorColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<BranchDetailsCubit>().loadBranchDetails(
                        widget.branchId,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('retry'.tr()),
                  ),
                ],
              ),
            );
          }

          if (state is BranchDetailsLoaded) {
            return _buildBranchDetails(context, state.branch);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildBranchDetails(BuildContext context, BranchEntity branch) {
    return CustomScrollView(
      slivers: [
        // Custom App Bar
        SliverAppBar(
          expandedHeight: 0,
          floating: true,
          pinned: true,
          backgroundColor: AppColors.primaryRed,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Iconsax.arrow_right_3, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Iconsax.notification, color: Colors.white),
              onPressed: () {
                // TODO: Handle notification tap
              },
            ),
          ],
        ),

        // Hero Banner with Branch Info
        SliverToBoxAdapter(
          child: HeroBannerWidget(
            backgroundImageUrl: resolveFileUrl(
              branch.coverImage ??
                  ((branch.images != null && branch.images!.isNotEmpty)
                      ? branch.images!.first
                      : null),
            ),
            title: branch.nameAr,
            subtitle: branch.descriptionAr ?? 'with_tornado_entertainment'.tr(),
            amenities: branch.amenities,
            onTap: () {
              // TODO: Handle banner tap
            },
          ),
        ),

        // Content
        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Branch Info Card
              // _buildBranchInfoCard(branch),

              // const SizedBox(height: 24),

              // Branch Details Section
              _buildBranchDetailsSection(branch),

              const SizedBox(height: 24),

              // Branch Amenities Section (only if more than 3 amenities or not shown in hero)
              if (branch.amenities != null && branch.amenities!.length > 3)
                _buildBranchAmenitiesSection(branch),

              const SizedBox(height: 24),

              // Branch Working Hours Section
              _buildBranchWorkingHoursSection(branch),

              const SizedBox(height: 24),

              // Branch Contact Section
              if (branch.contactPhone != null)
                _buildBranchContactSection(branch),

              const SizedBox(height: 24),

              // Halls Section
              _buildHallsSection(),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildBranchDetailsSection(BranchEntity branch) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.document_text,
                color: AppColors.primaryRed,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'description'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            branch.descriptionAr ??
                branch.descriptionEn ??
                'no_content_available'.tr(),
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchAmenitiesSection(BranchEntity branch) {
    if (branch.amenities == null ||
        branch.amenities!.isEmpty ||
        branch.amenities!.length <= 3) {
      return const SizedBox.shrink();
    }

    // Get amenities beyond the first 3 (which are shown in hero)
    final additionalAmenities = branch.amenities!.skip(3).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.star, color: AppColors.primaryRed, size: 24),
              const SizedBox(width: 12),
              Text(
                'more_amenities'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: additionalAmenities.map((amenity) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primaryRed.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  amenity,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchWorkingHoursSection(BranchEntity branch) {
    if (branch.workingHours == null || branch.workingHours!.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Iconsax.clock,
                    color: AppColors.primaryRed,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'working_hours'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Iconsax.info_circle,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'working_hours_all_week'.tr(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Sort working hours to show today first
    final sortedEntries = _sortWorkingHoursByToday(branch.workingHours!);
    final todayEntry = sortedEntries.first;
    final otherEntries = sortedEntries.skip(1).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Iconsax.clock,
                  color: AppColors.primaryRed,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'working_hours'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Today's hours (always visible)
          _buildDayHoursCard(todayEntry.key, todayEntry.value, true),

          // Other days (expandable)
          if (otherEntries.isNotEmpty) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isWorkingHoursExpanded = !_isWorkingHoursExpanded;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryRed.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isWorkingHoursExpanded
                          ? 'hide_other_days'.tr()
                          : 'show_other_days'.tr(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryRed,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _isWorkingHoursExpanded
                          ? Iconsax.arrow_up_2
                          : Iconsax.arrow_down_2,
                      size: 16,
                      color: AppColors.primaryRed,
                    ),
                  ],
                ),
              ),
            ),

            // Expandable section
            if (_isWorkingHoursExpanded) ...[
              const SizedBox(height: 12),
              ...otherEntries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildDayHoursCard(entry.key, entry.value, false),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildDayHoursCard(String dayName, dynamic hours, bool isToday) {
    final formattedHours = _formatWorkingHours(hours);
    final isClosed = formattedHours == 'closed'.tr();
    final isOpenNow = isToday && !isClosed && _isCurrentlyOpen(formattedHours);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isToday
            ? (isClosed
                  ? Colors.red.withValues(alpha: 0.05)
                  : AppColors.primaryRed.withValues(alpha: 0.05))
            : (isClosed
                  ? Colors.grey.withValues(alpha: 0.05)
                  : Colors.grey.withValues(alpha: 0.05)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToday
              ? (isClosed
                    ? Colors.red.withValues(alpha: 0.2)
                    : AppColors.primaryRed.withValues(alpha: 0.2))
              : Colors.grey.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Day name
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isToday
                        ? (isClosed ? Colors.red : AppColors.primaryRed)
                        : Colors.grey.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _translateDayName(dayName),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isToday
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isToday
                              ? (isClosed ? Colors.red : AppColors.primaryRed)
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (isToday && isOpenNow)
                        Text(
                          'open_now'.tr(),
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primaryRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Working hours
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  isClosed ? Iconsax.close_circle : Iconsax.clock,
                  size: 16,
                  color: isClosed ? Colors.red : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  formattedHours,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isToday
                        ? (isClosed ? Colors.red : AppColors.primaryRed)
                        : (isClosed ? Colors.red : AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<MapEntry<String, dynamic>> _sortWorkingHoursByToday(
    Map<String, dynamic> workingHours,
  ) {
    final entries = workingHours.entries.toList();

    // Find today's entry
    final todayEntry = entries.firstWhere(
      (entry) => _isToday(entry.key),
      orElse: () => entries.first,
    );

    // Remove today from the list
    entries.remove(todayEntry);

    // Sort remaining entries by day order
    entries.sort((a, b) {
      final dayOrder = {
        'monday': 1,
        'tuesday': 2,
        'wednesday': 3,
        'thursday': 4,
        'friday': 5,
        'saturday': 6,
        'sunday': 7,
        'Monday': 1,
        'Tuesday': 2,
        'Wednesday': 3,
        'Thursday': 4,
        'Friday': 5,
        'Saturday': 6,
        'Sunday': 7,
        'الاثنين': 1,
        'الثلاثاء': 2,
        'الأربعاء': 3,
        'الخميس': 4,
        'الجمعة': 5,
        'السبت': 6,
        'الأحد': 7,
      };

      final aOrder = dayOrder[a.key.toLowerCase()] ?? 0;
      final bOrder = dayOrder[b.key.toLowerCase()] ?? 0;

      return aOrder.compareTo(bOrder);
    });

    // Return today first, then others
    return [todayEntry, ...entries];
  }

  bool _isToday(String dayName) {
    final now = DateTime.now();
    final today = now.weekday;

    // Map API day names to weekday numbers
    final dayMap = {
      'monday': 1,
      'tuesday': 2,
      'wednesday': 3,
      'thursday': 4,
      'friday': 5,
      'saturday': 6,
      'sunday': 7,
      'Monday': 1,
      'Tuesday': 2,
      'Wednesday': 3,
      'Thursday': 4,
      'Friday': 5,
      'Saturday': 6,
      'Sunday': 7,
      'الاثنين': 1,
      'الثلاثاء': 2,
      'الأربعاء': 3,
      'الخميس': 4,
      'الجمعة': 5,
      'السبت': 6,
      'الأحد': 7,
    };

    return dayMap[dayName.toLowerCase()] == today;
  }

  String _translateDayName(String dayName) {
    final dayTranslations = {
      'monday': 'monday'.tr(),
      'tuesday': 'tuesday'.tr(),
      'wednesday': 'wednesday'.tr(),
      'thursday': 'thursday'.tr(),
      'friday': 'friday'.tr(),
      'saturday': 'saturday'.tr(),
      'sunday': 'sunday'.tr(),
      'Monday': 'monday'.tr(),
      'Tuesday': 'tuesday'.tr(),
      'Wednesday': 'wednesday'.tr(),
      'Thursday': 'thursday'.tr(),
      'Friday': 'friday'.tr(),
      'Saturday': 'saturday'.tr(),
      'Sunday': 'sunday'.tr(),
    };

    return dayTranslations[dayName] ?? dayName;
  }

  bool _isCurrentlyOpen(String hours) {
    try {
      // Extract time range from formatted hours like "09:00 - 18:00"
      final timePattern = RegExp(r'(\d{1,2}):(\d{2})');
      final matches = timePattern.allMatches(hours).toList();

      if (matches.length >= 2) {
        final now = DateTime.now();
        final currentHour = now.hour;
        final currentMinute = now.minute;
        final currentTimeInMinutes = currentHour * 60 + currentMinute;

        final openHour = int.parse(matches[0].group(1)!);
        final openMinute = int.parse(matches[0].group(2)!);
        final openTimeInMinutes = openHour * 60 + openMinute;

        final closeHour = int.parse(matches[1].group(1)!);
        final closeMinute = int.parse(matches[1].group(2)!);
        final closeTimeInMinutes = closeHour * 60 + closeMinute;

        return currentTimeInMinutes >= openTimeInMinutes &&
            currentTimeInMinutes <= closeTimeInMinutes;
      }
    } catch (e) {
      // If parsing fails, return false
    }

    return false;
  }

  String _formatWorkingHours(dynamic hours) {
    // Handle different data types
    if (hours == null) {
      return 'closed'.tr();
    }

    // If it's already a Map or Object, try to extract values
    if (hours is Map) {
      // Check if it has closed field
      if (hours.containsKey('closed') && hours['closed'] == true) {
        return 'closed'.tr();
      }

      // Check if it has open and close times
      if (hours.containsKey('open') && hours.containsKey('close')) {
        final openTime = hours['open']?.toString() ?? '';
        final closeTime = hours['close']?.toString() ?? '';
        if (openTime.isNotEmpty && closeTime.isNotEmpty) {
          return '$openTime - $closeTime';
        }
      }

      // If it's a Map but we can't extract meaningful data, convert to string
      hours = hours.toString();
    }

    // Convert to string and remove any extra whitespace and brackets
    String cleanHours = hours.toString().trim();

    // Handle different formats of working hours
    if (cleanHours.contains('closed') ||
        cleanHours.contains('closed') ||
        cleanHours.contains('closed: true')) {
      return 'closed'.tr();
    }

    // Handle JSON-like format: "{open: 09:00, close: 18:00, closed: false}"
    if (cleanHours.contains('open:') && cleanHours.contains('close:')) {
      final openMatch = RegExp(
        r'open:\s*(\d{1,2}:\d{2})',
      ).firstMatch(cleanHours);
      final closeMatch = RegExp(
        r'close:\s*(\d{1,2}:\d{2})',
      ).firstMatch(cleanHours);

      if (openMatch != null && closeMatch != null) {
        return '${openMatch.group(1)} - ${closeMatch.group(1)}';
      }
    }

    // Handle simple time range like "09:00 - 18:00" or "09:00-18:00"
    if (cleanHours.contains(' - ') || cleanHours.contains('-')) {
      return cleanHours.replaceAll('-', ' - ');
    }

    // Handle 24-hour format like "09:00" to "18:00"
    final timePattern = RegExp(r'(\d{1,2}:\d{2})');
    final matches = timePattern.allMatches(cleanHours).toList();

    if (matches.length >= 2) {
      return '${matches[0].group(1)} - ${matches[1].group(1)}';
    }

    // Handle single time like "09:00"
    if (matches.length == 1) {
      return '${matches[0].group(1)} - ${matches[0].group(1)}';
    }

    // Handle boolean values
    if (cleanHours.toLowerCase() == 'true') {
      return '24/7';
    }

    if (cleanHours.toLowerCase() == 'false' || cleanHours.isEmpty) {
      return 'closed'.tr();
    }

    // Handle numeric values (might be minutes or hours)
    if (RegExp(r'^\d+$').hasMatch(cleanHours)) {
      final num = int.tryParse(cleanHours);
      if (num != null) {
        if (num == 0) {
          return 'closed'.tr();
        } else if (num == 1) {
          return '24/7';
        }
      }
    }

    // Handle null or undefined
    if (cleanHours.toLowerCase() == 'null' ||
        cleanHours.toLowerCase() == 'undefined') {
      return 'closed'.tr();
    }

    // Return the original string if we can't parse it
    return cleanHours;
  }

  Widget _buildBranchContactSection(BranchEntity branch) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.call, color: AppColors.primaryRed, size: 24),
              const SizedBox(width: 12),
              Text(
                'contact_info'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Iconsax.call, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  branch.contactPhone!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement phone call functionality
                  print('Calling: ${branch.contactPhone}');
                },
                icon: const Icon(Iconsax.call, size: 16),
                label: Text('call_now'.tr()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHallsSection() {
    return BlocBuilder<HallsCubit, HallsState>(
      builder: (context, state) {
        if (state is HallsLoading) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Iconsax.home_2, color: AppColors.primaryRed, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'halls'.tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryRed),
                ),
              ],
            ),
          );
        }

        if (state is HallsError) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Iconsax.home_2, color: AppColors.primaryRed, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'halls'.tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Iconsax.info_circle,
                        size: 48,
                        color: AppColors.errorColor,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.errorColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        if (state is HallsLoaded) {
          if (state.halls.isEmpty) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Iconsax.home_2,
                        color: AppColors.primaryRed,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'halls'.tr(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Iconsax.home_2,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'no_halls_available'.tr(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(Iconsax.home_2, color: AppColors.primaryRed, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'halls'.tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.halls.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 160,
                        margin: EdgeInsets.only(
                          right: index < state.halls.length - 1 ? 12 : 0,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/hall-details',
                              arguments: {'hallId': state.halls[index].id},
                            );
                          },
                          child: _buildHallCard(state.halls[index]),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHallCard(HallEntity hall) {
    final imageUrl = hall.images != null && hall.images!.isNotEmpty
        ? hall.images![0]
        : null;

    final basePrice = hall.priceConfig['basePrice'] ?? 0;

    Color statusColor;
    String statusText;
    switch (hall.status) {
      case 'available':
        statusColor = AppColors.availableColor;
        statusText = 'available'.tr();
        break;
      case 'maintenance':
        statusColor = AppColors.maintenanceColor;
        statusText = 'maintenance'.tr();
        break;
      case 'reserved':
        statusColor = AppColors.reservedColor;
        statusText = 'reserved'.tr();
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusText = 'unknown'.tr();
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Hall Image
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                image: imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageUrl == null
                  ? Icon(
                      Iconsax.home_2,
                      size: 48,
                      color: AppColors.textSecondary,
                    )
                  : null,
            ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),

            // Status Badge
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Hall Info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      hall.nameAr,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${'ticket_price'.tr()}: $basePrice ${'currency'.tr()}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
