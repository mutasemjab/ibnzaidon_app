import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/usecase/usecase.dart';
import 'package:ibnzaidon/features/notifications/domain/entities/app_notification.dart';
import 'package:ibnzaidon/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:ibnzaidon/shared/domain/paged_list.dart';

class GetNotificationsUseCase
    implements UseCase<PagedList<AppNotification>, int> {
  const GetNotificationsUseCase(this._repository);

  final NotificationsRepository _repository;

  @override
  Future<Either<Failure, PagedList<AppNotification>>> call(int page) =>
      _repository.getNotifications(page);
}

class MarkNotificationReadUseCase implements UseCase<Unit, String> {
  const MarkNotificationReadUseCase(this._repository);

  final NotificationsRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String id) => _repository.markRead(id);
}

class MarkAllNotificationsReadUseCase implements UseCase<Unit, NoParams> {
  const MarkAllNotificationsReadUseCase(this._repository);

  final NotificationsRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(NoParams params) =>
      _repository.markAllRead();
}

class RegisterDeviceTokenUseCase implements UseCase<Unit, String> {
  const RegisterDeviceTokenUseCase(this._repository);

  final NotificationsRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String fcmToken) =>
      _repository.registerDeviceToken(fcmToken);
}
