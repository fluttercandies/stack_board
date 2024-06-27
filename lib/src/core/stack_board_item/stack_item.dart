import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:stack_board/src/widget_style_extension/ex_offset.dart';
import 'package:stack_board/src/widget_style_extension/ex_size.dart';

import 'stack_item_content.dart';
import 'stack_item_status.dart';

/// * 生成 StackItem id
/// * Generate Id for StackItem
String _genId() {
  final DateTime now = DateTime.now();
  final int value = Random().nextInt(100000);
  return '$value-${now.millisecondsSinceEpoch}';
}

/// * 布局数据核心类
/// * 自定义需要继承此类
/// * Core class for layout data
/// * Custom needs to inherit this class
@immutable
abstract class StackItem<T extends StackItemContent> {
  StackItem({
    String? id,
    required this.size,
    Offset? offset,
    double? angle = 0,
    StackItemStatus? status = StackItemStatus.selected,
    bool? lockZOrder = false,
    this.content,
  })  : id = id ?? _genId(),
        offset = offset ?? Offset.zero,
        angle = angle ?? 0,
        lockZOrder = lockZOrder ?? false,
        status = status ?? StackItemStatus.selected;

  const StackItem.empty({
    required this.size,
    required this.offset,
    required this.angle,
    required this.status,
    required this.content,
    required this.lockZOrder,
  }) : id = '';

  /// id
  final String id;

  /// Size
  final Size size;

  /// Offset
  final Offset offset;

  /// Angle
  final double angle;

  /// Status
  final StackItemStatus status;

  final bool lockZOrder;

  /// Content
  final T? content;

  /// Update content and return new instance
  StackItem<T> copyWith({
    Size? size,
    Offset? offset,
    double? angle,
    StackItemStatus? status,
    bool? lockZOrder,
    T? content,
  });

  /// to json
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'type': runtimeType.toString(),
      'angle': angle,
      'size': size.toJson(),
      'offset': offset.toJson(),
      'status': status.index,
      'lockZOrder': lockZOrder,
      if (content != null) 'content': content?.toJson(),
    };
  }

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) => other is StackItem && id == other.id;
}
