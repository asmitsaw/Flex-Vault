enum AuthProviderType { email, google }

class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.idToken,
    required this.expiresIn,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      idToken: json['idToken'] as String? ?? '',
      expiresIn: json['expiresIn'] as int? ?? 0,
    );
  }

  final String accessToken;
  final String refreshToken;
  final String idToken;
  final int expiresIn;
}

class AuthUser {
  const AuthUser({
    required this.userId,
    required this.email,
    this.name,
    this.emailVerified,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      userId: json['userId'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String?,
      emailVerified: json['emailVerified'] as bool?,
    );
  }

  final String userId;
  final String email;
  final String? name;
  final bool? emailVerified;
}

class AuthSession {
  const AuthSession({
    required this.user,
    required this.tokens,
    required this.provider,
  });

  final AuthUser user;
  final AuthTokens tokens;
  final AuthProviderType provider;
}

class AuthResult {
  const AuthResult({required this.session, this.message});

  final AuthSession? session;
  final String? message;

  bool get hasSession => session != null;
}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
