import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

/// Provides the singleton [AuthRepository] instance.
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => AuthRepository(FirebaseAuth.instance);

/// A repository that wraps [FirebaseAuth] operations.
class AuthRepository {
  /// Creates an [AuthRepository] with the given [FirebaseAuth] instance.
  const AuthRepository(this._auth);

  final FirebaseAuth _auth;

  /// The currently signed-in user, or `null` if none is signed in.
  User? get currentUser => _auth.currentUser;

  /// Signs in the user anonymously.
  Future<UserCredential> signInAnonymously() => _auth.signInAnonymously();
}
