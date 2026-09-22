import 'package:equatable/equatable.dart';
import 'package:ibnzaidon/shared/domain/entities/course.dart';

enum LibraryKind {
  previousExams('previous-year-exams'),
  questionBanks('question-banks'),
  worksheets('worksheets');

  const LibraryKind(this.path);

  final String path;
}

class LibraryItem extends Equatable {
  const LibraryItem({
    required this.id,
    required this.title,
    required this.pdfUrl,
    this.tag,
    this.year,
    this.pages = 0,
    this.fileSize,
    this.subject,
    this.teacher,
    this.classInfo,
  });

  final int id;
  final String title;
  final String? pdfUrl;
  final String? tag;
  final int? year;
  final int pages;
  final String? fileSize;
  final IdName? subject;
  final IdName? teacher;
  final IdName? classInfo;

  @override
  List<Object?> get props => [
    id,
    title,
    pdfUrl,
    tag,
    year,
    pages,
    fileSize,
    subject,
    teacher,
    classInfo,
  ];
}

class LibraryQuery extends Equatable {
  const LibraryQuery({
    this.search = '',
    this.subjectId,
    this.year,
    this.classId,
  });

  final String search;
  final int? subjectId;
  final int? year;
  final int? classId;

  LibraryQuery copyWith({
    String? search,
    int? subjectId,
    int? year,
    bool clearSubject = false,
    bool clearYear = false,
  }) => LibraryQuery(
    search: search ?? this.search,
    subjectId: clearSubject ? null : subjectId ?? this.subjectId,
    year: clearYear ? null : year ?? this.year,
    classId: classId,
  );

  @override
  List<Object?> get props => [search, subjectId, year, classId];
}
