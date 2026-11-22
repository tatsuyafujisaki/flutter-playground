import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'riverpod_examples.g.dart';

/// Returns a greeting for [name], defaulting to `'Anonymous'`.
@riverpod
String myGeneratedOptionalParameter(Ref ref, [String name = 'Anonymous']) =>
    'Hello, $name!';

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
void showGeneratedBoolNotifierProviderExamples() {
  final container = ProviderContainer();
  try {
    stdout.writeln(container.read(myBoolProvider)); // false
    container.read(myBoolProvider.notifier).toggle();
    stdout.writeln(container.read(myBoolProvider)); // true
  } finally {
    container.dispose();
  }
}

/// Demonstrates using generated function providers.
void showGeneratedFunctionProviderExamples() {
  final container = ProviderContainer();
  try {
    stdout
      ..writeln(container.read(myGeneratedParameterlessProvider)) // Hello!
      ..writeln(
        container.read(myGeneratedRequiredParameterProvider('Minnie')),
      ) // Hello, Minnie!
      ..writeln(
        container.read(myGeneratedOptionalParameterProvider()),
      ) // Hello, Anonymous!
      ..writeln(
        container.read(myGeneratedOptionalParameterProvider('Donald')),
      ) // Hello, Donald!
      ..writeln(
        container.read(myGeneratedRequiredParametersProvider('Goofy', 18)),
      ); // Hello, 18-year-old Goofy!
  } finally {
    container.dispose();
  }
}

/// Demonstrates using a generated set notifier provider.
void showGeneratedSetNotifierProviderExamples() {
  final container = ProviderContainer();
  try {
    stdout.writeln(container.read(mySetProvider)); // {}
    container.read(mySetProvider.notifier).add('a');
    stdout.writeln(container.read(mySetProvider)); // {'a'}
    container.read(mySetProvider.notifier).add('b');
    container.read(mySetProvider.notifier).remove('a');
    stdout.writeln(container.read(mySetProvider)); // {'b'}
  } finally {
    container.dispose();
  }
}

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
    state = {...state}..remove(s);
  }
}

void main() {
  showGeneratedBoolNotifierProviderExamples();
  showGeneratedFunctionProviderExamples();
  showGeneratedSetNotifierProviderExamples();
}
