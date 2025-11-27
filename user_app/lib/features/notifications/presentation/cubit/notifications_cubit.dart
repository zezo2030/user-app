import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/notifications_local_datasource.dart';
import '../../data/models/notification_model.dart';

// States
abstract class NotificationsState {}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<NotificationModel> notifications;
  final int unreadCount;

  NotificationsLoaded({required this.notifications, required this.unreadCount});
}

class NotificationsError extends NotificationsState {
  final String message;

  NotificationsError(this.message);
}

// Cubit
class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsLocalDataSource _localDataSource;

  NotificationsCubit(this._localDataSource) : super(NotificationsInitial());

  /// Load all notifications
  Future<void> loadNotifications() async {
    try {
      emit(NotificationsLoading());

      final notifications = await _localDataSource.getAllNotifications();
      final unreadCount = await _localDataSource.getUnreadCount();

      emit(
        NotificationsLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
        ),
      );
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  /// Load notifications by type
  Future<void> loadNotificationsByType(String type) async {
    try {
      emit(NotificationsLoading());

      final notifications = await _localDataSource.getNotificationsByType(type);
      final unreadCount = await _localDataSource.getUnreadCount();

      emit(
        NotificationsLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
        ),
      );
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String id) async {
    try {
      await _localDataSource.markAsRead(id);
      await loadNotifications(); // Reload to update UI
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _localDataSource.markAllAsRead();
      await loadNotifications(); // Reload to update UI
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String id) async {
    try {
      await _localDataSource.deleteNotification(id);
      await loadNotifications(); // Reload to update UI
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  /// Delete all notifications
  Future<void> deleteAllNotifications() async {
    try {
      await _localDataSource.deleteAllNotifications();
      await loadNotifications(); // Reload to update UI
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  /// Get unread count
  Future<int> getUnreadCount() async {
    try {
      return await _localDataSource.getUnreadCount();
    } catch (e) {
      return 0;
    }
  }

  /// Refresh notifications (call this when a new notification arrives)
  Future<void> refresh() async {
    await loadNotifications();
  }
}
