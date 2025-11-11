class PaginationModel {
  final int limit;
  final int offset;
  final int count;

  const PaginationModel({
    required this.limit,
    required this.offset,
    required this.count,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      limit: (json['limit'] as num?)?.toInt() ?? 0,
      offset: (json['offset'] as num?)?.toInt() ?? 0,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}

class ListResponse<T> {
  final bool success;
  final List<T> data;
  final PaginationModel pagination;

  const ListResponse({
    required this.success,
    required this.data,
    required this.pagination,
  });

  factory ListResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) mapper,
  ) {
    final list = (json['data'] as List? ?? const [])
        .map((e) => mapper((e as Map).cast<String, dynamic>()))
        .toList();

    return ListResponse(
      success: json['success'] as bool? ?? true,
      data: list,
      pagination: PaginationModel.fromJson(
        (json['pagination'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
    );
  }
}

