import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stack_board/stack_items.dart';

void main() {
  test('Stack Draw Item should save lockZorder to json', () {
    final item = StackDrawItem(
        content: DrawItemContent(size: 100, paintContents: []),
        size: Size(100, 100),
        lockZOrder: true);
    expect(item.toJson()['lockZOrder'], true);
  });

  test('Stack Draw Item should restore lockZorder from json', () {
    final item = StackDrawItem.fromJson({
      'id': 'id',
      'size': {'width': 100, 'height': 100},
      'content': {'size': 100.0, 'paintContents': []},
      'lockZOrder': true,
      'offset': {'dx': 0, 'dy': 0},
      'status': 0,
    });
    expect(item.lockZOrder, true);
  });
}