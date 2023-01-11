import 'dart:ui';

import 'package:flutter_drawing_board/paint_contents.dart';
import 'package:stack_board/src/core/stack_board_item/stack_item.dart';
import 'package:stack_board/src/core/stack_board_item/stack_item_content.dart';
import 'package:stack_board/src/core/stack_board_item/stack_item_status.dart';

import 'package:widget_style_extension/widget_style_extension.dart';

class DrawItemContent implements StackItemContent {
  DrawItemContent({
    required this.size,
    required this.paintContents,
  });

  factory DrawItemContent.fromJson(
    Map<String, dynamic> data, {
    PaintContent Function(String type, Map<String, dynamic> jsonStepMap)? contentFactory,
  }) {
    return DrawItemContent(
      size: data['size'] as double,
      paintContents: (data['paintContents'] as List<dynamic>).map((dynamic e) {
        final String type = e['type'] as String;

        final Map<String, dynamic> contentJson = e as Map<String, dynamic>;

        switch (type) {
          case 'Circle':
            return Circle.fromJson(contentJson);
          case 'Eraser':
            return Eraser.fromJson(contentJson);
          case 'Rectangle':
            return Rectangle.fromJson(contentJson);
          case 'SimpleLine':
            return SimpleLine.fromJson(contentJson);
          case 'SmoothLine':
            return SmoothLine.fromJson(contentJson);
          case 'StraightLine':
            return StraightLine.fromJson(contentJson);
        }

        return contentFactory?.call(type, contentJson) ?? EmptyContent.fromJson(contentJson);
      }).toList(),
    );
  }

  final double size;
  final List<PaintContent> paintContents;

  DrawItemContent copyWith({
    double? size,
    List<PaintContent>? paintContents,
  }) {
    return DrawItemContent(
      size: size ?? this.size,
      paintContents: paintContents ?? this.paintContents,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'size': size,
      'paintContents': paintContents.map((PaintContent e) => e.toJson()).toList(),
    };
  }
}

/// StackDrawItem
class StackDrawItem extends StackItem<DrawItemContent> {
  StackDrawItem({
    DrawItemContent? content,
    String? id,
    double? angle,
    Size size = const Size(300, 300),
    Offset? offset,
    StackItemStatus? status,
  }) : super(
          id: id,
          size: size,
          offset: offset,
          angle: angle,
          status: status,
          content: content,
        );

  factory StackDrawItem.fromJson(Map<String, dynamic> data) {
    return StackDrawItem(
      id: data['id'] as String?,
      angle: data['angle'] as double?,
      size: jsonToSize(data['size'] as Map<String, dynamic>),
      offset: jsonToOffset(data['offset'] as Map<String, dynamic>),
      status: StackItemStatus.values[data['status'] as int],
      content: DrawItemContent.fromJson(data['content'] as Map<String, dynamic>),
    );
  }

  @override
  StackDrawItem copyWith({
    Size? size,
    Offset? offset,
    double? angle,
    StackItemStatus? status,
    DrawItemContent? content,
  }) {
    return StackDrawItem(
      id: id,
      size: size ?? this.size ?? const Size(300, 300),
      offset: offset ?? this.offset,
      angle: angle ?? this.angle,
      status: status ?? this.status,
      content: content ?? this.content,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'type': 'StackDrawItem',
      if (angle != null) 'angle': angle,
      if (size != null) 'size': size?.toJson(),
      if (offset != null) 'offset': offset?.toJson(),
      if (status != null) 'status': status?.index,
      if (content != null) 'content': content?.toJson(),
    };
  }
}
