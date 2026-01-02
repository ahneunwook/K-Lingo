/// 백엔드 성공 응답
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final DateTime? timestamp;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.timestamp,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      message: json['message'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : null,
    );
  }
}

/// 백엔드 에러 응답
class ErrorResponse {
  final String code;
  final String message;
  final List<FieldError> errors;
  final DateTime? timestamp;

  ErrorResponse({
    required this.code,
    required this.message,
    this.errors = const [],
    this.timestamp,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      code: json['code'] ?? '',
      message: json['message'] ?? '',
      errors: json['errors'] != null
          ? (json['errors'] as List)
              .map((e) => FieldError.fromJson(e))
              .toList()
          : [],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : null,
    );
  }
}

/// 필드 에러 (validation 에러용)
class FieldError {
  final String field;
  final String value;
  final String reason;

  FieldError({
    required this.field,
    required this.value,
    required this.reason,
  });

  factory FieldError.fromJson(Map<String, dynamic> json) {
    return FieldError(
      field: json['field'] ?? '',
      value: json['value'] ?? '',
      reason: json['reason'] ?? '',
    );
  }
}
