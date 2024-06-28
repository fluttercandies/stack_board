import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stack_board/stack_items.dart';

void main() {
  test('Stack Text Item should save lockZorder to json', () {
    final StackTextItem item = StackTextItem(
        content: TextItemContent(),
        size: const Size(100, 100),
        lockZOrder: true);
    expect(item.toJson()['lockZOrder'], true);
  });

  test('Stack Text Item should restore lockZorder from json', () {
    final StackTextItem item = StackTextItem.fromJson(const <String, dynamic>{
      'id': 'id',
      'size': <String, dynamic>{'width': 100, 'height': 100},
      'content': <String, dynamic>{'text': 'text'},
      'lockZOrder': true,
      'offset': <String, dynamic>{'dx': 0, 'dy': 0},
      'status': 0,
    });
    expect(item.lockZOrder, true);
  });
}
