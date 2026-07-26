class UserCreateRequest {
  final String email;
  final String password;
  final String username;
  final String displayName;

  UserCreateRequest({
    required this.email,
    required this.password,
    required this.username,
    required this.displayName,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'username': username,
      'display_name': displayName,
    };
  }
}

class UserLoginRequest {
  final String login;
  final String password;

  UserLoginRequest({required this.login, required this.password});

  Map<String, dynamic> toJson() {
    return {'login': login, 'password': password};
  }
}

class UserOutResponse {
  final int id;
  final String email;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String? profileBannerUrl;
  final String privacyDefault;
  final String theme;
  final String language;
  final String timezone;
  final DateTime createdAt;

  UserOutResponse({
    required this.id,
    required this.email,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.profileBannerUrl,
    required this.privacyDefault,
    required this.theme,
    required this.language,
    required this.timezone,
    required this.createdAt,
  });

  factory UserOutResponse.fromJson(Map<String, dynamic> json) {
    return UserOutResponse(
      id: json['id'] as int,
      email: json['email'] as String,
      username: json['username'] as String,
      displayName: json['display_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      profileBannerUrl: json['profile_banner_url'] as String?,
      privacyDefault: json['privacy_default'] as String,
      theme: json['theme'] as String,
      language: json['language'] as String,
      timezone: json['timezone'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
