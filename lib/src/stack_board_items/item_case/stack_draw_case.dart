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
              background: widget.background ??
                  Container(width: _size, height: _size, color: Colors.white),
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
      shouldRebuild: (DrawConfig p, DrawConfig n) =>
          p.fingerCount != n.fingerCount || p.contentType != n.contentType,
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
              color: Theme.of(context).canvasColor,
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
      shouldRebuild: (DrawConfig p, DrawConfig n) =>
          p.fingerCount != n.fingerCount,
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
              color: Theme.of(context).canvasColor,
              boxShadow: _bottom == 0
                  ? const <BoxShadow>[
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 2,
                          spreadRadius: 1),
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
                shouldRebuild: (DrawConfig p, DrawConfig n) =>
                    p.strokeWidth != n.strokeWidth,
                builder: (DrawConfig dc, _) {
                  return Slider(
                    value: dc.strokeWidth,
                    max: 40,
                    min: 1,
                    onChanged: (double v) =>
                        _controller.setStyle(strokeWidth: v),
                  );
                },
              ),
            ),
          ),
          ColorPicBtn(
            initColor: _controller.getColor,
            onColorChanged: (Color color) => _controller.setStyle(color: color),
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
          padding: EdgeInsets.zero,
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
        style: TextButton.styleFrom(
          foregroundColor: Colors.black,
          padding: EdgeInsets.zero,
        ),
        child: Icon(icon, size: 14, color: Colors.black),
      ),
    );
  }
}

class ColorPicBtn extends StatefulWidget {
  const ColorPicBtn({
    Key? key,
    required this.initColor,
    required this.onColorChanged,
  }) : super(key: key);

  final Color initColor;
  final void Function(Color color) onColorChanged;

  @override
  State<ColorPicBtn> createState() => _ColorPicBtnState();
}

class _ColorPicBtnState extends State<ColorPicBtn> {
  late final SafeValueNotifier<_ColorPickerValue> _colorValue =
      SafeValueNotifier<_ColorPickerValue>(
          _ColorPickerValue.init(widget.initColor));

  final LayerLink _layerLink = LayerLink();

  _ColorPickerValue get _value => _colorValue.value;

