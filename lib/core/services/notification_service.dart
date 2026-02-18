import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Centralized notification service for local notifications.
/// Uses flutter_local_notifications v20 (all named-parameter API).
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _taskChannelId = 'task_channel';
  static const _taskChannelName = 'Task Notifications';
  static const _taskChannelDesc = 'Notifications for task updates';

  static const _reminderChannelId = 'reminder_channel';
  static const _reminderChannelName = 'Task Reminders';
  static const _reminderChannelDesc = 'Due-date reminders for tasks';

  /// Initialize the notification plugin and timezone data.
  Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    // v20 API: initialize({required settings: ...})
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Request notification permissions (iOS / Android 13+).
  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // ─── Notification Details ───────────────────────────────────────────────────

  NotificationDetails _taskDetails() => const NotificationDetails(
        android: AndroidNotificationDetails(
          _taskChannelId,
          _taskChannelName,
          channelDescription: _taskChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

  NotificationDetails _reminderDetails() => const NotificationDetails(
        android: AndroidNotificationDetails(
          _reminderChannelId,
          _reminderChannelName,
          channelDescription: _reminderChannelDesc,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

  // ─── Immediate Notifications ────────────────────────────────────────────────

  /// Show a generic notification immediately.
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      // v20 API: show({required id, title, body, notificationDetails, payload})
      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: _taskDetails(),
        payload: payload,
      );
    } catch (e) {
      debugPrint('NotificationService.showNotification error: $e');
    }
  }

  /// Notify when a new task is created.
  Future<void> notifyTaskCreated(String taskTitle) async {
    await showNotification(
      id: taskTitle.hashCode,
      title: '✅ Task Created',
      body: '"$taskTitle" has been added to your board.',
    );
  }

  /// Notify when a task is marked as complete.
  Future<void> notifyTaskCompleted(String taskTitle, {int? id}) async {
    await showNotification(
      id: id ?? taskTitle.hashCode,
      title: '🎉 Task Completed!',
      body: 'Great job! You completed "$taskTitle".',
    );
  }

  /// Notify when a task is updated.
  Future<void> notifyTaskUpdated(String taskTitle, {int? id}) async {
    await showNotification(
      id: id ?? taskTitle.hashCode,
      title: '✏️ Task Updated',
      body: '"$taskTitle" has been updated.',
    );
  }

  // ─── Scheduled Notifications ────────────────────────────────────────────────

  /// Schedule a due-date reminder 1 day before the task is due.
  Future<void> scheduleDueDateReminder({
    required int id,
    required String taskTitle,
    required DateTime dueDate,
  }) async {
    try {
      await cancelNotification(id);

      final reminderTime = dueDate.subtract(const Duration(days: 1));
      if (reminderTime.isBefore(DateTime.now())) return;

      final tzTime = tz.TZDateTime.from(reminderTime, tz.local);

      // v20 API: zonedSchedule({required id, required scheduledDate, required notificationDetails, required androidScheduleMode, title, body, payload})
      await _plugin.zonedSchedule(
        id: id,
        title: '⏰ Task Due Tomorrow',
        body: '"$taskTitle" is due tomorrow. Don\'t forget!',
        scheduledDate: tzTime,
        notificationDetails: _reminderDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'task_$id',
      );
    } catch (e) {
      debugPrint('NotificationService.scheduleDueDateReminder error: $e');
    }
  }

  /// Schedule a same-day reminder at 9 AM on the due date.
  Future<void> scheduleSameDayReminder({
    required int id,
    required String taskTitle,
    required DateTime dueDate,
  }) async {
    try {
      final reminderTime = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        9, // 9 AM
      );
      if (reminderTime.isBefore(DateTime.now())) return;

      final tzTime = tz.TZDateTime.from(reminderTime, tz.local);

      await _plugin.zonedSchedule(
        id: id + 1000,
        title: '🔔 Task Due Today',
        body: '"$taskTitle" is due today!',
        scheduledDate: tzTime,
        notificationDetails: _reminderDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'task_$id',
      );
    } catch (e) {
      debugPrint('NotificationService.scheduleSameDayReminder error: $e');
    }
  }

  /// Cancel a specific notification by ID (also cancels same-day reminder).
  Future<void> cancelNotification(int id) async {
    try {
      // v20 API: cancel({required int id})
      await _plugin.cancel(id: id);
      await _plugin.cancel(id: id + 1000);
    } catch (e) {
      debugPrint('NotificationService.cancelNotification error: $e');
    }
  }

  /// Cancel all pending notifications.
  Future<void> cancelAllNotifications() async {
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('NotificationService.cancelAllNotifications error: $e');
    }
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
