# Model-View-ViewModel (MVVM) with Riverpod

Use [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) (with
[riverpod_annotation](https://pub.dev/packages/riverpod_annotation)) to connect
repositories, ViewModels, and views.

| Layer | Depends on Flutter UI libraries? | Throws exceptions? | Catches exceptions? | Notes |
| --- | --- | --- | --- | --- |
| Repository (`@riverpod` / `@Riverpod`) | No | Yes | No | Wraps data sources such as HTTP clients, Firebase, or local storage. |
| ViewModel (`@riverpod` `Notifier` / `AsyncNotifier`) | No (except state/platform types if needed) | No (or exposes via `AsyncValue`) | Yes | Reads repositories via `ref.read(...)`, updates `state`, and checks `ref.mounted` after `await`. |
| View (`ConsumerWidget` / `ConsumerStatefulWidget`) | Yes | No | No | Watches state via `ref.watch(...)` and invokes ViewModel actions via `ref.read(...notifier)`. |

## References

- https://docs.flutter.dev/app-architecture/guide
- https://docs.flutter.dev/get-started/fwe/state-management#using-mvvm-for-your-applications-architecture
- https://riverpod.dev/
