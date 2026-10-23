import 'package:equatable/equatable.dart';

/// Server-authored long-form content (terms, privacy policy, about us,
/// support) for one slug.
class InfoPage extends Equatable {
  const InfoPage({required this.title, required this.body});

  final String title;
  final String body;

  @override
  List<Object?> get props => [title, body];
}
