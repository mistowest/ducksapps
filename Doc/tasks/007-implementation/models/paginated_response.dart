/// Generic paginated response model based on common API patterns.
/// Supports limit/offset, cursor-based, and page-based pagination.
class PaginatedResponse<T> {
  final List<T> data;
  final int? total;           // Total number of items available
  final int? limit;           // Number of items per page (for limit/offset)
  final int? offset;          // Offset for limit/offset pagination
  final int? page;            // Current page number (for page-based)
  final int? pageSize;        // Page size (for page-based)
  final String? nextCursor;   // Cursor for next page (cursor-based)
  final String? prevCursor;   // Cursor for previous page (cursor-based)
  final bool hasMore;         // Whether there are more pages available

  const PaginatedResponse({
    required this.data,
    this.total,
    this.limit,
    this.offset,
    this.page,
    this.pageSize,
    this.nextCursor,
    this.prevCursor,
    this.hasMore = false,
  });

  /// Creates a paginated response from JSON.
  ///
  /// [json] The JSON map from the API response
  /// [fromJsonT] Function to convert JSON items to type T
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    // Handle data array
    final List<dynamic> dataList = json['data'] ?? json['items'] ?? json['results'] ?? [];
    final List<T> data = dataList.map((item) => fromJsonT(item as Map<String, dynamic>)).toList();

    // Handle total count
    final int? total = json['total'] ?? json['totalCount'] ?? json['count'];

    // Handle limit/offset pagination
    final int? limit = json['limit'] ?? json['per_page'] ?? json['pageSize'];
    final int? offset = json['offset'] ?? json['skip'];

    // Handle page-based pagination
    final int? page = json['page'] ?? json['currentPage'] ?? json['pageNumber'];
    final int? pageSize = json['pageSize'] ?? json['size'] ?? json['limit'];

    // Handle cursor-based pagination
    final String? nextCursor = json['nextCursor'] ?? json['next_cursor'] ?? json['after'];
    final String? prevCursor = json['prevCursor'] ?? json['prev_cursor'] ?? json['before'];

    // Determine if there are more pages
    final bool hasMore = json['hasMore'] ?? json['has_more'] ?? json['hasNextPage'] ??
                        (nextCursor != null && nextCursor.isNotEmpty) ||
                        (page != null && total != null && limit != null && (page * limit < total)) ||
                        (offset != null && total != null && limit != null && (offset + limit < total));

    return PaginatedResponse<T>(
      data: data,
      total: total,
      limit: limit,
      offset: offset,
      page: page,
      pageSize: pageSize,
      nextCursor: nextCursor,
      prevCursor: prevCursor,
      hasMore: hasMore,
    );
  }

  /// Converts the paginated response to JSON.
  Map<String, dynamic> toJson() => {
        'data': data.map((item) => (item as dynamic).toJson()).toList(),
        'total': total,
        'limit': limit,
        'offset': offset,
        'page': page,
        'pageSize': pageSize,
        'nextCursor': nextCursor,
        'prevCursor': prevCursor,
        'hasMore': hasMore,
      };

  /// Returns the next page parameters for limit/offset pagination.
  Map<String, int?> getNextLimitOffsetParams() {
    if (offset == null || limit == null || total == null || !hasMore) return {};
    return {
      'offset': offset + limit,
      'limit': limit,
    };
  }

  /// Returns the next page parameters for page-based pagination.
  Map<String, int?> getNextPageParams() {
    if (page == null || pageSize == null || total == null || !hasMore) return {};
    return {
      'page': page + 1,
      'pageSize': pageSize,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaginatedResponse<T> &&
          runtimeType == other.runtimeType &&
          const ListEquality<T>().equals(data, other.data) &&
          total == other.total &&
          limit == other.limit &&
          offset == other.offset &&
          page == other.page &&
          pageSize == other.pageSize &&
          nextCursor == other.nextCursor &&
          prevCursor == other.prevCursor &&
          hasMore == other.hasMore;

  @override
  int get hashCode =>
      Object.hash(
        Object.hashAll(data),
        total,
        limit,
        offset,
        page,
        pageSize,
        nextCursor,
        prevCursor,
        hasMore,
      );

  @override
  String toString() {
    return 'PaginatedResponse{dataLength: ${data.length}, total: $total, limit: $limit, offset: $offset, page: $page, pageSize: $pageSize, nextCursor: $nextCursor, prevCursor: $prevCursor, hasMore: $hasMore}';
  }
}

/// Helper class for list equality in PaginatedResponse
class ListEquality<E> {
  const ListEquality();

  bool equals(List<E>? a, List<E>? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}