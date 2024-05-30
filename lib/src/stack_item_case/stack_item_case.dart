import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:stack_board/src/core/case_style.dart';
import 'package:stack_board/src/core/stack_board_item/stack_item.dart';
import 'package:stack_board/src/core/stack_board_item/stack_item_content.dart';
import 'package:stack_board/src/core/stack_board_item/stack_item_status.dart';
import 'package:stack_board/src/stack_board.dart';
import 'package:stack_board/src/stack_item_case/config_builder.dart';

/// * Operate box
/// * Used to wrap child widgets to provide functions of operate box
/// * 1. Drag
/// * 2. Scale
/// * 3. Resize
/// * 4. Rotate
/// * 5. Select
/// * 6. Edit
/// * 7. Delete (white in edit status)
class StackItemCase extends StatefulWidget {
  const StackItemCase({
    Key? key,
    required this.stackItem,
    required this.childBuilder,
    this.caseStyle,
    this.onDel,
    this.onTap,
    this.onSizeChanged,
    this.onOffsetChanged,
    this.onAngleChanged,
    this.onStatusChanged,
    this.actionsBuilder,
    this.borderBuilder,
  }) : super(key: key);

  /// * StackItemData
  final StackItem<StackItemContent> stackItem;

  /// * 子组件构建器, 当item状态改变时更新
  /// * Child builder, update when item status changed
  final Widget? Function(StackItem<StackItemContent> item)? childBuilder;

  /// * 外框样式
  /// * Outer frame style
  final CaseStyle? caseStyle;

  /// * 移除拦截
  /// * Remove intercept
  final void Function()? onDel;

  /// * 点击回调
  /// * Click callback
  final void Function()? onTap;

  /// * 尺寸变化回调
  /// * 返回值可控制是否继续进行
  /// * Size change callback
  /// * The return value can control whether to continue
  final bool? Function(Size size)? onSizeChanged;

  /// * 位置变化回调
  /// * 返回值可控制是否继续进行
  /// * Position change callback
  /// * The return value can control whether to continue
  final bool? Function(Offset offset)? onOffsetChanged;

  /// * 角度变化回调
  /// * 返回值可控制是否继续进行
  /// * Angle change callback
  /// * The return value can control whether to continue
  final bool? Function(double angle)? onAngleChanged;

  /// * 操作状态回调
  /// * 返回值可控制是否继续进行
  /// * Operation status callback
  /// * The return value can control whether to continue
  final bool? Function(StackItemStatus operatState)? onStatusChanged;

  /// * 操作层构建器
  /// * Operation layer builder
  final Widget Function(StackItemStatus operatState, CaseStyle caseStyle)?
      actionsBuilder;

  /// * 边框构建器
  /// * Border builder
  final Widget Function(StackItemStatus operatState)? borderBuilder;

  @override
  State<StatefulWidget> createState() {
    return _StackItemCaseState();
  }
}

class _StackItemCaseState extends State<StackItemCase> {
  Offset centerPoint = Offset.zero;
  Offset startGlobalPoint = Offset.zero;
  Offset startOffset = Offset.zero;
  Size startSize = Size.zero;
  double startAngle = 0;

  String get itemId => widget.stackItem.id;

  StackBoardController _controller(BuildContext context) =>
      StackBoardConfig.of(context).controller;

  /// * 外框样式
  /// * Outer frame style
  CaseStyle _caseStyle(BuildContext context) =>
      widget.caseStyle ??
      StackBoardConfig.of(context).caseStyle ??
      const CaseStyle();

  double _minSize(BuildContext context) => _caseStyle(context).buttonSize * 2;

  /// * 主体鼠标指针样式
  /// * Main body mouse pointer style
  MouseCursor _cursor(StackItemStatus status) {
    if (status == StackItemStatus.moving) {
      return SystemMouseCursors.grabbing;
    } else if (status == StackItemStatus.editing) {
      return SystemMouseCursors.click;
    }

    return SystemMouseCursors.grab;
  }

  /// * 点击
  /// * Click
  void _onTap(BuildContext context) {
    widget.onTap?.call();
    _controller(context).selectOne(itemId);
    widget.onStatusChanged?.call(StackItemStatus.selected);
  }

