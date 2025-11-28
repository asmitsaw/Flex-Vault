import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/services/api_client.dart';
import 'auth_models.dart';
import 'auth_storage.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return AuthRepository(
    apiClient: apiClient,
    storage: AuthStorage(),
    googleSignIn: GoogleSignIn(
      scopes: const ['email', 'profile'],
      signInOption: SignInOption.standard,
    ),
  );
});

class AuthRepository {
  AuthRepository({
    required ApiClient apiClient,
    required AuthStorage storage,
    GoogleSignIn? googleSignIn,
  }) : _apiClient = apiClient,
       _storage = storage,
       _googleSignIn =
           googleSignIn ?? GoogleSignIn(scopes: const ['email', 'profile']);

  final ApiClient _apiClient;
  final AuthStorage _storage;
  final GoogleSignIn _googleSignIn;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final tokens = _parseTokens(response);
      _apiClient.setAuthToken(tokens.accessToken);
      final user = await _fetchCurrentUser();
      final session = AuthSession(
        user: user,
        tokens: tokens,
        provider: AuthProviderType.email,
      );
      await _storage.saveSession(session);
      return session;
    } on DioException catch (error) {
      final message = _extractError(error);
      throw AuthException(message);
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      await _apiClient.post(
        '/auth/signup',
        data: {'email': email, 'password': password, 'name': name},
      );
    } on DioException catch (error) {
      throw AuthException(_extractError(error));
    }
  }

  Future<AuthSession> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        throw AuthException('Google sign-in was cancelled');
      }

      final authentication = await account.authentication;
      final idToken = authentication.idToken;
      if (idToken == null) {
        throw AuthException('Failed to retrieve Google ID token');
      }

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/google',
        data: {'idToken': idToken},
      );

      final tokens = _parseTokens(response);
      _apiClient.setAuthToken(tokens.accessToken);
      final user = await _fetchCurrentUser();
      final session = AuthSession(
        user: user,
        tokens: tokens,
        provider: AuthProviderType.google,
      );
      await _storage.saveSession(session);
      return session;
    } on DioException catch (error) {
      throw AuthException(_extractError(error));
    }
  }

  Future<AuthSession?> loadPersistedSession() async {
    final session = await _storage.readSession();
    if (session != null) {
      _apiClient.setAuthToken(session.tokens.accessToken);
    }
    return session;
  }

  Future<AuthSession> refreshWithStoredToken() async {
    final stored = await _storage.readSession();
    if (stored == null || stored.tokens.refreshToken.isEmpty) {
      throw AuthException('No session to refresh');
    }

    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/refresh-token',
        data: {'refreshToken': stored.tokens.refreshToken},
      );
      final tokens = _parseTokens(response);
      _apiClient.setAuthToken(tokens.accessToken);
      final user = await _fetchCurrentUser();
      final session = AuthSession(
        user: user,
        tokens: tokens,
        provider: stored.provider,
      );
      await _storage.saveSession(session);
      return session;
    } on DioException catch (error) {
      throw AuthException(_extractError(error));
    }
  }

  Future<void> logout() async {
    await _storage.clear();
    await _googleSignIn.signOut();
    _apiClient.setAuthToken(null);
  }

  Future<AuthUser> _fetchCurrentUser() async {
    final response = await _apiClient.get<Map<String, dynamic>>('/me');
    final payload = _unwrap(response.data);
    return AuthUser.fromJson(payload as Map<String, dynamic>);
  }

  AuthTokens _parseTokens(Response<Map<String, dynamic>> response) {
    final payload = _unwrap(response.data);
    return AuthTokens.fromJson(payload as Map<String, dynamic>);
  }

  dynamic _unwrap(Map<String, dynamic>? data) {
    if (data == null) return {};
    return data['data'] ?? data;
  }

  String _extractError(DioException error) {
    final responseMessage = error.response?.data is Map
        ? (error.response!.data['message'] as String?) ??
              (error.response!.data['error'] as String?)
        : null;
    return responseMessage ??
        error.message ??
        'Something went wrong. Please check your connection and try again.';
  }
}
