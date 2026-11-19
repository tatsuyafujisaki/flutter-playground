import 'dart:developer' as developer;

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'riverpod_examples.g.dart';

/// Returns a greeting for [name], defaulting to `'Anonymous'`.
@riverpod
String myGeneratedOptionalParameter(Ref ref, [String name = 'Anonymous']) =>
    'Hello, $name!';

// Generates AutoDisposeProvider<bool>
/// Returns a parameterless greeting.
@riverpod
String myGeneratedParameterless(Ref ref) => 'Hello!';

/// Returns a greeting for [name].
@riverpod
String myGeneratedRequiredParameter(Ref ref, String name) => 'Hello, $name!';

/// Returns a greeting including [name] and [age].
@riverpod
String myGeneratedRequiredParameters(Ref ref, String name, int age) =>
    'Hello, $age-year-old $name!';

/// Demonstrates using a generated boolean notifier provider.
void showGeneratedBoolNotifirerProviderExamples() {
  final container = ProviderContainer();
  developer.log(container.read(myBoolProvider).toString()); // false
  container.read(myBoolProvider.notifier).toggle();
  developer.log(container.read(myBoolProvider).toString()); // true
}

/// Demonstrates using generated function providers.
void showGeneratedFunctionProviderExamples() {
  final container = ProviderContainer();
  developer.log(container.read(myGeneratedParameterlessProvider)); // Hello!
  developer.log(
    container.read(myGeneratedRequiredParameterProvider('Minnie')),
  ); // Hello, Minnie!
  developer.log(
    container.read(myGeneratedOptionalParameterProvider()),
  ); // Hello, Anonymous!
  developer.log(
    container.read(myGeneratedOptionalParameterProvider('Donald')),
  ); // Hello, Donald!

  developer.log(
    container.read(myGeneratedRequiredParametersProvider('Goofy', 18)),
  ); // Hello, Donald!
}

/// Demonstrates using a generated set notifier provider.
void showGeneratedSetNotifirerProviderExamples() {
  final container = ProviderContainer();
  developer.log(container.read(mySetProvider).toString()); // {}
  container.read(mySetProvider.notifier).add('a');
  developer.log(container.read(mySetProvider).toString()); // {'a'}
  container.read(mySetProvider.notifier).add('b');
  container.read(mySetProvider.notifier).remove('a');
  developer.log(container.read(mySetProvider).toString()); // {'b'}
}

// Generates AutoDisposeNotifierProviderImpl<MyBool, bool>
/// A notifier that manages a boolean flag.
@riverpod
class MyBool extends _$MyBool {
  @override
  bool build() => false;

  /// Toggles the current boolean state.
  void toggle() {
    state = !state;
  }
}

/// A notifier that manages a set of strings.
@riverpod
class MySet extends _$MySet {
  /// Adds [s] to the set.
  void add(String s) {
    state = {...state, s};
  }

  @override
  Set<String> build() => {};

  /// Removes [s] from the set.
  void remove(String s) {
    state.remove(s);
  }
}