  /// * 点击编辑
  /// * Click edit
  void _onEdit(BuildContext context, StackItemStatus status) {
    if (status == StackItemStatus.editing) return;

    final StackBoardController _stackController = _controller(context);
    status = StackItemStatus.editing;
    _stackController.selectOne(itemId);
    _stackController.updateBasic(itemId, status: status);
    widget.onStatusChanged?.call(status);
  }

  void _onPanStart(DragStartDetails details, BuildContext context,
      StackItemStatus newStatus) {
    final StackBoardController _stackController = _controller(context);
    final StackItem<StackItemContent>? item = _stackController.getById(itemId);
    if (item == null) return;

    if (item.status != newStatus) {
      if (item.status == StackItemStatus.editing) return;
      if (item.status != StackItemStatus.selected)
        _stackController.selectOne(itemId);
      _stackController.updateBasic(itemId, status: newStatus);
      _stackController.moveItemOnTop(itemId);
      widget.onStatusChanged?.call(newStatus);
    }

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    centerPoint = renderBox.localToGlobal(Offset.zero);
    startGlobalPoint = details.globalPosition;
    startOffset = item.offset;
    startSize = item.size;
    startAngle = item.angle;
  }

  /// * 拖拽结束
  /// * Drag end
  void _onPanEnd(BuildContext context, StackItemStatus status) {
    if (status != StackItemStatus.selected) {
      if (status == StackItemStatus.editing) return;
      status = StackItemStatus.selected;
      _controller(context).updateBasic(itemId, status: status);
      widget.onStatusChanged?.call(status);
    }
  }

  /// * 移动操作
  /// * Move operation
  void _onPanUpdate(DragUpdateDetails dud, BuildContext context) {
    final StackBoardController _stackController = _controller(context);

    final StackItem<StackItemContent>? item = _stackController.getById(itemId);
    if (item == null) return;
    if (item.status == StackItemStatus.editing) return;

    final double angle = item.angle;
    final double sina = math.sin(-angle);
    final double cosa = math.cos(-angle);

    Offset d = dud.delta;
    final Offset changeTo = item.offset.translate(d.dx, d.dy);

    // 向量旋转
    d = Offset(sina * d.dy + cosa * d.dx, cosa * d.dy - sina * d.dx);

    final Offset realOffset = item.offset.translate(d.dx, d.dy);

    // 移动拦截
    if (!(widget.onOffsetChanged?.call(realOffset) ?? true)) return;

    _stackController.updateBasic(itemId, offset: realOffset);

    widget.onOffsetChanged?.call(changeTo);
  }

  static double _caculateDistance(Offset p1, Offset p2) {
    return sqrt(
      (p1.dx - p2.dx) * (p1.dx - p2.dx) + (p1.dy - p2.dy) * (p1.dy - p2.dy),
    );
  }

  /// * Calculate the item size based on the cursor position
  Size _calculateNewSize(DragUpdateDetails dud, BuildContext context,
      final StackItemStatus status) {
    final StackBoardController _stackController = _controller(context);

    final StackItem<StackItemContent>? item = _stackController.getById(itemId);
    if (item == null) return Size.zero;

    final double minSize = _minSize(context);

    final double originalDistance =
        _caculateDistance(startGlobalPoint, startOffset);
    final double newDistance =
        _caculateDistance(dud.globalPosition, startOffset);
    final double scale = newDistance / originalDistance;

    final double w = startSize.width * scale;
    final double h = startSize.height * scale;

    if (w < minSize || h < minSize) return item.size;

    return Size(w, h);
  }

  /// * 缩放操作
  /// * Scale operation
  void _onScaleUpdate(
      DragUpdateDetails dud, BuildContext context, StackItemStatus status) {
    final Size s = _calculateNewSize(dud, context, status);

    //缩放拦截
    if (!(widget.onSizeChanged?.call(s) ?? true)) return;

    _controller(context).updateBasic(itemId, size: s);
  }

  /// * Horizontal resize operation
  void _onResizeXUpdate(
      DragUpdateDetails dud, BuildContext context, StackItemStatus status) {
    final Size newSize = _calculateNewSize(dud, context, status);
    final Size s = Size(newSize.width, startSize.height);

    //缩放拦截
    if (!(widget.onSizeChanged?.call(s) ?? true)) return;

    _controller(context).updateBasic(itemId, size: s);
  }

