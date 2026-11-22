import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_playground/data/repository/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_view_model.g.dart';

/// A Riverpod async notifier that manages Firebase authentication state.
@Riverpod(keepAlive: true)
class AuthViewModel extends _$AuthViewModel {
  @override
  Future<UserCredential?> build() async => null;

  /// Signs in anonymously if no user is currently authenticated.
  Future<void> signInAnonymously() async {
    final authRepository = ref.read(authRepositoryProvider);
    if (authRepository.currentUser != null) {
      return;
    }
    state = const AsyncLoading();
    final nextState = await AsyncValue.guard(authRepository.signInAnonymously);
    if (nextState case AsyncError(:final error, :final stackTrace)) {
      developer.log(
        'Failed to sign in anonymously',
        error: error,
        stackTrace: stackTrace,
      );
    }
    if (ref.mounted) {
      state = nextState;
    }
  }
}
