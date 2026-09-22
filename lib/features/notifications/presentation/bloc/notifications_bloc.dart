import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/bloc/paged_bloc.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/core/usecase/usecase.dart';
import 'package:ibnzaidon/core/utils/parsers.dart';
import 'package:ibnzaidon/features/notifications/domain/entities/app_notification.dart';
import 'package:ibnzaidon/features/notifications/domain/usecases/notifications_usecases.dart';
import 'package:ibnzaidon/shared/domain/paged_list.dart';

final class NotificationReadRequested extends PagedEvent<NoQuery> {
  const NotificationReadRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

final class NotificationsReadAllRequested extends PagedEvent<NoQuery> {
  const NotificationsReadAllRequested();
}

/// Notification list with optimistic mark-read / mark-all-read.
class NotificationsBloc extends PagedBloc<AppNotification, NoQuery> {
  NotificationsBloc({
    required GetNotificationsUseCase getNotifications,
    required MarkNotificationReadUseCase markRead,
    required MarkAllNotificationsReadUseCase markAllRead,
  }) : _getNotifications = getNotifications,
       _markRead = markRead,
       _markAllRead = markAllRead,
       super(initialQuery: const NoQuery()) {
    on<NotificationReadRequested>(_onRead, transformer: sequential());
    on<NotificationsReadAllRequested>(_onReadAll, transformer: droppable());
  }

  final GetNotificationsUseCase _getNotifications;
  final MarkNotificationReadUseCase _markRead;
  final MarkAllNotificationsReadUseCase _markAllRead;

  @override
  Future<Either<Failure, PagedList<AppNotification>>> fetchPage(
    int page,
    NoQuery query,
  ) => _getNotifications(page);

  int get unreadCount =>
      parseInt(state.extra['unread_count'], fallback: -1) >= 0
      ? parseInt(state.extra['unread_count'])
      : state.items.where((n) => !n.isRead).length;

  Future<void> _onRead(
    NotificationReadRequested event,
    Emitter<PagedState<AppNotification, NoQuery>> emit,
  ) async {
    final target = state.items.where((n) => n.id == event.id).firstOrNull;
    if (target == null || target.isRead) return;
    emit(
      state.copyWith(
        items: [
          for (final item in state.items)
            if (item.id == event.id) item.markRead() else item,
        ],
        extra: {
          ...state.extra,
          'unread_count': (unreadCount - 1).clamp(0, 1 << 31),
        },
      ),
    );
    await _markRead(event.id);
  }

  Future<void> _onReadAll(
    NotificationsReadAllRequested event,
    Emitter<PagedState<AppNotification, NoQuery>> emit,
  ) async {
    emit(
      state.copyWith(
        items: [for (final item in state.items) item.markRead()],
        extra: {...state.extra, 'unread_count': 0},
      ),
    );
    await _markAllRead(const NoParams());
  }
}

/// App-wide unread counter for the bell badge.
class NotificationsBadgeCubit extends Cubit<int> {
  NotificationsBadgeCubit(this._getNotifications) : super(0);

  final GetNotificationsUseCase _getNotifications;

  Future<void> refresh() async {
    final result = await _getNotifications(1);
    result.fold((_) {}, (page) {
      final count =
          tryParseInt(page.extra['unread_count']) ??
          page.items.where((n) => !n.isRead).length;
      if (!isClosed) emit(count);
    });
  }

  void set(int count) => emit(count < 0 ? 0 : count);
  void increment() => emit(state + 1);
  void clear() => emit(0);
}