  /// * Vertical resize operation
  void _onResizeYUpdate(
      DragUpdateDetails dud, BuildContext context, StackItemStatus status) {
    final Size newSize = _calculateNewSize(dud, context, status);
    final Size s = Size(startSize.width, newSize.height);

    //缩放拦截
    if (!(widget.onSizeChanged?.call(s) ?? true)) return;

    _controller(context).updateBasic(itemId, size: s);
  }

  /// * 旋转操作
  /// * Rotate operation
  void _onRotateUpdate(
      DragUpdateDetails dud, BuildContext context, StackItemStatus status) {
    final double startToCenterX = startGlobalPoint.dx - centerPoint.dx;
    final double startToCenterY = startGlobalPoint.dy - centerPoint.dy;
    final double endToCenterX = dud.globalPosition.dx - centerPoint.dx;
    final double endToCenterY = dud.globalPosition.dy - centerPoint.dy;
    final double direct =
        startToCenterX * endToCenterY - startToCenterY * endToCenterX;
    final double startToCenter = sqrt(
        pow(centerPoint.dx - startGlobalPoint.dx, 2) +
            pow(centerPoint.dy - startGlobalPoint.dy, 2));
    final double endToCenter = sqrt(
        pow(centerPoint.dx - dud.globalPosition.dx, 2) +
            pow(centerPoint.dy - dud.globalPosition.dy, 2));
    final double startToEnd = sqrt(
        pow(startGlobalPoint.dx - dud.globalPosition.dx, 2) +
            pow(startGlobalPoint.dy - dud.globalPosition.dy, 2));
    final double cosA =
        (pow(startToCenter, 2) + pow(endToCenter, 2) - pow(startToEnd, 2)) /
            (2 * startToCenter * endToCenter);
    double angle = acos(cosA);
    if (direct < 0) {
      angle = startAngle - angle;
    } else {
      angle = startAngle + angle;
    }

    //旋转拦截
    if (!(widget.onAngleChanged?.call(angle) ?? true)) return;

    _controller(context).updateBasic(itemId, angle: angle);
  }

