/// OAuth 로그인 성공 시 백엔드에서 받는 토큰 응답
class AuthTokenResponse {
  final String accessToken;
  final String refreshToken;
  final int? expiresIn;
  final String? scope;
  final String? tokenType;
  final String? idToken;

  AuthTokenResponse({
    required this.accessToken,
    required this.refreshToken,
    this.expiresIn,
    this.scope,
    this.tokenType,
    this.idToken,
  });

  factory AuthTokenResponse.fromJson(Map<String, dynamic> json) {
    return AuthTokenResponse(
      accessToken: json['access_token'] ?? json['accessToken'],
      refreshToken: json['refresh_token'] ?? json['refreshToken'],
      expiresIn: json['expires_in'] ?? json['expiresIn'],
      scope: json['scope'],
      tokenType: json['token_type'] ?? json['tokenType'],
      idToken: json['id_token'] ?? json['idToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_in': expiresIn,
      'scope': scope,
      'token_type': tokenType,
      'id_token': idToken,
    };
  }
}
