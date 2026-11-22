import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_playground/data/repository/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_view_model.g.dart';

/// A Riverpod notifier that manages Firebase authentication state.
@Riverpod(keepAlive: true)
class AuthViewModel extends _$AuthViewModel {
  Future<User?>? _pendingSignIn;

  @override
  User? build() => ref.watch(authRepositoryProvider).currentUser;

  /// Signs in anonymously if no user is currently authenticated.
  ///
  /// Concurrent calls share the same in-flight request. Throws if sign-in
  /// fails so callers that require authentication do not proceed
  /// unauthenticated.
  Future<User?> signInAnonymously() {
    final authRepository = ref.read(authRepositoryProvider);
    if (authRepository.currentUser case final currentUser?) {
      return Future.value(state = currentUser);
    }
    return _pendingSignIn ??= _performSignIn(authRepository);
  }

  Future<User?> _performSignIn(AuthRepository authRepository) async {
    try {
      final credential = await authRepository.signInAnonymously();
      final user = credential.user ?? authRepository.currentUser;
      if (ref.mounted) {
        state = user;
      }
      return user;
    } on Exception catch (error, stackTrace) {
      developer.log(
        'Failed to sign in anonymously',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    } finally {
      _pendingSignIn = null;
    }
  }
}
