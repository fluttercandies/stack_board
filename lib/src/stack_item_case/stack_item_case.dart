import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:stack_board/src/core/case_style.dart';
import 'package:stack_board/src/core/stack_board_item/stack_item.dart';
import 'package:stack_board/src/core/stack_board_item/stack_item_content.dart';
import 'package:stack_board/src/core/stack_board_item/stack_item_status.dart';
import 'package:stack_board/src/stack_board.dart';
import 'package:stack_board/src/stack_item_case/config_builder.dart';
import 'package:stack_board/src/widgets/get_size.dart';

/// * 操作盒
/// * 用于包裹子组件，提供操作盒的功能
/// * 1. 拖动
/// * 2. 缩放
/// * 3. 旋转
/// * 4. 删除
/// * 5. 点击
/// * 6. 编辑
/// * Operate box
/// * Used to wrap child widgets to provide functions of operate box
/// * 1. Drag
/// * 2. Scale
/// * 3. Rotate
/// * 4. Delete
/// * 5. Click
/// * 6. Edit
class StackItemCase extends StatelessWidget {
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
    this.onEditStatusChanged,
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
  final bool? Function(StackItemStatus operatState)? onEditStatusChanged;

  /// * 操作层构建器
  /// * Operation layer builder
  final Widget Function(StackItemStatus operatState, CaseStyle caseStyle)? actionsBuilder;

  /// * 边框构建器
  /// * Border builder
  final Widget Function(StackItemStatus operatState)? borderBuilder;

  String get itemId => stackItem.id;

  StackBoardController _controller(BuildContext context) => StackBoardConfig.of(context).controller;

