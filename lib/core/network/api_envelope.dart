import 'package:equatable/equatable.dart';
import 'package:ibnzaidon/core/utils/parsers.dart';

/// Laravel envelope: `{ status, message, data, pagination?, ...extras }`.
final class ApiEnvelope {
  const ApiEnvelope({
    required this.status,
    this.message,
    this.data,
    this.pagination,
    this.extras = const {},
  });

  /// Tolerant: anything that is not a JSON object is a [FormatException] so
  /// the guard can map it to `UnknownFailure`.
  factory ApiEnvelope.fromJson(Object? json) {
    final map = asMap(json);
    if (map == null) throw const FormatException('Response is not an object');
    final paginationMap = asMap(map['pagination']);
    final extras = Map<String, dynamic>.of(map)
      ..remove('status')
      ..remove('message')
      ..remove('data')
      ..remove('pagination');
    return ApiEnvelope(
      status: parseBool(map['status'], fallback: true),
      message: tryParseString(map['message']),
      data: map['data'],
      pagination: paginationMap == null
          ? null
          : PaginationMeta.fromJson(paginationMap),
      extras: extras,
    );
  }

  final bool status;
  final String? message;
  final Object? data;
  final PaginationMeta? pagination;
  final Map<String, dynamic> extras;

  Map<String, dynamic> get dataMap => asMap(data) ?? const {};
  List<Object?> get dataList => asList(data);

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data,
    if (pagination != null) 'pagination': pagination!.toJson(),
    ...extras,
  };
}

final class PaginationMeta extends Equatable {
  const PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) => PaginationMeta(
    currentPage: parseInt(json['current_page'], fallback: 1),
    lastPage: parseInt(json['last_page'], fallback: 1),
    perPage: parseInt(json['per_page']),
    total: parseInt(json['total']),
  );

  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  Map<String, dynamic> toJson() => {
    'current_page': currentPage,
    'last_page': lastPage,
    'per_page': perPage,
    'total': total,
  };

  @override
  List<Object?> get props => [currentPage, lastPage, perPage, total];
}
