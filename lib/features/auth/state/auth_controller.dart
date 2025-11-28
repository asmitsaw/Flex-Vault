import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_models.dart';
import '../data/auth_repository.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    final repository = ref.watch(authRepositoryProvider);
    return AuthController(repository);
  },
);

class AuthState {
  const AuthState({
    required this.isLoading,
    this.session,
    this.errorMessage,
    this.infoMessage,
  });

  factory AuthState.initial() => const AuthState(isLoading: true);

  final bool isLoading;
  final AuthSession? session;
  final String? errorMessage;
  final String? infoMessage;

  bool get isAuthenticated => session != null;

  AuthState copyWith({
    bool? isLoading,
    AuthSession? session,
    String? errorMessage,
    String? infoMessage,
    bool clearError = false,
    bool clearInfo = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      session: session ?? this.session,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      infoMessage: clearInfo ? null : infoMessage ?? this.infoMessage,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository) : super(AuthState.initial()) {
    _restoreSession();
  }

  final AuthRepository _repository;

  Future<void> _restoreSession() async {
    try {
      final session = await _repository.loadPersistedSession();
      state = state.copyWith(
        isLoading: false,
        session: session,
        clearError: true,
        clearInfo: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
        clearInfo: true,
      );
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true, clearInfo: true);
    try {
      final session = await _repository.login(email: email, password: password);
      state = state.copyWith(isLoading: false, session: session);
    } on AuthException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> signUp(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true, clearInfo: true);
    try {
      await _repository.signUp(email: email, password: password, name: name);
      state = state.copyWith(
        isLoading: false,
        infoMessage:
            'Account created. Please verify your email before logging in.',
      );
    } on AuthException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true, clearInfo: true);
    try {
      final session = await _repository.signInWithGoogle();
      state = state.copyWith(isLoading: false, session: session);
    } on AuthException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> refreshSession() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final session = await _repository.refreshWithStoredToken();
      state = state.copyWith(isLoading: false, session: session);
    } on AuthException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = state.copyWith(
      session: null,
      infoMessage: 'You have been signed out.',
    );
  }
}
