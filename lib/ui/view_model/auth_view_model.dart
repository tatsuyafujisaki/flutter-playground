import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_playground/data/repository/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_view_model.g.dart';

/// A Riverpod notifier that manages Firebase authentication state.
@Riverpod(keepAlive: true)
class AuthViewModel extends _$AuthViewModel {
  @override
  UserCredential? build() => null;

  /// Signs in anonymously if no user is currently authenticated.
  Future<void> signInAnonymously() async {
    final authRepository = ref.read(authRepositoryProvider);
    if (authRepository.currentUser == null) {
      final credential = await authRepository.signInAnonymously();
      if (ref.mounted) {
        state = credential;
      }
    }
  }
}
