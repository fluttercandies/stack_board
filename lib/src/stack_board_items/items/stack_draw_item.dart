import 'dart:ui';

import 'package:flutter_drawing_board/paint_contents.dart';
import 'package:stack_board/src/core/stack_board_item/stack_item.dart';
import 'package:stack_board/src/core/stack_board_item/stack_item_content.dart';
import 'package:stack_board/src/core/stack_board_item/stack_item_status.dart';
import 'package:stack_board/src/widget_style_extension/ex_offset.dart';
import 'package:stack_board/src/widget_style_extension/ex_size.dart';

import '../../../helpers.dart';

class DrawItemContent implements StackItemContent {
  DrawItemContent({
    required this.size,
    required this.paintContents,
  });

  factory DrawItemContent.fromJson(
    Map<String, dynamic> data, {
    PaintContent Function(String type, Map<String, dynamic> jsonStepMap)?
        contentFactory,
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

        return contentFactory?.call(type, contentJson) ??
            EmptyContent.fromJson(contentJson);
      }).toList(),
    );
  }

  double size;
  List<PaintContent> paintContents;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'size': size,
      'paintContents':
          paintContents.map((PaintContent e) => e.toJson()).toList(),
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
    bool? lockZOrder,
    StackItemStatus? status,
    bool? allowChildReciveGestures,
    bool? tightContent,
    required this.isHardLocked,
  }) : super(
            id: id,
            size: size,
            offset: offset,
            angle: angle,
            status: status,
            lockZOrder: lockZOrder,
            allowChildReciveGestures: allowChildReciveGestures,
            tightContent: tightContent,
            content: content ??
                DrawItemContent(
                    size: size.shortestSide, paintContents: <PaintContent>[]));

  factory StackDrawItem.fromJson(Map<String, dynamic> data) {
    return StackDrawItem(
      id: data['id'] as String?,
      angle: data['angle'] as double?,
      size: jsonToSize(data['size'] as Map<String, dynamic>),
      offset: jsonToOffset(data['offset'] as Map<String, dynamic>),
      status: StackItemStatus.values[data['status'] as int],
      lockZOrder: asNullT<bool>(data['lockZOrder']) ?? false,
      allowChildReciveGestures: asNullT<bool>(data['allowChildReciveGestures']),
      tightContent: asNullT<bool>(data['tightContent']),
      content:
          DrawItemContent.fromJson(data['content'] as Map<String, dynamic>),
      isHardLocked: asNullT<bool>(data['isHardLocked']) ?? false,
    );
  }

  ///Decide Weather allowed tro move , delete or rezize or select the item
  final bool isHardLocked;

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = super.toJson();
    json['isHardLocked'] = isHardLocked;
    return json;
  }

  /// * 覆盖绘制内容
  /// * Override the drawing content
  void setContents(List<PaintContent> contents) {
    content!.paintContents = contents;
  }

  @override
  StackDrawItem copyWith({
    Size? size,
    Offset? offset,
    double? angle,
    StackItemStatus? status,
    bool? lockZOrder,
    DrawItemContent? content,
    bool? allowChildReciveGestures,
    bool? tightContent,
  }) {
    return StackDrawItem(
        id: id,
        size: size ?? this.size,
        offset: offset ?? this.offset,
        angle: angle ?? this.angle,
        status: status ?? this.status,
        lockZOrder: lockZOrder ?? this.lockZOrder,
        content: content ?? this.content,
        allowChildReciveGestures:
            allowChildReciveGestures ?? this.allowChildReciveGestures,
        tightContent: tightContent ?? this.tightContent,
        isHardLocked: isHardLocked);
  }
}
