import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../activities/data/bookings_api.dart';
import '../../activities/data/bookings_repository.dart';
import '../../activities/domain/booking_status.dart';
import '../../activities/presentation/widgets/booking_card.dart';
import '../../booking/data/models/booking_model.dart';
import '../../booking/presentation/pages/booking_details_page.dart';
import '../../tickets/data/datasources/tickets_remote_datasource.dart';
import '../../../core/network/dio_client.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../../auth/presentation/cubit/auth_state.dart';
import '../../../core/routes/app_route_generator.dart';

class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        // Check if user is guest
        if (authState is Guest) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pop();
            Navigator.pushNamed(context, AppRoutes.login);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('login_required'.tr()),
                backgroundColor: Colors.orange,
              ),
            );
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return RepositoryProvider<BookingsRepository>(
          create: (_) => BookingsRepositoryImpl(api: BookingsApi()),
          child: _MyBookingsView(
            ticketsDs: TicketsRemoteDataSourceImpl(dio: DioClient.instance),
          ),
        );
      },
    );
  }
}

class _MyBookingsView extends StatefulWidget {
  final TicketsRemoteDataSource ticketsDs;
  const _MyBookingsView({required this.ticketsDs});

  @override
  State<_MyBookingsView> createState() => _MyBookingsViewState();
}

class _MyBookingsViewState extends State<_MyBookingsView> {
  bool _loading = true;
  String? _error;
  List<BookingModel> _bookings = const [];
  bool _showingUpcomingNotice = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _showingUpcomingNotice = false;
    });
    try {
      final repo = context.read<BookingsRepository>();
      // اجلب صفحة كبيرة نسبياً لتغطية اليوم والقادم
      final res = await repo.fetch(
        filter: BookingStatusFilter.all,
        page: 1,
        pageSize: 50,
      );
      final items = res.items;

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      final todays = items.where((b) {
        final dt = b.startTime.toLocal();
        return dt.isAfter(todayStart) && dt.isBefore(todayEnd);
      }).toList();

      if (todays.isNotEmpty) {
        _bookings = todays;
      } else {
        // القادمة: بعد الآن
        final upcoming = items
            .where((b) => b.startTime.toLocal().isAfter(now))
            .toList();
        if (upcoming.isNotEmpty) {
          _bookings = upcoming;
          _showingUpcomingNotice = true;
        } else {
          // لا يوجد اليوم ولا القادمة: أعرض الأقرب من السابقة
          final past =
              items.where((b) => b.startTime.toLocal().isBefore(now)).toList()
                ..sort((a, b) => b.startTime.compareTo(a.startTime));
          _bookings = past;
          _showingUpcomingNotice = false;
        }
      }

      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Map<DateTime, List<BookingModel>> _groupByDay(List<BookingModel> list) {
    final Map<DateTime, List<BookingModel>> map = {};
    for (final b in list) {
      final local = b.startTime.toLocal();
      final d = DateTime(local.year, local.month, local.day);
      (map[d] ??= <BookingModel>[]).add(b);
    }
    final entries = map.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return Map<DateTime, List<BookingModel>>.fromEntries(entries);
  }

  String _dayLabel(BuildContext context, DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final d = DateTime(day.year, day.month, day.day);
    if (d == today) return 'today'.tr();
    if (d == tomorrow) return 'tomorrow'.tr();
    return DateFormat.E().addPattern(' d MMM').format(d);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('my_bookings'.tr())),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: _load, child: Text('retry'.tr())),
          ],
        ),
      );
    }

    if (_bookings.isEmpty) {
      return Center(child: Text('no_bookings_found'.tr()));
    }

    final grouped = _groupByDay(_bookings);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        children: [
          if (_showingUpcomingNotice)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(child: Text('showing_upcoming'.tr())),
                ],
              ),
            ),
          const SizedBox(height: 8),
          ...grouped.entries.expand((entry) {
            final day = entry.key;
            final items = entry.value;
            return [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  _dayLabel(context, day),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ...items.map(
                (b) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: BookingCard(
                    booking: b,
                    ticketsDs: widget.ticketsDs,
                    onDetails: () async {
                      // الانتقال إلى صفحة التفاصيل وانتظار النتيجة
                      final result = await Navigator.of(context).push(
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 200),
                          pageBuilder: (_, animation, __) => FadeTransition(
                            opacity: animation,
                            child: BookingDetailsPage(booking: b),
                          ),
                          transitionsBuilder: (_, animation, __, child) {
                            final offsetAnimation = Tween<Offset>(
                              begin: const Offset(0.1, 0),
                              end: Offset.zero,
                            ).animate(animation);
                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          },
                        ),
                      );
                      // إذا تم إرجاع true (مثل بعد الدفع أو الإلغاء)، قم بتحديث البيانات
                      if (result == true && mounted) {
                        _load();
                      }
                    },
                  ),
                ),
              ),
            ];
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
