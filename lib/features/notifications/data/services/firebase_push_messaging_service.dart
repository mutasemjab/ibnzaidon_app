import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ibnzaidon/core/utils/parsers.dart';
import 'package:ibnzaidon/features/notifications/domain/entities/app_notification.dart';
import 'package:ibnzaidon/features/notifications/domain/services/push_messaging_service.dart';

/// FCM for delivery, `flutter_local_notifications` to show foreground
/// messages (FCM shows nothing while the app is open).
class FirebasePushMessagingService implements PushMessagingService {
  FirebasePushMessagingService(this._messaging, this._local);

  static const _channelId = 'general';
  static const _channelName = 'General';
  static const _androidIcon = '@mipmap/launcher_icon';

  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _local;
  final _opened = StreamController<PushMessage>.broadcast();
  final _foreground = StreamController<PushMessage>.broadcast();
  bool _initialized = false;
  int _nextId = 0;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;
    await _local.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings(_androidIcon),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null) return;
        final decoded = asMap(jsonDecode(payload));
        if (decoded == null) return;
        _opened.add(_fromPayload(decoded));
      },
    );
    FirebaseMessaging.onMessage.listen(_showForeground);
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => _opened.add(_toMessage(message)),
    );
    await _messaging.setForegroundNotificationPresentationOptions();
  }

  PushMessage _toMessage(RemoteMessage message) {
    final data = Map<String, Object?>.from(message.data);
    return PushMessage(
      title: message.notification?.title ?? tryParseString(data['title']),
      body: message.notification?.body ?? tryParseString(data['body']),
      type: tryParseString(data['type']),
      data: data,
    );
  }

  PushMessage _fromPayload(Map<String, dynamic> json) => PushMessage(
    title: tryParseString(json['title']),
    body: tryParseString(json['body']),
    type: tryParseString(json['type']),
    data: Map<String, Object?>.from(asMap(json['data']) ?? const {}),
  );

  Future<void> _showForeground(RemoteMessage remote) async {
    final message = _toMessage(remote);
    _foreground.add(message);
    await _local.show(
      id: _nextId++,
      title: message.title,
      body: message.body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: _androidIcon,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: jsonEncode({
        'title': message.title,
        'body': message.body,
        'type': message.type,
        'data': message.data,
      }),
    );
  }

  PushPermission _map(AuthorizationStatus status) => switch (status) {
    AuthorizationStatus.authorized ||
    AuthorizationStatus.provisional => PushPermission.granted,
    AuthorizationStatus.denied => PushPermission.denied,
    AuthorizationStatus.notDetermined => PushPermission.unknown,
  };

  @override
  Future<PushPermission> permissionStatus() async {
    final settings = await _messaging.getNotificationSettings();
    return _map(settings.authorizationStatus);
  }

  @override
  Future<PushPermission> requestPermission() async {
    await _ensureInitialized();
    final settings = await _messaging.requestPermission();
    return _map(settings.authorizationStatus);
  }

  @override
  Future<String?> getToken() async {
    await _ensureInitialized();
    return _messaging.getToken();
  }

  @override
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  @override
  Stream<PushMessage> get onForegroundMessage {
    unawaited(_ensureInitialized());
    return _foreground.stream;
  }

  @override
  Stream<PushMessage> get onMessageOpened {
    unawaited(_ensureInitialized());
    return _opened.stream;
  }

  @override
  Future<PushMessage?> initialMessage() async {
    final message = await _messaging.getInitialMessage();
    return message == null ? null : _toMessage(message);
  }
}
