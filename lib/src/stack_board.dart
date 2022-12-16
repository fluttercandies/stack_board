import 'package:flutter/material.dart';
import 'package:stack_board/src/core/stack_board_controller.dart';
import 'package:stack_board/src/stack_item_case/stack_item_case.dart';
import 'package:stack_board/src/widgets/ex_builder.dart';
import 'package:stack_board_item/stack_board_item.dart';

import 'core/case_style.dart';

class StackBoardConfig extends InheritedWidget {
  const StackBoardConfig({
    Key? key,
    required this.controller,
    this.caseStyle,
    required Widget child,
  }) : super(key: key, child: child);

  final StackBoardController controller;
  final CaseStyle? caseStyle;

  static StackBoardConfig of(BuildContext context) {
    final StackBoardConfig? result = context.dependOnInheritedWidgetOfExactType<StackBoardConfig>();
    assert(result != null, 'No StackBoardConfig found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant StackBoardConfig oldWidget) =>
      oldWidget.controller != controller || oldWidget.caseStyle != caseStyle;
}

/// StackBoard
class StackBoard extends StatelessWidget {
  const StackBoard({
    Key? key,
    this.controller,
    this.background,
    this.caseStyle,
    this.childBuilder,
    this.onDel,
    this.onTap,
    this.onSizeChanged,
    this.onOffsetChanged,
    this.onAngleChanged,
    this.onEditStatusChanged,
  }) : super(key: key);

  final StackBoardController? controller;

  /// 背景
  final Widget? background;

  /// 操作框样式
  final CaseStyle? caseStyle;

  /// 自定义类型控件构建器
  final Widget? Function(StackItem<StackItemContent> item)? childBuilder;

  /// 移除拦截
  final void Function(StackItem<StackItemContent> item)? onDel;

  /// 点击回调
  final void Function(StackItem<StackItemContent> item)? onTap;

  /// 尺寸变化回调
  /// 返回值可控制是否继续进行
  final bool? Function(StackItem<StackItemContent> item, Size size)? onSizeChanged;

  /// 位置变化回调
  final bool? Function(StackItem<StackItemContent> item, Offset offset)? onOffsetChanged;

  /// 角度变化回调
  final bool? Function(StackItem<StackItemContent> item, double angle)? onAngleChanged;

  /// 操作状态回调
  final bool? Function(StackItem<StackItemContent> item, StackItemStatus operatState)? onEditStatusChanged;

  StackBoardController get _controller => controller ?? StackBoardController.def();

  @override
  Widget build(BuildContext context) {
    return StackBoardConfig(
      controller: _controller,
      caseStyle: caseStyle,
      child: GestureDetector(
        onTap: () => _controller.unSelectAll(),
        behavior: HitTestBehavior.opaque,
        child: ExBuilder<StackConfig>(
          valueListenable: _controller,
          shouldRebuild: (StackConfig p, StackConfig n) => p.data.length != n.data.length,
          builder: (StackConfig sc) {
            return Stack(
              fit: StackFit.expand,
              children: <Widget>[
                const SizedBox.expand(),
                if (background != null) background!,
                for (int i = 0; i < sc.data.length; i++) _itemBuilder(context, sc.data[i], i),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, StackItem<StackItemContent> item, int i) {
    return StackItemCase(
      index: i,
      childBuilder: childBuilder,
      caseStyle: caseStyle,
      onDel: () => onDel?.call(item),
      onTap: () => onTap?.call(item),
      onSizeChanged: (Size size) => onSizeChanged?.call(item, size) ?? true,
      onOffsetChanged: (Offset offset) => onOffsetChanged?.call(item, offset) ?? true,
      onAngleChanged: (double angle) => onAngleChanged?.call(item, angle) ?? true,
      onEditStatusChanged: (StackItemStatus operatState) => onEditStatusChanged?.call(item, operatState) ?? true,
    );
  }
}