  /// * 外框样式
  /// * Outer frame style
  CaseStyle _caseStyle(BuildContext context) =>
      caseStyle ?? StackBoardConfig.of(context).caseStyle ?? const CaseStyle();

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
    onTap?.call();
    _controller(context).selectOne(itemId);
    onEditStatusChanged?.call(StackItemStatus.editing);
  }

  /// * 点击编辑
  /// * Click edit
  void _tapEdit(BuildContext context, final StackItemStatus status) {
    StackItemStatus _status = status;

    if (_status == StackItemStatus.editing) {
      _status = StackItemStatus.selected;
    } else {
      _status = StackItemStatus.editing;
    }

    onEditStatusChanged?.call(_status);
    _controller(context).updateBasic(itemId, status: _status);
  }

  /// * 拖拽结束
  /// * Drag end
  void _onPanEnd(BuildContext context, final StackItemStatus status) {
    StackItemStatus _status = status;

    if (_status != StackItemStatus.selected) {
      _status = StackItemStatus.selected;
      _controller(context).updateBasic(itemId, status: _status);
      onEditStatusChanged?.call(_status);
    }
  }

  /// * 移动操作
  /// * Move operation
  void _onPanUpdate(DragUpdateDetails dud, BuildContext context, final StackItemStatus status) {
    StackItemStatus _status = status;

    final StackBoardController _stackController = _controller(context);

    if (_status == StackItemStatus.idle) {
      _stackController.selectOne(itemId);
      return;
    }

    if (_status != StackItemStatus.moving) {
      _status = StackItemStatus.moving;
      _stackController.updateBasic(itemId, status: _status);
      onEditStatusChanged?.call(_status);
    }

    final StackItem<StackItemContent>? item = _stackController.getById(itemId);
    if (item == null) return;

    final double angle = item.angle ?? 0;
    final double sina = math.sin(-angle);
    final double cosa = math.cos(-angle);

    Offset d = dud.delta;
    final Offset changeTo = item.offset?.translate(d.dx, d.dy) ?? Offset.zero;

    // 向量旋转
    d = Offset(sina * d.dy + cosa * d.dx, cosa * d.dy - sina * d.dx);

    final Offset? realOffset = item.offset?.translate(d.dx, d.dy);
    if (realOffset == null) return;

    // 移动拦截
    if (!(onOffsetChanged?.call(realOffset) ?? true)) return;

    _stackController.updateBasic(itemId, offset: realOffset);

    onOffsetChanged?.call(changeTo);
  }

  /// * 缩放操作
  /// * Scale operation
  void _scaleHandle(DragUpdateDetails dud, BuildContext context, final StackItemStatus status) {
    StackItemStatus _status = status;

    final StackBoardController _stackController = _controller(context);

    _stackController.selectOne(itemId);

    if (_status != StackItemStatus.scaling) {
      if (_status == StackItemStatus.moving || _status == StackItemStatus.roating) {
        _status = StackItemStatus.scaling;
      } else {
        _status = StackItemStatus.scaling;
        _stackController.updateBasic(itemId, status: _status);
      }

      onEditStatusChanged?.call(_status);
    }

    final StackItem<StackItemContent>? item = _stackController.getById(itemId);
    if (item == null) return;

    if (item.offset == null) return;
    if (item.size == null) return;

    final double angle = item.angle ?? 0;
    final double fsina = math.sin(-angle);
    final double fcosa = math.cos(-angle);
    // final double sina = math.sin(angle);
    // final double cosa = math.cos(angle);

    // final Offset d = dud.delta;
    final Offset d = dud.globalPosition;
    // d = Offset(fsina * d.dy + fcosa * d.dx, fcosa * d.dy - fsina * d.dx);

    // print('delta:$d');

    // final Size size = item.size!;
    // double w = size.width + d.dx;
    // double h = size.height + d.dy;

    final CaseStyle style = _caseStyle(context);

    final double min = style.iconSize * 3;

    Offset start = item.offset! + Offset(-style.iconSize / 2, style.iconSize * 2);
    start = Offset(fsina * start.dy + fcosa * start.dx, fcosa * start.dy - fsina * start.dx);

    double w = d.dx - start.dx;
    double h = d.dy - start.dy;

    //达到极小值
    if (w < min) w = min;
    if (h < min) h = min;

    Size s = Size(w, h);

    if (d.dx < 0 && s.width < min) s = Size(min, h);
    if (d.dy < 0 && s.height < min) s = Size(w, min);

    //缩放拦截
    if (!(onSizeChanged?.call(s) ?? true)) return;

    if (style.boxAspectRatio != null) {
      if (s.width < s.height) {
        _stackController.updateBasic(itemId, size: Size(s.width, s.width / caseStyle!.boxAspectRatio!));
      } else {
        _stackController.updateBasic(itemId, size: Size(s.height * style.boxAspectRatio!, s.height));
      }
    } else {
      _stackController.updateBasic(itemId, size: s);
    }
  }

  /// * 旋转操作
  /// * Rotate operation
  void _roateHandle(DragUpdateDetails dud, BuildContext context, final StackItemStatus status) {
    StackItemStatus _status = status;

    final StackBoardController _stackController = _controller(context);

    _stackController.selectOne(itemId);

    if (_status != StackItemStatus.roating) {
      if (_status == StackItemStatus.moving || _status == StackItemStatus.scaling) {
        _status = StackItemStatus.roating;
      } else {
        _status = StackItemStatus.roating;
        _stackController.updateBasic(itemId, status: _status);
      }

      onEditStatusChanged?.call(_status);
    }

    final StackItem<StackItemContent>? item = _stackController.getById(itemId);
    if (item == null) return;

    if (item.size == null) return;
    if (item.offset == null) return;

    final CaseStyle style = _caseStyle(context);

    final Offset start = item.offset!;
    final Offset global = dud.globalPosition.translate(
      style.iconSize / 2,
      -style.iconSize * 2.5,
    );
    final Size size = item.size!;
    final Offset center = Offset(start.dx + size.width / 2, start.dy + size.height / 2);
    final double l = (global - center).distance;
    final double s = (global.dy - center.dy).abs();

    double angle = math.asin(s / l);

    if (global.dx < center.dx) {
      if (global.dy < center.dy) {
        angle = math.pi + angle;
        // print('第四象限');
      } else {
        angle = math.pi - angle;
        // print('第三象限');
      }
    } else {
      if (global.dy < center.dy) {
        angle = 2 * math.pi - angle;
        // print('第一象限');
      }
    }

    //旋转拦截
    if (!(onAngleChanged?.call(angle) ?? true)) return;

    _stackController.updateBasic(itemId, angle: angle);
  }

  /// * 旋转回0度
  /// * Rotate back to 0 degrees
  void _turnBack(BuildContext context) {
    final StackBoardController _stackController = _controller(context);

    _stackController.selectOne(itemId);

    final StackItem<StackItemContent>? item = _stackController.getById(itemId);
    if (item == null) return;

    _stackController.updateBasic(itemId, status: StackItemStatus.roating);

    if (item.angle != 0) {
      _stackController.updateBasic(itemId, angle: 0, status: StackItemStatus.selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConfigBuilder.withItem(
      itemId,
      shouldRebuild: (StackItem<StackItemContent> p, StackItem<StackItemContent> n) =>
          p.offset != n.offset || p.angle != n.angle,
      childBuilder: (StackItem<StackItemContent> item, Widget c) {
        return Positioned(
          key: ValueKey<String>(item.id),
          top: item.offset?.dy ?? 0,
          left: item.offset?.dx ?? 0,
          child: Transform.rotate(angle: item.angle ?? 0, child: c),
        );
      },
      child: ConfigBuilder.withItem(
        itemId,
        shouldRebuild: (StackItem<StackItemContent> p, StackItem<StackItemContent> n) => p.status != n.status,
        childBuilder: (StackItem<StackItemContent> item, Widget c) {
          final StackItemStatus status = item.status ?? StackItemStatus.idle;

          return MouseRegion(
            cursor: _cursor(status),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (DragUpdateDetails dud) => _onPanUpdate(dud, context, status),
              onPanEnd: (_) => _onPanEnd(context, status),
              onTap: () => _onTap(context),
              child: Stack(
                children: <Widget>[
                  borderBuilder?.call(status) ?? _border(context, status),
                  _child(context),
                  if (actionsBuilder != null) actionsBuilder!(status, _caseStyle(context)),
                  if (actionsBuilder == null) ...<Widget>[
                    if (status != StackItemStatus.idle) _edit(context, status),
                    if (status != StackItemStatus.idle) _roate(context, status),
                    if (status != StackItemStatus.idle) _check(context, status),
                    if (onDel != null && status != StackItemStatus.idle) _del(context),
                    if (status != StackItemStatus.idle) _scale(context, status, item.angle),
                  ],
                ],
              ),
            ),
          );
        },
        child: const SizedBox.shrink(),
      ),
    );
  }

  /// * 子组件
  /// * Child component
  Widget _child(BuildContext context) {
    final StackBoardController _stackController = _controller(context);

    final StackItem<StackItemContent>? item = _stackController.getById(itemId);
    if (item == null) return const SizedBox.shrink();

    Widget content = childBuilder?.call(item) ?? const SizedBox.shrink();

    Size? _size = item.size;

    if (_size == null) {
      final CaseStyle style = _caseStyle(context);
      final double minSize = style.iconSize * 3;

      content = GetSize(
        onChanged: (Size? size) {
          if (size != null && _size == null) {
            _size = size;

            if (_size!.width < minSize) {
              _size = Size(minSize, _size!.height);
            }

            if (_size!.height < minSize) {
              _size = Size(_size!.width, minSize);
            }

            _stackController.updateBasic(itemId, size: _size);
          }
        },
        child: content,
      );
    }

    return ConfigBuilder.withItem(
      itemId,
      shouldRebuild: (StackItem<StackItemContent> p, StackItem<StackItemContent> n) => p.size != n.size,
      childBuilder: (StackItem<StackItemContent> item, Widget c) {
        return SizedBox.fromSize(size: item.size, child: c);
      },
      child: Padding(
        padding: EdgeInsets.all(_caseStyle(context).iconSize),
        child: content,
      ),
    );
  }

  /// * 边框
  /// * Border
  Widget _border(BuildContext context, StackItemStatus status) {
    final CaseStyle style = _caseStyle(context);

    return Positioned(
      top: style.iconSize / 2,
      bottom: style.iconSize / 2,
      left: style.iconSize / 2,
      right: style.iconSize / 2,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: status == StackItemStatus.idle ? Colors.transparent : style.borderColor,
            width: style.borderWidth,
          ),
        ),
      ),
    );
  }

  /// * 编辑手柄
  /// * Edit handle
  Widget _edit(BuildContext context, StackItemStatus status) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _tapEdit(context, status),
        child: _toolCase(
          context,
          Icon(status == StackItemStatus.editing ? Icons.border_color : Icons.edit),
        ),
      ),
    );
  }

  /// * 删除手柄
  /// * Delete handle
  Widget _del(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => onDel?.call(),
          child: _toolCase(context, const Icon(Icons.clear)),
        ),
      ),
    );
  }

  /// * 缩放手柄
  /// * Scale handle
  Widget _scale(BuildContext context, StackItemStatus status, double? angle) {
    final bool hasAngle = angle != null && angle != 0;

    return Positioned(
      bottom: 0,
      right: 0,
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeUpLeftDownRight,
        child: GestureDetector(
          onPanUpdate: hasAngle ? null : (DragUpdateDetails dud) => _scaleHandle(dud, context, status),
          onPanEnd: hasAngle ? null : (_) => _onPanEnd(context, status),
          onTap: hasAngle ? () => _turnBack(context) : null,
          child: _toolCase(
            context,
            RotatedBox(
              quarterTurns: 1,
              child: Icon(angle == 0 ? Icons.open_in_full_outlined : Icons.restart_alt_rounded),
            ),
          ),
        ),
      ),
    );
  }

  /// * 旋转手柄
  /// * Rotate handle
  Widget _roate(BuildContext context, StackItemStatus status) {
    return Positioned(
      top: 0,
      bottom: 0,
      right: 0,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onPanUpdate: (DragUpdateDetails dud) => _roateHandle(dud, context, status),
          onPanEnd: (_) => _onPanEnd(context, status),
          child: _toolCase(
            context,
            const RotatedBox(
              quarterTurns: 1,
              child: Icon(Icons.refresh),
            ),
          ),
        ),
      ),
    );
  }

  /// * 完成操作
  /// * Complete operation
  Widget _check(BuildContext context, StackItemStatus status) {
    StackItemStatus _status = status;

    return Positioned(
      bottom: 0,
      left: 0,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            if (_status != StackItemStatus.idle) {
              _status = StackItemStatus.idle;
              onEditStatusChanged?.call(_status);
              _controller(context).updateBasic(itemId, status: _status);
            }
          },
          child: _toolCase(context, const Icon(Icons.check)),
        ),
      ),
    );
  }

  /// * 操作手柄壳
  /// * Operation handle shell
  Widget _toolCase(BuildContext context, Widget child) {
    final CaseStyle style = _caseStyle(context);

    return Container(
      width: style.iconSize,
      height: style.iconSize,
      child: IconTheme(
        data: Theme.of(context).iconTheme.copyWith(
              color: style.iconColor,
              size: style.iconSize * 0.6,
            ),
        child: child,
      ),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: style.borderColor,
      ),
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
