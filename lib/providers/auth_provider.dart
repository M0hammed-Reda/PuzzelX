import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

// Since we may not have Firebase initialized, we can swap these out in main.dart
final authServiceProvider = Provider<AuthService>((ref) => MockAuthService());

final authStateProvider = StreamProvider<UserModel?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final authControllerProvider = StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController(ref.watch(authServiceProvider));
});

class AuthController extends StateNotifier<bool> {
  final AuthService _authService;

  AuthController(this._authService) : super(false); // isLoading

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

  Future<void> logout() async {
    await _authService.logout();
  }
}
