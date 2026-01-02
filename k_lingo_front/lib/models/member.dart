// 사용자 역할
enum Role { USER, ADMIN }

// 소셜 로그인 제공자
enum Provider { GOOGLE, APPLE }

class Member {
  final int? id;
  final String email;
  final String nickname;
  final String provider;   // GOOGLE, APPLE
  final String providerId; // 소셜 서비스에서 제공하는 고유 식별값
  final Role role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Member({
    this.id,
    required this.email,
    required this.nickname,
    required this.provider,
    required this.providerId,
    this.role = Role.USER,
    this.createdAt,
    this.updatedAt,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      email: json['email'] ?? '',
      nickname: json['nickname'] ?? '',
      provider: json['provider'] ?? '',
      providerId: json['providerId'] ?? '',
      role: _parseRole(json['role']),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nickname': nickname,
      'provider': provider,
      'providerId': providerId,
      'role': role.name,
    };
  }

  static Role _parseRole(String? role) {
    switch (role) {
      case 'ADMIN':
        return Role.ADMIN;
      default:
        return Role.USER;
    }
  }

  // 편의 메서드
  bool get isAdmin => role == Role.ADMIN;
  bool get isGoogleUser => provider == 'GOOGLE';
  bool get isAppleUser => provider == 'APPLE';
}
