import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Provider for the AuthService. Defaults to MockAuthService
/// but can be overridden in main.dart to use FirebaseAuthService.
final authServiceProvider = Provider<AuthService>((ref) => MockAuthService());

/// Stream provider that emits the current authenticated user (or null).
final authStateProvider = StreamProvider<UserModel?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/// StateNotifier-based controller that manages loading state
/// and delegates auth operations to the AuthService.
final authControllerProvider = StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController(ref.watch(authServiceProvider));
});

class AuthController extends StateNotifier<bool> {
  final AuthService _authService;

  AuthController(this._authService) : super(false); // isLoading = false

  /// Attempts login. Throws [AuthException] with user-friendly message on failure.
  Future<void> login(String email, String password) async {
    state = true;
    try {
      await _authService.login(email, password);
    } catch (e) {
      state = false;
      rethrow;
    }
    state = false;
  }

  /// Attempts signup. Throws [AuthException] with user-friendly message on failure.
  Future<void> signup(String name, String email, String password) async {
    state = true;
    try {
      await _authService.signup(name, email, password);
    } catch (e) {
      state = false;
      rethrow;
    }
    state = false;
  }

  /// Signs out the current user.
  Future<void> logout() async {
    await _authService.logout();
  }
}
