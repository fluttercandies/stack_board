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
    this.size,
    Offset? offset,
    double? angle = 0,
    StackItemStatus? status = StackItemStatus.selected,
    this.content,
  })  : id = id ?? _genId(),
        offset = offset ?? Offset.zero,
        angle = angle ?? 0,
        status = status ?? StackItemStatus.selected;

  const StackItem.empty({
    required this.size,
    required this.offset,
    required this.angle,
    required this.status,
    required this.content,
  }) : id = '';

  /// id
  final String id;

  /// Size
  final Size? size;

  /// Offset
  final Offset? offset;

  /// Angle
  final double? angle;

  /// Status
  final StackItemStatus? status;

  /// Content
  final T? content;

  /// Update content and return new instance
  StackItem<T> copyWith({
    Size? size,
    Offset? offset,
    double? angle,
    StackItemStatus? status,
    T? content,
  });

  /// to json
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'type': runtimeType.toString(),
      if (angle != null) 'angle': angle,
      if (size != null) 'size': size?.toJson(),
      if (offset != null) 'offset': offset?.toJson(),
      if (status != null) 'status': status?.index,
      if (content != null) 'content': content?.toJson(),
    };
  }

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) => other is StackItem && id == other.id;
}
