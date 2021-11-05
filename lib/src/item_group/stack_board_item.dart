import 'package:flutter/material.dart';
import 'package:stack_board/src/helper/case_style.dart';

///自定义对象
@immutable
class StackBoardItem {
  const StackBoardItem({
    required this.child,
    this.id,
    this.onEdit,
    this.onDel,
    this.caseStyle = const CaseStyle(),
  });

  ///item id
  final int? id;

  ///子控件
  final Widget child;

  ///编辑回调
  final Function(bool)? onEdit;

  ///移除回调
  final Future<bool> Function()? onDel;

  ///外框样式
  final CaseStyle? caseStyle;

  ///对象拷贝
  StackBoardItem copyWith({
    int? id,
    Widget? child,
    Function(bool)? onEdit,
    Future<bool> Function()? onDel,
    CaseStyle? caseStyle,
  }) =>
      StackBoardItem(
        id: id ?? this.id,
        child: child ?? this.child,
        onDel: onDel ?? this.onDel,
        onEdit: onEdit ?? this.onEdit,
        caseStyle: caseStyle ?? this.caseStyle,
      );

  ///对象比较
  bool sameWith(StackBoardItem item) => item.id == id;

  @override
  bool operator ==(Object other) => other is StackBoardItem && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
