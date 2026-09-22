import 'package:ibnzaidon/core/network/api_envelope.dart';
import 'package:ibnzaidon/core/utils/parsers.dart';
import 'package:ibnzaidon/shared/domain/paged_list.dart';

/// Parses a paginated Laravel envelope. Malformed rows are skipped; extra
/// top-level keys (e.g. `unread_count`) are forwarded in [PagedList.extra].
PagedList<T> pagedFromEnvelope<T>(
  ApiEnvelope envelope,
  T Function(Map<String, dynamic> json) parse,
) {
  final meta = envelope.pagination;
  final items = mapList(envelope.data, parse);
  return PagedList<T>(
    items: items,
    currentPage: meta?.currentPage ?? 1,
    lastPage: meta?.lastPage ?? 1,
    total: meta?.total ?? items.length,
    extra: envelope.extras,
  );
}
