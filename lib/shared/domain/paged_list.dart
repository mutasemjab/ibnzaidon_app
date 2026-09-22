import 'package:equatable/equatable.dart';

final class PagedList<T> extends Equatable {
  const PagedList({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    this.total = 0,
    this.extra = const {},
  });

  const PagedList.empty()
    : items = const [],
      currentPage = 1,
      lastPage = 1,
      total = 0,
      extra = const {};

  final List<T> items;
  final int currentPage;
  final int lastPage;
  final int total;

  /// Top-level extras such as `unread_count` on notifications.
  final Map<String, Object?> extra;

  bool get hasMore => currentPage < lastPage;

  @override
  List<Object?> get props => [items, currentPage, lastPage, total, extra];
}