  @override
  Widget build(BuildContext context) {
    return ConfigBuilder.withItem(
      itemId,
      shouldRebuild:
          (StackItem<StackItemContent> p, StackItem<StackItemContent> n) =>
              p.offset != n.offset ||
              p.angle != n.angle ||
              p.size != n.size ||
              p.status != n.status,
      childBuilder: (StackItem<StackItemContent> item, Widget c) {
        return Positioned(
          key: ValueKey<String>(item.id),
          top: item.offset.dy,
          left: item.offset.dx,
          child: Transform.translate(
            offset: Offset(
                -item.size.width / 2 -
                    (item.status != StackItemStatus.idle
                        ? _caseStyle(context).buttonSize / 2
                        : 0),
                -item.size.height / 2 -
                    (item.status != StackItemStatus.idle
                        ? _caseStyle(context).buttonSize * 1.5
                        : 0)),
            child: Transform.rotate(angle: item.angle, child: c),
          ),
        );
      },
      child: ConfigBuilder.withItem(
        itemId,
        shouldRebuild:
            (StackItem<StackItemContent> p, StackItem<StackItemContent> n) =>
                p.status != n.status,
        childBuilder: (StackItem<StackItemContent> item, Widget c) {
          return MouseRegion(
            cursor: _cursor(item.status),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (DragStartDetails details) =>
                  _onPanStart(details, context, StackItemStatus.moving),
              onPanUpdate: (DragUpdateDetails dud) =>
                  _onPanUpdate(dud, context),
              onPanEnd: (_) => _onPanEnd(context, item.status),
              onTap: () => _onTap(context),
              onDoubleTap: () => _onEdit(context, item.status),
              child: _childrenStack(context, item),
            ),
          );
        },
        child: const SizedBox.shrink(),
      ),
    );
  }

  Widget _childrenStack(
      BuildContext context, StackItem<StackItemContent> item) {
    final CaseStyle style = _caseStyle(context);

    final List<Widget> widgets = <Widget>[_content(context, item)];

    widgets.add(widget.borderBuilder?.call(item.status) ??
        _frameBorder(context, item.status));
    if (widget.actionsBuilder != null) {
      widgets.add(widget.actionsBuilder!(item.status, _caseStyle(context)));
    } else if (item.status != StackItemStatus.editing) {
      if (item.status != StackItemStatus.idle) {
        if (item.size.height > _minSize(context) * 2) {
          widgets.add(Positioned(
              bottom: style.buttonSize,
              right: 0,
              top: style.buttonSize,
              child: _resizeXHandle(context, item.status)));
          widgets.add(Positioned(
              bottom: style.buttonSize,
              left: 0,
              top: style.buttonSize,
              child: _resizeXHandle(context, item.status)));
        }
        if (item.size.width > _minSize(context) * 2) {
          widgets.add(Positioned(
              left: 0,
              top: style.buttonSize,
              right: 0,
              child: _resizeYHandle(context, item.status)));
          widgets.add(Positioned(
              left: 0,
              bottom: style.buttonSize,
              right: 0,
              child: _resizeYHandle(context, item.status)));
        }
        if (item.size.height > _minSize(context) &&
            item.size.width > _minSize(context)) {
          widgets.add(Positioned(
              top: style.buttonSize,
              right: 0,
              child: _scaleHandle(context, item.status,
                  SystemMouseCursors.resizeUpRightDownLeft)));
          widgets.add(Positioned(
              bottom: style.buttonSize,
              left: 0,
              child: _scaleHandle(context, item.status,
                  SystemMouseCursors.resizeUpRightDownLeft)));
        }
        widgets.addAll(<Widget>[
          if (item.status == StackItemStatus.editing)
            _deleteHandle(context)
          else
            _rotateAndMoveHandle(context, item.status, item),
          Positioned(
              top: style.buttonSize,
              left: 0,
              child: _scaleHandle(context, item.status,
                  SystemMouseCursors.resizeUpLeftDownRight)),
          Positioned(
              bottom: style.buttonSize,
              right: 0,
              child: _scaleHandle(context, item.status,
                  SystemMouseCursors.resizeUpLeftDownRight)),
        ]);
      }
    } else {
      widgets.add(_deleteHandle(context));
    }
    return Stack(children: widgets);
  }

  /// * 子组件
  /// * Child component
  Widget _content(BuildContext context, StackItem<StackItemContent> item) {
    final CaseStyle style = _caseStyle(context);

    final Widget content =
        widget.childBuilder?.call(item) ?? const SizedBox.shrink();

    return ConfigBuilder.withItem(
      itemId,
      shouldRebuild:
          (StackItem<StackItemContent> p, StackItem<StackItemContent> n) =>
              p.size != n.size || p.status != n.status,
      childBuilder: (StackItem<StackItemContent> item, Widget c) {
        return Padding(
            padding: item.status == StackItemStatus.idle
                ? EdgeInsets.zero
                : EdgeInsets.fromLTRB(
                    style.buttonSize / 2,
                    style.buttonSize * 1.5,
                    style.buttonSize / 2,
                    style.buttonSize * 1.5),
            child: SizedBox.fromSize(size: item.size, child: c));
      },
      child: content,
    );
  }

  /// * 边框
  /// * Border
  Widget _frameBorder(BuildContext context, StackItemStatus status) {
    final CaseStyle style = _caseStyle(context);

    return Positioned(
        top: style.buttonSize * 1.5,
        bottom: style.buttonSize * 1.5,
        left: style.buttonSize / 2,
        right: style.buttonSize / 2,
        child: IgnorePointer(
          ignoring: true,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: status == StackItemStatus.idle
                    ? Colors.transparent
                    : style.frameBorderColor,
                width: style.frameBorderWidth,
              ),
            ),
          ),
        ));
  }

  /// * 删除手柄
  /// * Delete handle
  Widget _deleteHandle(BuildContext context) {
    final CaseStyle style = _caseStyle(context);

    return Positioned(
      left: 0,
      bottom: 0,
      right: 0,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => widget.onDel?.call(),
          child: _toolCase(context, style, const Icon(Icons.delete)),
        ),
      ),
    );
  }

  /// * 缩放手柄
  /// * Scale handle
  Widget _scaleHandle(
      BuildContext context, StackItemStatus status, MouseCursor cursor) {
    final CaseStyle style = _caseStyle(context);

    return MouseRegion(
      cursor: cursor,
      child: GestureDetector(
        onPanStart: (DragStartDetails dud) =>
            _onPanStart(dud, context, StackItemStatus.scaling),
        onPanUpdate: (DragUpdateDetails dud) =>
            _onScaleUpdate(dud, context, status),
        onPanEnd: (_) => _onPanEnd(context, status),
        child: _toolCase(
          context,
          style,
          null,
        ),
      ),
    );
  }

  /// * Resize handle
  Widget _resizeHandle(
      BuildContext context,
      StackItemStatus status,
      double width,
      double height,
      MouseCursor cursor,
      Function(DragUpdateDetails, BuildContext, StackItemStatus) onPanUpdate) {
    final CaseStyle style = _caseStyle(context);
    return Center(
      child: MouseRegion(
        cursor: cursor,
        child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (DragStartDetails dud) =>
                _onPanStart(dud, context, StackItemStatus.resizing),
            onPanUpdate: (DragUpdateDetails dud) =>
                onPanUpdate(dud, context, status),
            onPanEnd: (_) => _onPanEnd(context, status),
            child: Container(
                width: width * 3,
                height: height * 3,
                child: Center(
                  child: Container(
                    width: width,
                    height: height,
                    decoration: BoxDecoration(
                      color: style.buttonBgColor,
                      border: Border.all(
                          width: style.buttonBorderWidth,
                          color: style.buttonBorderColor),
                      borderRadius: BorderRadius.circular(style.buttonSize),
                    ),
                  ),
                ))),
      ),
    );
  }

  /// * 旋转手柄
  /// * Resize X handle
  Widget _resizeXHandle(BuildContext context, StackItemStatus status) {
    final CaseStyle style = _caseStyle(context);
    return _resizeHandle(context, status, style.buttonSize / 3,
        style.buttonSize, SystemMouseCursors.resizeColumn, _onResizeXUpdate);
  }

  /// * 旋转手柄
  /// * Resize Y handle
  Widget _resizeYHandle(BuildContext context, StackItemStatus status) {
    final CaseStyle style = _caseStyle(context);
    return _resizeHandle(context, status, style.buttonSize,
        style.buttonSize / 3, SystemMouseCursors.resizeRow, _onResizeYUpdate);
  }

  /// * 旋转手柄
  /// * Rotate handle
  Widget _rotateAndMoveHandle(BuildContext context, StackItemStatus status,
      StackItem<StackItemContent> item) {
    final CaseStyle style = _caseStyle(context);

    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          GestureDetector(
            onPanStart: (DragStartDetails dud) =>
                _onPanStart(dud, context, StackItemStatus.roating),
            onPanUpdate: (DragUpdateDetails dud) =>
                _onRotateUpdate(dud, context, status),
            onPanEnd: (_) => _onPanEnd(context, status),
            child: _toolCase(
              context,
              style,
              const Icon(Icons.sync),
            ),
          ),
          if (item.size.width + item.size.height < style.buttonSize * 6)
            Padding(
              padding: EdgeInsets.only(left: style.buttonSize / 2),
              child: GestureDetector(
                onPanStart: (DragStartDetails details) =>
                    _onPanStart(details, context, StackItemStatus.moving),
                onPanUpdate: (DragUpdateDetails dud) =>
                    _onPanUpdate(dud, context),
                onPanEnd: (_) => _onPanEnd(context, status),
                child: _toolCase(context, style, const Icon(Icons.open_with)),
              ),
            )
        ]),
      ),
    );
  }

  /// * 操作手柄壳
  /// * Operation handle shell
  Widget _toolCase(BuildContext context, CaseStyle style, Widget? child) {
    return Container(
      width: style.buttonSize,
      height: style.buttonSize,
      child: child == null
          ? null
          : IconTheme(
              data: Theme.of(context).iconTheme.copyWith(
                    color: style.buttonIconColor,
                    size: style.buttonSize * 0.6,
                  ),
              child: child,
            ),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: style.buttonBgColor,
          border: Border.all(
              width: style.buttonBorderWidth, color: style.buttonBorderColor)),
    );
  }

  /// * 工具栏
  /// * Toolbar
  // Widget _tools(BuildContext context) {
  //   final CaseStyle style = _caseStyle(context);

  //   return Positioned(
  //     left: style.iconSize / 2,
  //     top: style.iconSize / 2,
  //     right: style.iconSize / 2,
  //     bottom: style.iconSize / 2,
  //     child: tools!,
  //   );
  // }
}
