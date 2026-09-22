import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.type,
    this.data = const {},
    this.isRead = false,
    this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final String? type;

  /// Free-form payload; keys such as `course_id` / `exam_id` drive deep links.
  final Map<String, Object?> data;
  final bool isRead;
  final DateTime? createdAt;

  AppNotification markRead() => AppNotification(
    id: id,
    title: title,
    body: body,
    type: type,
    data: data,
    isRead: true,
    createdAt: createdAt,
  );

  @override
  List<Object?> get props => [id, title, body, type, data, isRead, createdAt];
}

enum PushPermission { unknown, granted, denied }

/// A push message reduced to what the app needs.
class PushMessage extends Equatable {
  const PushMessage({this.title, this.body, this.type, this.data = const {}});

  final String? title;
  final String? body;
  final String? type;
  final Map<String, Object?> data;

  @override
  List<Object?> get props => [title, body, type, data];
}
