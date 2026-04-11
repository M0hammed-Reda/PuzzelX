import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

abstract class AuthService {
  Future<UserModel?> login(String email, String password);
  Future<UserModel?> signup(String name, String email, String password);
  Future<void> logout();
  Stream<UserModel?> get authStateChanges;
}

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
    // Mock save to firestore
    final mockFirestore = FirestoreService.instance; // will be Mocked
    await mockFirestore.saveUser(_currentUser!);
    _controller.add(_currentUser);
    return _currentUser;
  }
}

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService.instance;

  @override
  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return await _firestore.getUser(user.uid);
    });
  }

  @override
  Future<UserModel?> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    if (cred.user != null) {
      return await _firestore.getUser(cred.user!.uid);
    }
    return null;
  }

  @override
  Future<UserModel?> signup(String name, String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    if (cred.user != null) {
      final user = UserModel(uid: cred.user!.uid, name: name, email: email);
      await _firestore.saveUser(user);
      return user;
    }
    return null;
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }
}
