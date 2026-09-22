import 'package:equatable/equatable.dart';
import 'package:ibnzaidon/shared/domain/entities/course.dart';

class TeacherDetail extends Equatable {
  const TeacherDetail({
    required this.teacher,
    this.bio,
    this.qualification,
    this.courses = const [],
  });

  final Teacher teacher;
  final String? bio;
  final String? qualification;
  final List<Course> courses;

  @override
  List<Object?> get props => [teacher, bio, qualification, courses];
}

class TeachersQuery extends Equatable {
  const TeachersQuery({this.search = ''});

  final String search;

  @override
  List<Object?> get props => [search];
}
