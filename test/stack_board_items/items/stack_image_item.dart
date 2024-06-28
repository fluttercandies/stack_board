import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stack_board/stack_items.dart';

void main() {
  test('Stack Image Item should save lockZorder to json', () {
    final item = StackImageItem(
        content: ImageItemContent(url: 'http://a.b.c'),
        size: Size(100, 100),
        lockZOrder: true);
    expect(item.toJson()['lockZOrder'], true);
  });

  test('Stack Image Item should restore lockZorder from json', () {
    final item = StackImageItem.fromJson({
      'id': 'id',
      'size': {'width': 100, 'height': 100},
      'content': {'url': 'http://a.b.c'},
      'lockZOrder': true,
      'status': 0,
    });
    expect(item.lockZOrder, true);
  });
}
