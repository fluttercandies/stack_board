import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flutter_drawing_board/helpers.dart';
import 'package:flutter_drawing_board/paint_contents.dart';
import 'package:stack_board/src/core/stack_board_item/stack_item_status.dart';
import 'package:stack_board/stack_items.dart';

const double _defSize = 300;

/// * 绘制对象
/// * Draw object
class StackDrawCase extends StatefulWidget {
  const StackDrawCase({
    Key? key,
    required this.item,
    this.background,
    this.onPaint,
    this.onPointerDown,
    this.onPointerMove,
  }) : super(key: key);

  /// * StackDrawItem
  final StackDrawItem item;

  /// * 背景
  /// * background
  final Widget? background;

  /// * 抬起时的回调当前的所以内容
  /// * Callback to the current content when lifted
  final Function(List<PaintContent> contents)? onPaint;

  /// * 开始拖动
  /// * Start dragging
  final Function(PointerDownEvent pde)? onPointerDown;

  /// * 正在拖动
  /// * Dragging
  final Function(PointerMoveEvent pme)? onPointerMove;

  @override
  State<StackDrawCase> createState() => _StackDrawCaseState();
}

class _StackDrawCaseState extends State<StackDrawCase> {
  final DrawingController _controller = DrawingController();

  @override
  void initState() {
    super.initState();
    if (widget.item.content?.paintContents.isNotEmpty ?? false) {
      _controller.addContents(widget.item.content!.paintContents);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.item.status == StackItemStatus.editing;

  double get _size => widget.item.content?.size ?? _defSize;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Container(
        width: _size,
        height: _size,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            DrawingBoard(
              onPointerDown: widget.onPointerDown,
              onPointerMove: widget.onPointerMove,
              onPointerUp: (_) {
                widget.item.setContents(_controller.getHistory);
                widget.onPaint?.call(_controller.getHistory);
              },
              controller: _controller,
              boardPanEnabled: false,
              boardScaleEnabled: false,
              background: widget.background ?? Container(width: _size, height: _size, color: Colors.white),
            ),
            _tools(),
            _actions(),
            if (!_isEditing) _mask(),
          ],
        ),
      ),
    );
  }

  /// * 遮罩
  /// * Mask
  Widget _mask() {
    return Positioned.fill(
      child: Container(color: Colors.transparent),
    );
  }

  /// * 工具栏
  /// * Tool bar
  Widget _tools() {
    return _configBuilder(
      shouldRebuild: (DrawConfig p, DrawConfig n) => p.fingerCount != n.fingerCount || p.contentType != n.contentType,
      builder: (DrawConfig dc, Widget? child) {
        final bool isPen = _isEditing && dc.fingerCount == 1;

        double _left = 0;

        if (_isEditing) {
          if (isPen) _left = -30;
        } else {
          _left = -30;
        }

        return AnimatedPositioned(
          left: _left,
          top: 0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
          child: Container(
            width: 30,
            decoration: BoxDecoration(
              color: Theme.of(context).bottomAppBarColor,
              boxShadow: _left == 0
                  ? const <BoxShadow>[
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 2,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: DrawingBoard.defaultTools(dc.contentType, _controller)
                  .map((DefToolItem item) => _DefToolItem(item: item))
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  /// * 操作栏
  /// * Operation bar
  Widget _actions() {
    return _configBuilder(
      shouldRebuild: (DrawConfig p, DrawConfig n) => p.fingerCount != n.fingerCount,
      builder: (DrawConfig dc, Widget? child) {
        final bool isPen = dc.fingerCount == 1;

        double _bottom = 0;

        if (_isEditing) {
          if (isPen) _bottom = -30;
        } else {
          _bottom = -30;
        }

        return AnimatedPositioned(
          bottom: _bottom,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
          child: Container(
            height: 30,
            decoration: BoxDecoration(
              color: Theme.of(context).bottomAppBarColor,
              boxShadow: _bottom == 0
                  ? const <BoxShadow>[
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 2,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: child,
          ),
        );
      },
      child: Row(
        children: <Widget>[
          SizedBox(
            height: 14,
            width: 85,
            child: SliderTheme(
              data: const SliderThemeData(
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 14),
                trackHeight: 2,
              ),
              child: _configBuilder(
                shouldRebuild: (DrawConfig p, DrawConfig n) => p.strokeWidth != n.strokeWidth,
                builder: (DrawConfig dc, _) {
                  return Slider(
                    value: dc.strokeWidth,
                    max: 40,
                    min: 1,
                    onChanged: (double v) => _controller.setStyle(strokeWidth: v),
                  );
                },
              ),
            ),
          ),
          ColorPicBtn(
            controller: _controller,
            builder: (Color color) {
              return Container(
                width: 14,
                height: 14,
                color: color,
              );
            },
          ),
          _DefActionItem(
            icon: CupertinoIcons.arrow_turn_up_left,
            onTap: () => _controller.undo(),
          ),
          _DefActionItem(
            icon: CupertinoIcons.arrow_turn_up_right,
            onTap: () => _controller.redo(),
          ),
          _DefActionItem(
            icon: CupertinoIcons.rotate_right,
            onTap: () => _controller.turn(),
          ),
          _DefActionItem(
            icon: CupertinoIcons.trash,
            onTap: () => _controller.clear(),
          ),
        ],
      ),
    );
  }

  /// * 选项构建器
  /// * Option builder
  Widget _configBuilder({
    bool Function(DrawConfig p, DrawConfig n)? shouldRebuild,
    required Widget Function(DrawConfig dc, Widget? child) builder,
    Widget? child,
  }) {
    return ExValueBuilder<DrawConfig>(
      valueListenable: _controller.drawConfig,
      shouldRebuild: shouldRebuild,
      builder: (_, DrawConfig config, Widget? child) {
        return builder(config, child);
      },
      child: child,
    );
  }
}

/// * 默认工具项
/// * Default tool item
class _DefToolItem extends StatelessWidget {
  const _DefToolItem({
    Key? key,
    required this.item,
  }) : super(key: key);

  final DefToolItem item;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: TextButton(
        onPressed: item.onTap,
        style: TextButton.styleFrom(
          foregroundColor: Colors.black,
        ),
        child: Icon(
          item.icon,
          size: 14,
          color: item.isActive ? item.activeColor : item.color,
        ),
      ),
    );
  }
}

/// * 默认操作项
/// * Default operation item
class _DefActionItem extends StatelessWidget {
  const _DefActionItem({
    Key? key,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  final IconData icon;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: TextButton(
        onPressed: onTap,
        child: Icon(icon, size: 14, color: Colors.black),
      ),
    );
  }
}
