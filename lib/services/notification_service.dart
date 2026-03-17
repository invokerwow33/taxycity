import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
  }

  // Запрос разрешений
  static Future<void> requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // Показать уведомление
  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'taxycity_channel',
      'TaxyCity Notifications',
      channelDescription: 'Уведомления от приложения TaxyCity',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // Типы уведомлений
  static Future<void> orderAccepted() async {
    await showNotification(
      title: 'Заказ принят!',
      body: 'Водитель принял ваш заказ. Ожидайте прибытия.',
    );
  }

  static Future<void> driverArrived() async {
    await showNotification(
      title: 'Водитель прибыл',
      body: 'Водитель уже на месте. Можете выходить.',
    );
  }

  static Future<void> tripCompleted() async {
    await showNotification(
      title: 'Поездка завершена',
      body: 'Спасибо за поездку! Оцените, пожалуйста, водителя.',
    );
  }

  static Future<void> newOrder(String from, String price) async {
    await showNotification(
      title: 'Новый заказ!',
      body: 'Маршрут: $from. Стоимость: $price',
    );
  }

  static Future<void> cancelOrder() async {
    await showNotification(
      title: 'Заказ отменён',
      body: 'Заказ был отменён.',
    );
  }

  static Future<void> messageReceived(String sender) async {
    await showNotification(
      title: 'Новое сообщение',
      body: 'Сообщение от $sender',
    );
  }
}
