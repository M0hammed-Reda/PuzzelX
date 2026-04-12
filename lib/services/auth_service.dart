import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

/// Custom exception for authentication errors with user-friendly messages.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

/// Abstract contract for authentication services.
/// Allows swapping between real Firebase and mock implementations.
abstract class AuthService {
  Future<UserModel?> login(String email, String password);
  Future<UserModel?> signup(String name, String email, String password);
  Future<void> logout();
  Stream<UserModel?> get authStateChanges;
}

/// Converts Firebase error codes into user-friendly messages.
String _mapFirebaseAuthError(FirebaseAuthException e) {
  switch (e.code) {
    case 'user-not-found':
      return 'No account found with this email. Please sign up first.';
    case 'wrong-password':
      return 'Incorrect password. Please try again.';
    case 'invalid-email':
      return 'The email address is not valid.';
    case 'user-disabled':
      return 'This account has been disabled. Contact support for help.';
    case 'email-already-in-use':
      return 'An account already exists with this email. Try logging in instead.';
    case 'operation-not-allowed':
      return 'Email/password sign-in is not enabled. Contact support.';
    case 'weak-password':
      return 'Password is too weak. Please use at least 6 characters.';
    case 'too-many-requests':
      return 'Too many failed attempts. Please wait a moment and try again.';
    case 'network-request-failed':
      return 'Network error. Please check your internet connection.';
    case 'invalid-credential':
      return 'Invalid email or password. Please check and try again.';
    default:
      return e.message ?? 'An unexpected error occurred. Please try again.';
  }
}

/// Real Firebase Authentication implementation.
class FirebaseAuthService implements AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService.instance;

  @override
  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      var userModel = await _firestore.getUser(user.uid);
      
      // Auto-heal: If user exists in Auth but missing in Firestore 
      // (happens if DB was created after account signup).
      if (userModel == null) {
        userModel = UserModel(
          uid: user.uid, 
          name: user.displayName ?? 'Player', 
          email: user.email ?? '',
        );
        await _firestore.saveUser(userModel);
      }
      return userModel;
    });
  }

  @override
  Future<UserModel?> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (cred.user != null) {
        var userModel = await _firestore.getUser(cred.user!.uid);
        
        // Auto-heal missing firestore document
        if (userModel == null) {
          userModel = UserModel(
            uid: cred.user!.uid, 
            name: cred.user!.displayName ?? 'Player', 
            email: cred.user!.email ?? '',
          );
          await _firestore.saveUser(userModel);
        }
        return userModel;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } catch (e) {
      throw const AuthException('Something went wrong. Please try again later.');
    }
  }

  @override
  Future<UserModel?> signup(String name, String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (cred.user != null) {
        // Update the Firebase user display name
        await cred.user!.updateDisplayName(name);

        final user = UserModel(uid: cred.user!.uid, name: name, email: email);
        await _firestore.saveUser(user);
        return user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } catch (e) {
      throw const AuthException('Something went wrong. Please try again later.');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw const AuthException('Failed to sign out. Please try again.');
    }
  }
}

/// Mock authentication for development and testing without Firebase.
class MockAuthService implements AuthService {
  UserModel? _currentUser;
  final _controller = StreamController<UserModel?>.broadcast();

  @override
  Stream<UserModel?> get authStateChanges async* {
    yield _currentUser;
    yield* _controller.stream;
  }

  @override
  Future<UserModel?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    // Simulate invalid credentials
    if (password.length < 6) {
      throw const AuthException('Incorrect password. Please try again.');
    }

    _currentUser = UserModel(uid: 'mock_uid_1', name: 'Test User', email: email);
    _controller.add(_currentUser);
    return _currentUser;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
    _controller.add(_currentUser);
  }

  @override
  Future<UserModel?> signup(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    _currentUser = UserModel(uid: 'mock_uid_1', name: name, email: email);
    final mockFirestore = FirestoreService.instance;
    await mockFirestore.saveUser(_currentUser!);
    _controller.add(_currentUser);
    return _currentUser;
  }
}
