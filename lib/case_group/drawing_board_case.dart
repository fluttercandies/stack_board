import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:stack_board/helper/safe_state.dart';
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

  bool _isEditing = false;
  bool _isDrawing = true;

  @override
  void initState() {
    super.initState();
    _drawingController = DrawingController(config: DrawConfig.def());
  }

  @override
  void dispose() {
    _drawingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ItemCase(
      isCenter: false,
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
              // if (_isEditing && !_isDrawing) _toolBar,
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
      isOperating: widget.isOperating,
    );
  }

  ///绘制拦截
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
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
          width: 40,
          color: Colors.white,
          child: Column(
            children: <Widget>[
              _buildToolItem(
                  PaintType.simpleLine, CupertinoIcons.pencil, () => _drawingController.setType = PaintType.simpleLine),
              _buildToolItem(
                  PaintType.straightLine, Icons.show_chart, () => _drawingController.setType = PaintType.straightLine),
              _buildToolItem(
                  PaintType.rectangle, CupertinoIcons.stop, () => _drawingController.setType = PaintType.rectangle),
              _buildToolItem(
                  PaintType.eraser, CupertinoIcons.bandage, () => _drawingController.setType = PaintType.eraser),
            ],
          )),
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
}
