import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:stack_board/src/helper/operat_state.dart';
import 'package:stack_board/src/item_group/adaptive_text.dart';

import 'item_case.dart';

/// 默认文本样式
const TextStyle _defaultStyle = TextStyle(fontSize: 20);

/// 自适应文本外壳
class AdaptiveTextCase extends StatefulWidget {
  const AdaptiveTextCase({
    Key? key,
    required this.adaptiveText,
    this.onDel,
    this.operatState,
    this.onTap,
  }) : super(key: key);

  @override
  _AdaptiveTextCaseState createState() => _AdaptiveTextCaseState();

  /// 自适应文本对象
  final AdaptiveText adaptiveText;

  /// 移除拦截
  final void Function()? onDel;

  /// 点击回调
  final void Function()? onTap;

  /// 操作状态
  final OperatState? operatState;
}

class _AdaptiveTextCaseState extends State<AdaptiveTextCase> with SafeState<AdaptiveTextCase> {
  /// 是否正在编辑
  bool _isEditing = false;

  /// 文本内容
  late String _text = widget.adaptiveText.data;

  /// 输入框宽度
  double _textFieldWidth = 100;

  /// 文本样式
  TextStyle get _style => widget.adaptiveText.style ?? _defaultStyle;

  /// 计算文本大小
  Size _textSize(String text, TextStyle style) {
    final TextPainter textPainter =
        TextPainter(text: TextSpan(text: text, style: style), maxLines: 1, textDirection: TextDirection.ltr)
          ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  @override
  Widget build(BuildContext context) {
    return ItemCase(
      isCenter: false,
      canEdit: true,
      onTap: widget.onTap,
      tapToEdit: widget.adaptiveText.tapToEdit,
      child: _isEditing ? _buildEditingBox : _buildTextBox,
      onDel: widget.onDel,
      operatState: widget.operatState,
      caseStyle: widget.adaptiveText.caseStyle,
      onOperatStateChanged: (OperatState s) {
        if (s != OperatState.editing && _isEditing) {
          safeSetState(() => _isEditing = false);
        } else if (s == OperatState.editing && !_isEditing) {
          safeSetState(() => _isEditing = true);
        }
      },
      onSizeChanged: (Size s) {
        final Size size = _textSize(_text, _style);
        _textFieldWidth = size.width + 8;
      },
    );
  }

  /// 仅文本
  Widget get _buildTextBox {
    return FittedBox(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          _text,
          style: _style,
          textAlign: widget.adaptiveText.textAlign,
          textDirection: widget.adaptiveText.textDirection,
          locale: widget.adaptiveText.locale,
          softWrap: widget.adaptiveText.softWrap,
          overflow: widget.adaptiveText.overflow,
          textScaleFactor: widget.adaptiveText.textScaleFactor,
          maxLines: widget.adaptiveText.maxLines,
          semanticsLabel: widget.adaptiveText.semanticsLabel,
        ),
      ),
    );
  }

  /// 正在编辑
  Widget get _buildEditingBox {
    return FittedBox(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: SizedBox(
          width: _textFieldWidth,
          child: TextFormField(
            autofocus: true,
            initialValue: _text,
            onChanged: (String v) => _text = v,
            style: _style,
            textAlign: widget.adaptiveText.textAlign ?? TextAlign.start,
            textDirection: widget.adaptiveText.textDirection,
            maxLines: widget.adaptiveText.maxLines,
          ),
        ),
      ),
    );
  }
}
