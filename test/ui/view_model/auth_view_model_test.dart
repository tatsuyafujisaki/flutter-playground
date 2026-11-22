import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_playground/data/repository/auth_repository.dart';
import 'package:flutter_playground/ui/view_model/auth_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeUser extends Fake implements User;

class _FakeUserCredential(@override final User? user)
    extends Fake
    implements UserCredential;

class _FakeAuthRepository({
  @override var User? currentUser,
  var Future<UserCredential> Function()? onSignIn,
}) implements AuthRepository {
  int signInCallCount = 0;

  @override
  Future<UserCredential> signInAnonymously() {
    signInCallCount++;
    return onSignIn!();
  }
}

void main() {
  group('AuthViewModel', () {
    test(
      'build returns persisted currentUser when already signed in',
      () async {
        final persistedUser = _FakeUser();
        final repository = _FakeAuthRepository(currentUser: persistedUser);
        final container = ProviderContainer(
          overrides: [authRepositoryProvider.overrideWithValue(repository)],
        );
        addTearDown(container.dispose);

        final user = container.read(authViewModelProvider);
        expect(user, same(persistedUser));

        final result = await container
            .read(authViewModelProvider.notifier)
            .signInAnonymously();
        expect(result, same(persistedUser));
        expect(repository.signInCallCount, 0);
      },
    );

    test('deduplicates concurrent signInAnonymously calls', () async {
      final signedInUser = _FakeUser();
      final completer = Completer<UserCredential>();
      final repository = _FakeAuthRepository(onSignIn: () => completer.future);
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authViewModelProvider.notifier);

      final first = notifier.signInAnonymously();
      final second = notifier.signInAnonymously();
      expect(repository.signInCallCount, 1);

      repository.currentUser = signedInUser;
      completer.complete(_FakeUserCredential(signedInUser));

      final results = await Future.wait([first, second]);
      expect(results, [same(signedInUser), same(signedInUser)]);
      expect(container.read(authViewModelProvider), same(signedInUser));
    });

    test(
      'rethrows sign-in failures and allows retry after error clears',
      () async {
        final signedInUser = _FakeUser();
        var shouldFail = true;
        final repository = _FakeAuthRepository(
          onSignIn: () async {
            if (shouldFail) {
              throw Exception('network unavailable');
            }
            return _FakeUserCredential(signedInUser);
          },
        );
        final container = ProviderContainer(
          overrides: [authRepositoryProvider.overrideWithValue(repository)],
        );
        addTearDown(container.dispose);

        final notifier = container.read(authViewModelProvider.notifier);

        await expectLater(notifier.signInAnonymously(), throwsException);
        expect(container.read(authViewModelProvider), isNull);

        shouldFail = false;
        final user = await notifier.signInAnonymously();
        expect(user, same(signedInUser));
        expect(repository.signInCallCount, 2);
        expect(container.read(authViewModelProvider), same(signedInUser));
      },
    );
  });
}
