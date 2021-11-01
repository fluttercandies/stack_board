import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flutter_drawing_board/helper/color_pic.dart';
import 'package:stack_board/helper/safe_state.dart';
import 'package:stack_board/helper/safe_value_notifier.dart';
import 'package:stack_board/item_group/stack_drawing.dart';

import 'item_case.dart';

///画板外壳
class DrawingBoardCase extends StatefulWidget {
  const DrawingBoardCase({
    Key? key,
    required this.stackDrawing,
    this.onDel,
    this.isOperating,
  }) : super(key: key);

  @override
  _DrawingBoardCaseState createState() => _DrawingBoardCaseState();

  final StackDrawing stackDrawing;
  final void Function()? onDel;
  final bool? isOperating;
}

class _DrawingBoardCaseState extends State<DrawingBoardCase> with SafeState<DrawingBoardCase> {
  late DrawingController _drawingController;

  ///绘制线条粗细进度
  late SafeValueNotifier<double> _indicator;

  bool _isEditing = true;
  bool _isDrawing = false;

  @override
  void initState() {
    super.initState();
    _drawingController = DrawingController(config: DrawConfig.def());
    _indicator = SafeValueNotifier<double>(1);
  }

  @override
  void dispose() {
    _drawingController.dispose();
    _indicator.dispose();
    super.dispose();
  }

  ///选择颜色
  Future<void> _pickColor() async {
    final Color? newColor = await showModalBottomSheet<Color?>(
        context: context, builder: (_) => ColorPic(nowColor: _drawingController.getColor));
    if (newColor == null) {
      return;
    }

    if (newColor != _drawingController.getColor) {
      _drawingController.setColor = newColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ItemCase(
      isCenter: false,
      isEditing: true,
      isOperating: widget.isOperating,
      tools: _tools,
      child: FittedBox(
        child: SizedBox.fromSize(
          size: widget.stackDrawing.size,
          child: Stack(
            children: <Widget>[
              FittedBox(
                child: SizedBox.fromSize(
                  size: widget.stackDrawing.size,
                  child: DrawingBoard(
                    controller: _drawingController,
                    background: widget.stackDrawing.child,
                    drawingCallback: (bool isDrawing) {
                      if (_isDrawing != isDrawing) {
                        _isDrawing = isDrawing;
                        safeSetState(() {});
                      }
                    },
                  ),
                ),
              ),
              if (!_isEditing) _mask,
            ],
          ),
        ),
      ),
      onDel: widget.onDel,
      caseStyle: widget.stackDrawing.caseStyle,
      onEdit: (bool isEditing) {
        if (isEditing != _isEditing) {
          if (!isEditing) {
            _isDrawing = false;
          }
          _isEditing = isEditing;
          safeSetState(() {});
        }
      },
    );
  }

  ///绘制拦截图层
  Widget get _mask {
    return Positioned(
      top: 0,
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(color: Colors.transparent),
    );
  }

  ///工具栏
  Widget? get _tools {
    if (!_isEditing || _isDrawing) return const SizedBox.shrink();

    return Stack(
      children: <Widget>[
        _toolBar,
        Align(alignment: Alignment.bottomRight, child: _buildActions),
      ],
    );
  }

  ///工具栏
  Widget get _toolBar {
    return FittedBox(
      fit: BoxFit.none,
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
            width: widget.stackDrawing.caseStyle!.iconSize * 1.5,
            color: Colors.white,
            child: Column(
              children: <Widget>[
                _buildToolItem(
                    PaintType.simpleLine, Icons.brush, () => _drawingController.setType = PaintType.simpleLine),
                _buildToolItem(PaintType.straightLine, Icons.show_chart,
                    () => _drawingController.setType = PaintType.straightLine),
                _buildToolItem(
                    PaintType.rectangle, Icons.crop_din, () => _drawingController.setType = PaintType.rectangle),
                _buildToolItem(
                    PaintType.eraser, Icons.auto_fix_normal, () => _drawingController.setType = PaintType.eraser),
              ],
            )),
      ),
    );
  }

  ///构建工具项
  Widget _buildToolItem(PaintType type, IconData icon, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: widget.stackDrawing.caseStyle!.iconSize * 1.5,
        height: widget.stackDrawing.caseStyle!.iconSize * 1.6,
        child: ExValueBuilder<DrawConfig>(
          valueListenable: _drawingController.drawConfig,
          shouldRebuild: (DrawConfig? p, DrawConfig? n) => p!.paintType == type || n!.paintType == type,
          builder: (_, DrawConfig? dc, __) {
            return Icon(
              icon,
              color: dc?.paintType == type ? Theme.of(context).primaryColor : null,
              size: widget.stackDrawing.caseStyle?.iconSize,
            );
          },
        ),
      ),
    );
  }

  ///构建操作栏
  Widget get _buildActions {
    final double iconSize = widget.stackDrawing.caseStyle!.iconSize;

    return Container(
      height: iconSize * 1.5,
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        child: Row(
          children: <Widget>[
            Container(
              height: iconSize * 1.5,
              width: 80,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SliderTheme(
                data: SliderThemeData(
                  thumbShape: RoundSliderThumbShape(
                    enabledThumbRadius: iconSize / 2.5,
                    elevation: 0,
                  ),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
                ),
                child: ExValueBuilder<double>(
                  valueListenable: _indicator,
                  builder: (_, double? ind, ___) {
                    return Slider(
                      value: ind ?? 1,
                      max: 50,
                      min: 1,
                      divisions: 50,
                      label: ind?.floor().toString(),
                      onChanged: (double v) => _indicator.value = v,
                      onChangeEnd: (double v) => _drawingController.setThickness = v,
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              width: iconSize,
              height: iconSize,
              child: ExValueBuilder<DrawConfig?>(
                valueListenable: _drawingController.drawConfig,
                shouldRebuild: (DrawConfig? p, DrawConfig? n) => p!.color != n!.color,
                builder: (_, DrawConfig? dc, ___) {
                  return TextButton(
                    onPressed: _pickColor,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: dc?.color,
                      shape: const RoundedRectangleBorder(),
                    ),
                    child: const SizedBox.shrink(),
                  );
                },
              ),
            ),
            GestureDetector(
              onTap: () => _drawingController.undo(),
              child: SizedBox(
                width: iconSize * 1.6,
                child: Icon(CupertinoIcons.arrow_turn_up_left, size: iconSize),
              ),
            ),
            GestureDetector(
              onTap: () => _drawingController.redo(),
              child: SizedBox(
                width: iconSize * 1.6,
                child: Icon(CupertinoIcons.arrow_turn_up_right, size: iconSize),
              ),
            ),
            GestureDetector(
              onTap: () => _drawingController.turn(),
              child: SizedBox(
                width: iconSize * 1.6,
                child: Icon(CupertinoIcons.rotate_right, size: iconSize),
              ),
            ),
            GestureDetector(
              onTap: () => _drawingController.clear(),
              child: SizedBox(
                width: iconSize * 1.6,
                child: Icon(Icons.clear_all, size: iconSize),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
