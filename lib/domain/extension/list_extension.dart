/// Convenience helpers for [List].
extension ListExtension<E> on List<E> {
  /// Inserts [element] at the beginning of this list.
  void prepend(E element) {
    insert(0, element);
  }
}
