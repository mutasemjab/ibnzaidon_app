import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/features/notifications/domain/entities/app_notification.dart';
import 'package:ibnzaidon/shared/domain/paged_list.dart';

abstract interface class NotificationsRepository {
  /// [PagedList.extra] carries `unread_count`.
  Future<Either<Failure, PagedList<AppNotification>>> getNotifications(
    int page,
  );
  Future<Either<Failure, Unit>> markRead(String id);
  Future<Either<Failure, Unit>> markAllRead();
  Future<Either<Failure, Unit>> registerDeviceToken(String fcmToken);
}
