import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/bloc/paged_bloc.dart';
import 'package:ibnzaidon/core/usecase/usecase.dart';
import 'package:ibnzaidon/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:ibnzaidon/features/notifications/domain/entities/app_notification.dart';
import 'package:ibnzaidon/features/notifications/domain/usecases/notifications_usecases.dart';
import 'package:ibnzaidon/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:ibnzaidon/features/notifications/presentation/notification_link_resolver.dart';
import 'package:ibnzaidon/shared/domain/paged_list.dart';
import 'package:mocktail/mocktail.dart';

class _MockGet extends Mock implements GetNotificationsUseCase {}

class _MockRead extends Mock implements MarkNotificationReadUseCase {}

class _MockReadAll extends Mock implements MarkAllNotificationsReadUseCase {}

AppNotification _n(String id, {bool read = false}) =>
    AppNotification(id: id, title: 't$id', body: 'b', isRead: read);

void main() {
  late _MockGet get;
  late _MockRead read;
  late _MockReadAll readAll;

  setUpAll(() => registerFallbackValue(const NoParams()));

  setUp(() {
    get = _MockGet();
    read = _MockRead();
    readAll = _MockReadAll();
    when(() => get(any())).thenAnswer(
      (_) async => right(
        PagedList(
          items: [_n('a'), _n('b'), _n('c', read: true)],
          currentPage: 1,
          lastPage: 1,
          extra: const {'unread_count': 2},
        ),
      ),
    );
    when(() => read(any())).thenAnswer((_) async => right(unit));
    when(() => readAll(any())).thenAnswer((_) async => right(unit));
  });

  NotificationsBloc build() => NotificationsBloc(
    getNotifications: get,
    markRead: read,
    markAllRead: readAll,
  );

  blocTest<NotificationsBloc, PagedState<AppNotification, NoQuery>>(
    'loads notifications and keeps the server unread_count',
    build: build,
    act: (bloc) => bloc.add(const PagedStarted<NoQuery>()),
    verify: (bloc) {
      expect(bloc.state.items.length, 3);
      expect(bloc.unreadCount, 2);
    },
  );

  blocTest<NotificationsBloc, PagedState<AppNotification, NoQuery>>(
    'marking one as read is optimistic and decrements the counter',
    build: build,
    act: (bloc) async {
      bloc.add(const PagedStarted<NoQuery>());
      await bloc.stream.firstWhere((s) => s.status == PagedStatus.success);
      bloc.add(const NotificationReadRequested('a'));
    },
    verify: (bloc) {
      expect(bloc.state.items.first.isRead, isTrue);
      expect(bloc.unreadCount, 1);
      verify(() => read('a')).called(1);
    },
  );

  blocTest<NotificationsBloc, PagedState<AppNotification, NoQuery>>(
    'mark all read clears every item and the counter',
    build: build,
    act: (bloc) async {
      bloc.add(const PagedStarted<NoQuery>());
      await bloc.stream.firstWhere((s) => s.status == PagedStatus.success);
      bloc.add(const NotificationsReadAllRequested());
    },
    verify: (bloc) {
      expect(bloc.state.items.every((n) => n.isRead), isTrue);
      expect(bloc.unreadCount, 0);
      verify(() => readAll(any())).called(1);
    },
  );

  group('NotificationLinkResolver', () {
    test('routes by payload ids', () {
      expect(
        NotificationLinkResolver.resolve('x', {
          'course_id': 4,
          'lesson_id': '9',
        }),
        '/course/4/lesson/9',
      );
      expect(NotificationLinkResolver.resolve(null, {'exam_id': 3}), '/exam/3');
      expect(
        NotificationLinkResolver.resolve(null, {'course_id': 4}),
        '/course/4',
      );
    });

    test('falls back to the notifications list', () {
      expect(NotificationLinkResolver.resolve('general', {}), '/notifications');
    });
  });

  test('parses a notification with a free-form data payload', () {
    final n = NotificationsRepositoryImpl.parseNotification({
      'id': 12,
      'title': 'New lesson',
      'body': 'Go',
      'type': 'course',
      'data': {'course_id': 5},
      'is_read': 0,
      'created_at': '2025-02-01 08:00',
    });
    expect(n.id, '12');
    expect(n.isRead, isFalse);
    expect(n.data['course_id'], 5);
    expect(n.createdAt, DateTime(2025, 2, 1, 8));
  });
}
