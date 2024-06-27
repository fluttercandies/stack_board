import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stack_board/stack_items.dart';

main() {
  test('Stack Text Item should save lockZorder to json', () {
    final item = StackTextItem(
        content: TextItemContent(),
        size: Size(100, 100),
        lockZOrder: true);
    expect(item.toJson()['lockZOrder'], true);
  });

  test('Stack Text Item should restore lockZorder from json', () {
    final item = StackTextItem.fromJson({
      'id': 'id',
      'size': {'width': 100, 'height': 100},
      'content': {'text': 'text'},
      'lockZOrder': true,
      'offset': {'dx': 0, 'dy': 0},
      'status': 0,
    });
    expect(item.lockZOrder, true);
  });

}