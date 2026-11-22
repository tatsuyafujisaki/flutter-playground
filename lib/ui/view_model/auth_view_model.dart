import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_playground/data/repository/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_view_model.g.dart';

/// A Riverpod async notifier that manages Firebase authentication state.
@Riverpod(keepAlive: true)
class AuthViewModel extends _$AuthViewModel {
  Future<User?>? _pendingSignIn;

  @override
  Future<User?> build() async => ref.watch(authRepositoryProvider).currentUser;

  /// Signs in anonymously if no user is currently authenticated.
  ///
  /// Concurrent calls share the same in-flight request. Throws if sign-in
  /// fails so callers that require authentication do not proceed
  /// unauthenticated.
  Future<User?> signInAnonymously() {
    final authRepository = ref.read(authRepositoryProvider);
    if (authRepository.currentUser case final currentUser?) {
      if (state.value != currentUser) {
        state = AsyncData(currentUser);
      }
      return Future.value(currentUser);
    }
    if (_pendingSignIn case final pending?) {
      return pending;
    }

    final future = _performSignIn(authRepository);
    _pendingSignIn = future;
    return future;
  }

  Future<User?> _performSignIn(AuthRepository authRepository) async {
    state = const AsyncLoading();
    try {
      final credential = await authRepository.signInAnonymously();
      final user = credential.user ?? authRepository.currentUser;
      if (ref.mounted) {
        state = AsyncData(user);
      }
      return user;
    } on Exception catch (error, stackTrace) {
      developer.log(
        'Failed to sign in anonymously',
        error: error,
        stackTrace: stackTrace,
      );
      if (ref.mounted) {
        state = AsyncError(error, stackTrace);
      }
      rethrow;
    } finally {
      _pendingSignIn = null;
    }
  }
}
