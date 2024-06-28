import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/paint_contents.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stack_board/stack_items.dart';

void main() {
  test('Stack Draw Item should save lockZorder to json', () {
    final StackDrawItem item = StackDrawItem(
        content: DrawItemContent(size: 100, paintContents: <PaintContent>[]),
        size: const Size(100, 100),
        lockZOrder: true);
    expect(item.toJson()['lockZOrder'], true);
  });

  test('Stack Draw Item should restore lockZorder from json', () {
    final StackDrawItem item = StackDrawItem.fromJson(const <String, dynamic>{
      'id': 'id',
      'size': <String, dynamic>{'width': 100, 'height': 100},
      'content': <String, dynamic>{'size': 100.0, 'paintContents': <dynamic>[]},
      'lockZOrder': true,
      'offset': <String, dynamic>{'dx': 0, 'dy': 0},
      'status': 0,
    });
    expect(item.lockZOrder, true);
  });
}
