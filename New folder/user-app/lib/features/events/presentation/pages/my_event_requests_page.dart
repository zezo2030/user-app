// My Event Requests Page - Presentation Layer
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/di/auth_injection.dart';
import '../cubit/event_request_cubit.dart';
import '../cubit/event_request_state.dart';
import '../widgets/event_request_card.dart';
import 'event_request_details_page.dart';
import 'create_event_request_page.dart';
import 'package:iconsax/iconsax.dart';

class MyEventRequestsPage extends StatelessWidget {
  const MyEventRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<EventRequestCubit>()..getRequests(),
      child: const _MyEventRequestsView(),
    );
  }
}

class _MyEventRequestsView extends StatefulWidget {
  const _MyEventRequestsView();

  @override
  State<_MyEventRequestsView> createState() => _MyEventRequestsViewState();
}

class _MyEventRequestsViewState extends State<_MyEventRequestsView> {
  String? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الحجوزات الخاصة').tr(),
        actions: [
          // زر إنشاء طلب جديد
          IconButton(
            icon: const Icon(Iconsax.add),
            tooltip: 'إنشاء طلب جديد',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => sl<EventRequestCubit>(),
                    child: const CreateEventRequestPage(),
                  ),
                ),
              ).then((_) {
                // تحديث القائمة بعد إنشاء طلب جديد
                context.read<EventRequestCubit>().getRequests(
                      status: _selectedStatus == 'all' ? null : _selectedStatus,
                    );
              });
            },
          ),
          // قائمة التصفية
          PopupMenuButton<String>(
            onSelected: (status) {
              setState(() {
                _selectedStatus = status;
              });
              context.read<EventRequestCubit>().getRequests(status: status == 'all' ? null : status);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('الكل')),
              const PopupMenuItem(value: 'submitted', child: Text('تم الإرسال')),
              const PopupMenuItem(value: 'quoted', child: Text('تم التسعير')),
              const PopupMenuItem(value: 'confirmed', child: Text('مؤكد')),
              const PopupMenuItem(value: 'rejected', child: Text('مرفوض')),
            ],
            child: const Icon(Icons.filter_list),
          ),
        ],
      ),
      // زر عائم (FloatingActionButton) لإنشاء طلب جديد
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => sl<EventRequestCubit>(),
                child: const CreateEventRequestPage(),
              ),
            ),
          ).then((_) {
            // تحديث القائمة بعد إنشاء طلب جديد
            context.read<EventRequestCubit>().getRequests(
                  status: _selectedStatus == 'all' ? null : _selectedStatus,
                );
          });
        },
        icon: const Icon(Iconsax.add),
        label: const Text('إنشاء طلب جديد'),
      ),
      body: BlocBuilder<EventRequestCubit, EventRequestState>(
        builder: (context, state) {
          if (state is EventRequestsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is EventRequestsError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<EventRequestCubit>().getRequests(
                            status: _selectedStatus == 'all' ? null : _selectedStatus,
                          );
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (state is EventRequestsLoaded) {
            if (state.requests.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد طلبات',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider(
                              create: (_) => sl<EventRequestCubit>(),
                              child: const CreateEventRequestPage(),
                            ),
                          ),
                        ).then((_) {
                          // تحديث القائمة بعد إنشاء طلب جديد
                          context.read<EventRequestCubit>().getRequests(
                                status: _selectedStatus == 'all' ? null : _selectedStatus,
                              );
                        });
                      },
                      icon: const Icon(Iconsax.add),
                      label: const Text('إنشاء طلب جديد'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<EventRequestCubit>().getRequests(
                      status: _selectedStatus == 'all' ? null : _selectedStatus,
                    );
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.requests.length,
                itemBuilder: (context, index) {
                  final request = state.requests[index];
                  return EventRequestCard(
                    request: request,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventRequestDetailsPage(requestId: request.id),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

