import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/network/api_client.dart';
import 'package:ibnzaidon/core/network/api_guard.dart';
import 'package:ibnzaidon/core/utils/parsers.dart';
import 'package:ibnzaidon/features/notifications/domain/entities/app_notification.dart';
import 'package:ibnzaidon/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:ibnzaidon/shared/data/paged_parser.dart';
import 'package:ibnzaidon/shared/domain/paged_list.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl({
    required ApiClient client,
    required ApiGuard guard,
  }) : _client = client,
       _guard = guard;

  final ApiClient _client;
  final ApiGuard _guard;

  @override
  Future<Either<Failure, PagedList<AppNotification>>> getNotifications(
    int page,
  ) => _guard.run(() async {
    final envelope = await _client.get('notifications', query: {'page': page});
    return pagedFromEnvelope<AppNotification>(envelope, parseNotification);
  });

  static AppNotification parseNotification(Map<String, dynamic> json) {
    final data = asMap(json['data']) ?? const <String, dynamic>{};
    return AppNotification(
      id: parseString(json['id']),
      title: parseString(json['title']),
      body: parseString(json['body']),
      type: tryParseString(json['type']),
      data: Map<String, Object?>.from(data),
      isRead: parseBool(json['is_read']),
      createdAt: tryParseDate(json['created_at']),
    );
  }

  @override
  Future<Either<Failure, Unit>> markRead(String id) => _guard.run(() async {
    await _client.post('notifications/$id/read');
    return unit;
  });

  @override
  Future<Either<Failure, Unit>> markAllRead() => _guard.run(() async {
    await _client.post('notifications/read-all');
    return unit;
  });

  @override
  Future<Either<Failure, Unit>> registerDeviceToken(String fcmToken) =>
      _guard.run(() async {
        await _client.post('device-token', body: {'fcm_token': fcmToken});
        return unit;
      });
}
