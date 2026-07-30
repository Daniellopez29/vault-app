import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'api_client.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._();
  factory PushNotificationService() => _instance;
  PushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'vault_high_importance',
    'Notificaciones de Vault',
    description: 'Notificaciones importantes de Vault',
    importance: Importance.high,
  );

  Future<void> initialize({
    void Function(RemoteMessage)? onMessageTapped,
  }) async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (Platform.isAndroid) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation
          <AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(_androidChannel);
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    await _localNotifications.initialize(
      settings: const InitializationSettings(android: androidSettings),
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null && onMessageTapped != null) {
          try {
            final data = jsonDecode(response.payload!) as Map<String, dynamic>;
            onMessageTapped(RemoteMessage(data: data.cast()));
          } catch (_) {}
        }
      },
    );

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((message) {
      _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      onMessageTapped?.call(message);
    });

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      onMessageTapped?.call(initialMessage);
    }
  }

  Future<String?> getToken() => _messaging.getToken();

  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  /// Registra el token FCM en el backend para que pueda enviar pushes
  /// dirigidos a este dispositivo. Se llama tras login exitoso.
  Future<void> registerTokenInBackend(ApiClient client) async {
    try {
      final token = await getToken();
      if (token == null) return;
      await client.post('/users/fcm-token', body: {'token': token});
    } catch (_) {
      // Fire-and-forget: si falla, las push no llegarán pero no bloquea el flujo.
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title ?? 'Vault',
      body: notification.body ?? '',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }
}
