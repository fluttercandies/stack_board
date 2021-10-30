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
    this.isOperating = true,
  }) : super(key: key);

  @override
  _DrawingBoardCaseState createState() => _DrawingBoardCaseState();

  final StackDrawing stackDrawing;
  final void Function()? onDel;
  final bool isOperating;
}

class _DrawingBoardCaseState extends State<DrawingBoardCase> with SafeState<DrawingBoardCase> {
  late DrawingController _drawingController;

  ///线条粗细进度
  late SafeValueNotifier<double> _indicator;

  bool _isEditing = false;
  bool _isDrawing = true;

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
      isOperating: widget.isOperating,
      tools: _isEditing && !_isDrawing
          ? Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _toolBar,
                // _buildActions,
              ],
            )
          : null,
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
          safeSetState(() => _isEditing = isEditing);
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
  Widget get _toolBar {
    return FittedBox(
      fit: BoxFit.none,
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
            width: 40,
            color: Colors.white,
            child: Column(
              children: <Widget>[
                _buildToolItem(PaintType.simpleLine, CupertinoIcons.pencil,
                    () => _drawingController.setType = PaintType.simpleLine),
                _buildToolItem(PaintType.straightLine, Icons.show_chart,
                    () => _drawingController.setType = PaintType.straightLine),
                _buildToolItem(
                    PaintType.rectangle, CupertinoIcons.stop, () => _drawingController.setType = PaintType.rectangle),
                _buildToolItem(
                    PaintType.eraser, CupertinoIcons.bandage, () => _drawingController.setType = PaintType.eraser),
              ],
            )),
      ),
    );
  }

  ///构建工具项
  Widget _buildToolItem(PaintType type, IconData icon, Function() onTap) {
    return ExValueBuilder<DrawConfig>(
      valueListenable: _drawingController.drawConfig,
      shouldRebuild: (DrawConfig? p, DrawConfig? n) => p!.paintType == type || n!.paintType == type,
      builder: (_, DrawConfig? dc, __) {
        return IconButton(
          icon: Icon(
            icon,
            color: dc?.paintType == type ? Colors.blue : null,
          ),
          onPressed: onTap,
        );
      },
    );
  }

  ///构建操作栏
  Widget get _buildActions {
    return Container(
      height: 40,
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        child: Row(
          children: <Widget>[
            SizedBox(
              height: 24,
              width: 80,
              child: ExValueBuilder<double>(
                valueListenable: _indicator,
                builder: (_, double? ind, ___) {
                  return Slider(
                    value: ind!,
                    max: 50,
                    min: 1,
                    onChanged: (double v) => _indicator.value = v,
                    onChangeEnd: (double v) => _drawingController.setThickness = v,
                  );
                },
              ),
            ),
            SizedBox(
              width: 24,
              height: 24,
              child: ExValueBuilder<DrawConfig?>(
                valueListenable: _drawingController.drawConfig,
                shouldRebuild: (DrawConfig? p, DrawConfig? n) => p!.color != n!.color,
                builder: (_, DrawConfig? dc, ___) {
                  return TextButton(
                    onPressed: _pickColor,
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                    ),
                    child: Container(color: dc!.color),
                  );
                },
              ),
            ),
            IconButton(icon: const Icon(CupertinoIcons.arrow_turn_up_left), onPressed: () => _drawingController.undo()),
            IconButton(
                icon: const Icon(CupertinoIcons.arrow_turn_up_right), onPressed: () => _drawingController.redo()),
            IconButton(icon: const Icon(CupertinoIcons.rotate_right), onPressed: () => _drawingController.turn()),
            IconButton(icon: const Icon(CupertinoIcons.trash), onPressed: () => _drawingController.clear()),
          ],
        ),
      ),
    );
  }
}
