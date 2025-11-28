import 'package:shared_preferences/shared_preferences.dart';

import 'auth_models.dart';

class AuthStorage {
  static const _accessTokenKey = 'flexvault_access_token';
  static const _refreshTokenKey = 'flexvault_refresh_token';
  static const _idTokenKey = 'flexvault_id_token';
  static const _userIdKey = 'flexvault_user_id';
  static const _userEmailKey = 'flexvault_user_email';
  static const _userNameKey = 'flexvault_user_name';
  static const _providerKey = 'flexvault_auth_provider';

  Future<void> saveSession(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, session.tokens.accessToken);
    await prefs.setString(_refreshTokenKey, session.tokens.refreshToken);
    await prefs.setString(_idTokenKey, session.tokens.idToken);
    await prefs.setString(_userIdKey, session.user.userId);
    await prefs.setString(_userEmailKey, session.user.email);
    await prefs.setString(_userNameKey, session.user.name ?? '');
    await prefs.setString(_providerKey, session.provider.name);
  }

  Future<AuthSession?> readSession() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString(_accessTokenKey);
    final refreshToken = prefs.getString(_refreshTokenKey);
    final idToken = prefs.getString(_idTokenKey);
    final userId = prefs.getString(_userIdKey);
    final email = prefs.getString(_userEmailKey);
    final name = prefs.getString(_userNameKey);
    final providerName = prefs.getString(_providerKey);

    if (accessToken == null ||
        refreshToken == null ||
        userId == null ||
        email == null) {
      return null;
    }

    final provider = providerName != null
        ? AuthProviderType.values.firstWhere(
            (value) => value.name == providerName,
            orElse: () => AuthProviderType.email,
          )
        : AuthProviderType.email;

    return AuthSession(
      user: AuthUser(
        userId: userId,
        email: email,
        name: name?.isEmpty == true ? null : name,
      ),
      tokens: AuthTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        idToken: idToken ?? '',
        expiresIn: 0,
      ),
      provider: provider,
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_idTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_providerKey);
  }
}
