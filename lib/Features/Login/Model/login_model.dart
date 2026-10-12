class LoginRequest {
  const LoginRequest({required this.loginId, required this.password});

  final String loginId;
  final String password;

  Map<String, dynamic> toJson() => {
        'loginId': loginId,
        'password': password,
      };
}

class LoginResponse {
  const LoginResponse({
    required this.statusCode,
    required this.message,
    required this.token,
    required this.refreshToken,
  });

  final int statusCode;
  final String message;
  final String token;
  final String refreshToken;

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        statusCode: (json['statusCode'] as num?)?.toInt() ?? 0,
        message: json['message'] as String? ?? '',
        token: json['token'] as String? ?? '',
        refreshToken: json['refreshToken'] as String? ?? '',
      );

  // The web application treats a returned token as the successful-login signal.
  // Keep the mobile client compatible with that behaviour instead of requiring
  bool get isAuthenticated => token.isNotEmpty;
}
