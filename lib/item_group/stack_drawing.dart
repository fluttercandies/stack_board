import 'package:flutter/material.dart';
import 'package:stack_board/helper/case_style.dart';

import 'stack_board_item.dart';

///画板
class StackDrawing extends StackBoardItem {
  const StackDrawing({
    this.size = const Size(120, 120),
    Widget background = const SizedBox(width: 200, height: 200),
    final int? id,
    final Future<bool> Function()? onDel,
    CaseStyle? caseStyle,
  }) : super(
          id: id,
          onDel: onDel,
          child: background,
          caseStyle: caseStyle,
        );

  final Size size;

  @override
  StackDrawing copyWith({
    int? id,
    Widget? child,
    Function(bool)? onEdit,
    Future<bool> Function()? onDel,
    CaseStyle? caseStyle,
    Size? size,
  }) {
    return StackDrawing(
      background: child ?? this.child,
      id: id ?? this.id,
      onDel: onDel ?? this.onDel,
      caseStyle: caseStyle ?? this.caseStyle,
      size: size ?? this.size,
    );
  }
}
