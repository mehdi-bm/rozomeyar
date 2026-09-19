/// Applies a `ReorderableListView.onReorderItem` move to a list.
///
/// Unlike the deprecated `onReorder`, `onReorderItem` already accounts for the
/// item being removed before reinsertion, so `newIndex` is used as given.
List<T> reordered<T>(List<T> items, int oldIndex, int newIndex) {
  final copy = List<T>.of(items);
  final item = copy.removeAt(oldIndex);
  copy.insert(newIndex, item);
  return copy;
}
