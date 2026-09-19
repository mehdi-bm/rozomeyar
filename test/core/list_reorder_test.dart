import 'package:flutter_test/flutter_test.dart';
import 'package:resumeyar/core/utils/list_reorder.dart';

void main() {
  const items = <String>['a', 'b', 'c', 'd'];

  test('moves an item downwards', () {
    expect(reordered(items, 0, 2), <String>['b', 'c', 'a', 'd']);
  });

  test('moves an item upwards', () {
    expect(reordered(items, 3, 0), <String>['d', 'a', 'b', 'c']);
  });

  test('moving to the same index changes nothing', () {
    expect(reordered(items, 1, 1), items);
  });

  test('moving to the end works', () {
    expect(reordered(items, 0, 3), <String>['b', 'c', 'd', 'a']);
  });

  test('does not mutate the source list', () {
    final source = List<String>.of(items);
    reordered(source, 0, 2);
    expect(source, items);
  });
}
