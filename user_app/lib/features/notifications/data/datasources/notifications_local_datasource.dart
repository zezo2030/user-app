import 'package:hive/hive.dart';
import '../models/notification_model.dart';

class NotificationsLocalDataSource {
  static const String _boxName = 'notifications';
  Box<NotificationModel>? _box;

  /// Initialize Hive box
  Future<void> init() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<NotificationModel>(_boxName);
    }
  }

  /// Save a notification
  Future<void> saveNotification(NotificationModel notification) async {
    await init();
    await _box!.put(notification.id, notification);
  }

  /// Get all notifications
  Future<List<NotificationModel>> getAllNotifications() async {
    await init();
    return _box!.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Get unread notifications count
  Future<int> getUnreadCount() async {
    await init();
    return _box!.values.where((n) => !n.isRead).length;
  }

  /// Mark notification as read
  Future<void> markAsRead(String id) async {
    await init();
    final notification = _box!.get(id);
    if (notification != null) {
      final updated = notification.copyWith(isRead: true);
      await _box!.put(id, updated);
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    await init();
    final notifications = _box!.values.toList();
    for (var notification in notifications) {
      if (!notification.isRead) {
        final updated = notification.copyWith(isRead: true);
        await _box!.put(notification.id, updated);
      }
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String id) async {
    await init();
    await _box!.delete(id);
  }

  /// Delete all notifications
  Future<void> deleteAllNotifications() async {
    await init();
    await _box!.clear();
  }

  /// Get notifications by type
  Future<List<NotificationModel>> getNotificationsByType(String type) async {
    await init();
    return _box!.values.where((n) => n.type == type).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Check if notification should be saved based on type
  bool shouldSaveNotification(String type) {
    const allowedTypes = ['booking', 'trip', 'offer'];
    return allowedTypes.contains(type.toLowerCase());
  }
}