  @override
  void dispose() {
    _colorValue.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.1),
      builder: (_) => _buildColorPicker(),
    );

    widget.onColorChanged(_value.color);
  }

  Color _mixColors(Color grayColor, Color color, double xRatio, double yRatio) {
    int red = (grayColor.red * (1 - xRatio) + color.red * xRatio).toInt();
    int green = (grayColor.green * (1 - xRatio) + color.green * xRatio).toInt();
    int blue = (grayColor.blue * (1 - xRatio) + color.blue * xRatio).toInt();

    final Color middleColor = Color.fromARGB(255, red, green, blue);

    red = (grayColor.red * yRatio + middleColor.red * (1 - yRatio)).toInt();
    green =
        (grayColor.green * yRatio + middleColor.green * (1 - yRatio)).toInt();
    blue = (grayColor.blue * yRatio + middleColor.blue * (1 - yRatio)).toInt();

    return Color.fromARGB(255, red, green, blue);
  }

  @override
  Widget build(BuildContext context) {
    return ExValueBuilder<_ColorPickerValue>(
      valueListenable: _colorValue,
      shouldRebuild: (_ColorPickerValue p, _ColorPickerValue n) =>
          p.color != n.color,
      builder: (_, _ColorPickerValue v, __) {
        return CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            onTap: _onTap,
            child: Container(
              width: 16,
              height: 16,
              color: v.color,
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorPicker() {
    return Center(
      child: CompositedTransformFollower(
        link: _layerLink,
        targetAnchor: Alignment.topCenter,
        followerAnchor: Alignment.bottomCenter,
        offset: const Offset(0, -10),
        child: Container(
          width: 200,
          color: Colors.white,
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AspectRatio(
                aspectRatio: 1,
                child: LayoutBuilder(
                  builder: (_, BoxConstraints c) {
                    return ExValueBuilder<_ColorPickerValue>(
                      valueListenable: _colorValue,
                      shouldRebuild:
                          (_ColorPickerValue p, _ColorPickerValue n) =>
                              p.offset != n.offset || p.color != n.color,
                      builder: (BuildContext context, _ColorPickerValue v, __) {
                        double left = v.offset.dx * (c.maxWidth - 30);
                        if (left < 0) left = 0;
                        if (left > c.maxWidth - 30) left = c.maxWidth - 30;

                        double top = v.offset.dy * (c.maxHeight - 30);
                        if (top < 0) top = 0;
                        if (top > c.maxHeight - 30) top = c.maxHeight - 30;

                        return Stack(
                          children: <Widget>[
                            GestureDetector(
                              onPanUpdate: (DragUpdateDetails d) {
                                double x = d.localPosition.dx / c.maxWidth;
                                if (x < 0) x = 0;
                                if (x > 1) x = 1;
                                double y = d.localPosition.dy / c.maxHeight;
                                if (y < 0) y = 0;
                                if (y > 1) y = 1;

                                final double grayValue = (1 - y) * 255;
                                final Color grayColor = Color.fromARGB(
                                  255,
                                  grayValue.toInt(),
                                  grayValue.toInt(),
                                  grayValue.toInt(),
                                );

                                _colorValue.value = _value.copyWith(
                                  offset: Offset(x, y),
                                  color: _mixColors(
                                      grayColor, _value.baseColor, x, y),
                                  grayColor: grayColor,
                                );
                              },
                              child: SizedBox.expand(
                                  child: CustomPaint(
                                      painter: _GrayscalePainter(v.baseColor))),
                            ),
                            Positioned(
                              left: left,
                              top: top,
                              child: IgnorePointer(
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: v.color,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                      strokeAlign: BorderSide.strokeAlignInside,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              LayoutBuilder(builder: (_, BoxConstraints c) {
                return GestureDetector(
                  onHorizontalDragUpdate: (DragUpdateDetails d) {
                    // 滑动时更新颜色
                    double _hue = (d.localPosition.dx / c.maxWidth) * 360;

                    if (_hue < 0) _hue = 0;
                    if (_hue > 360) _hue = 360;

                    double left = d.localPosition.dx - 15;

                    if (left < 0) left = 0;
                    if (left > c.maxWidth - 30) left = c.maxWidth - 30;

                    final Color baseColor =
                        HSVColor.fromAHSV(1.0, _hue, 1.0, 1.0).toColor();

                    _colorValue.value = _value.copyWith(
                      baseColor: baseColor,
                      color: _mixColors(_value.grayColor, baseColor,
                          _value.offset.dx, _value.offset.dy),
                      pickerLeft: left,
                    );
                  },
                  child: Container(
                    height: 30,
                    alignment: Alignment.centerLeft,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          Colors.red,
                          Colors.yellow,
                          Colors.green,
                          Colors.cyan,
                          Colors.blue,
                          Colors.purple,
                          Colors.red,
                        ],
                      ),
                    ),
                    child: IgnorePointer(
                      child: ExValueBuilder<_ColorPickerValue>(
                        valueListenable: _colorValue,
                        shouldRebuild:
                            (_ColorPickerValue p, _ColorPickerValue n) =>
                                p.pickerLeft != n.pickerLeft ||
                                p.baseColor != n.baseColor,
                        builder: (_, _ColorPickerValue v, __) {
                          return Container(
                            width: 30,
                            height: 30,
                            margin: EdgeInsets.only(left: v.pickerLeft),
                            decoration: BoxDecoration(
                              color: v.baseColor,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                                strokeAlign: BorderSide.strokeAlignInside,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorPickerValue {
  const _ColorPickerValue({
    required this.baseColor,
    required this.color,
    required this.offset,
    required this.pickerLeft,
    required this.grayColor,
  });

  factory _ColorPickerValue.init(Color color) {
    return _ColorPickerValue(
      baseColor: color,
      color: color,
      offset: const Offset(1, 0),
      pickerLeft: 0.0,
      grayColor: Colors.white,
    );
  }

  final Color baseColor;
  final Color color;
  final Offset offset;
  final double pickerLeft;
  final Color grayColor;

  _ColorPickerValue copyWith({
    Color? baseColor,
    Color? color,
    Offset? offset,
    double? pickerLeft,
    Color? grayColor,
    double? xRatio,
    double? yRatio,
  }) {
    return _ColorPickerValue(
      baseColor: baseColor ?? this.baseColor,
      color: color ?? this.color,
      offset: offset ?? this.offset,
      pickerLeft: pickerLeft ?? this.pickerLeft,
      grayColor: grayColor ?? this.grayColor,
    );
  }
}

class _GrayscalePainter extends CustomPainter {
  const _GrayscalePainter(this.currentColor);

  final Color currentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = LinearGradient(
        colors: <Color>[Colors.black, Colors.black.withOpacity(0)],
        begin: Alignment.bottomLeft,
        end: Alignment.topLeft,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final Paint overlayPaint = Paint()
      ..shader = LinearGradient(
        colors: <Color>[Colors.white, currentColor],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), overlayPaint);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_GrayscalePainter oldDelegate) {
    return oldDelegate.currentColor != currentColor;
  }
}
