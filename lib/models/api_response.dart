class ApiResponse<T> {
  final bool success;
  final int status;
  final String message;
  final T data;

  ApiResponse({
    required this.success,
    required this.status,
    required this.message,
    required this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    return ApiResponse(
      success: json['success'] as bool,
      status: json['status'] as int,
      message: json['message'] as String,
      data: fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}