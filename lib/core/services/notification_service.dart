import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance =
      NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Skip on web — local notifications not supported
    if (kIsWeb) {
      _initialized = true;
      return;
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings =
        InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);

    // Request permission on Android 13+
final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
await androidPlugin?.requestNotificationsPermission();


    _initialized = true;
  }

  Future<void> showLowStockNotification({
    required String productName,
    required int currentStock,
    required int threshold,
  }) async {
    if (kIsWeb) return;

    const androidDetails = AndroidNotificationDetails(
      'low_stock_channel',
      'Low Stock Alerts',
      channelDescription:
          'Notifications for products running low on stock',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const details =
        NotificationDetails(android: androidDetails);

    await _plugin.show(
      productName.hashCode,
      '⚠️ Low Stock Alert',
      '$productName is running low — only $currentStock unit${currentStock != 1 ? 's' : ''} left (threshold: $threshold)',
      details,
    );
  }

  Future<void> showMultipleLowStockNotification(
      int count) async {
    if (kIsWeb) return;

    const androidDetails = AndroidNotificationDetails(
      'low_stock_channel',
      'Low Stock Alerts',
      channelDescription:
          'Notifications for products running low on stock',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const details =
        NotificationDetails(android: androidDetails);

    await _plugin.show(
      0,
      '⚠️ Low Stock Alert',
      '$count product${count != 1 ? 's are' : ' is'} running low on stock. Check your inventory.',
      details,
    );
  }
}