import 'package:equatable/equatable.dart';

/// Which of the contract-less endpoints a record came from.
enum SchoolRecordKind {
  announcements('announcements'),
  educationalNotes('educational-notes'),
  weeklyPlanner('weekly-planner'),
  classSchedule('class-schedule'),
  examSchedule('exam-schedule');

  const SchoolRecordKind(this.path);

  final String path;
}

/// Tolerant record for endpoints whose response shape is unknown. Only
/// fields that could be read are set; [fields] keeps the remaining scalar
/// values so nothing is silently dropped.
class SchoolRecord extends Equatable {
  const SchoolRecord({
    this.id,
    this.title,
    this.body,
    this.date,
    this.fields = const {},
  });

  final int? id;
  final String? title;
  final String? body;
  final DateTime? date;
  final Map<String, String> fields;

  @override
  List<Object?> get props => [id, title, body, date, fields];
}

class ConductDocument extends Equatable {
  const ConductDocument({this.title, this.body, this.fields = const {}});

  final String? title;
  final String? body;
  final Map<String, String> fields;

  @override
  List<Object?> get props => [title, body, fields];
}

class ConductStatus extends Equatable {
  const ConductStatus({this.isSigned = false, this.signedAt});

  final bool isSigned;
  final DateTime? signedAt;

  @override
  List<Object?> get props => [isSigned, signedAt];
}

class ConductOverview extends Equatable {
  const ConductOverview({required this.document, required this.status});

  final ConductDocument document;
  final ConductStatus status;

  @override
  List<Object?> get props => [document, status];
}
