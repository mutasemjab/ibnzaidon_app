import 'package:ibnzaidon/features/notifications/domain/entities/app_notification.dart';

/// FCM + local notification abstraction (Firebase stays in the data layer).
abstract interface class PushMessagingService {
  Future<PushPermission> permissionStatus();
  Future<PushPermission> requestPermission();
  Future<String?> getToken();
  Stream<String> get onTokenRefresh;

  /// Messages received while the app is in the foreground (already shown as
  /// a local notification by the implementation).
  Stream<PushMessage> get onForegroundMessage;

  /// User tapped a notification while the app was backgrounded.
  Stream<PushMessage> get onMessageOpened;

  /// The message that launched the app from a terminated state, if any.
  Future<PushMessage?> initialMessage();
}
