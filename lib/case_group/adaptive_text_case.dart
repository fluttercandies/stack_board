import 'package:flutter/material.dart';
import 'package:stack_board/helper/safe_state.dart';
import 'package:stack_board/item_group/adaptive_text.dart';

import 'item_case.dart';

const TextStyle _defaultStyle = TextStyle(fontSize: 20);

///自适应文本外壳
class AdaptiveTextCase extends StatefulWidget {
  const AdaptiveTextCase({
    Key? key,
    required this.adaptiveText,
    this.onDel,
    this.isOperating = true,
  }) : super(key: key);

  @override
  _AdaptiveTextCaseState createState() => _AdaptiveTextCaseState();

  final AdaptiveText adaptiveText;
  final void Function()? onDel;
  final bool isOperating;
}

class _AdaptiveTextCaseState extends State<AdaptiveTextCase> with SafeState<AdaptiveTextCase> {
  bool _isEditing = false;
  late String _text = widget.adaptiveText.data;
  double _textFieldWidth = 100;

  TextStyle get _style => widget.adaptiveText.style ?? _defaultStyle;

  Size _textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(text: TextSpan(text: text, style: style), maxLines: 1, textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  @override
  Widget build(BuildContext context) {
    return ItemCase(
      isCenter: false,
      child: _isEditing ? _buildEditingBox : _buildTextBox,
      onDel: widget.onDel,
      caseStyle: widget.adaptiveText.caseStyle,
      onEdit: (bool isEditing) {
        if (isEditing != _isEditing) {
          safeSetState(() => _isEditing = isEditing);
        }
      },
      onSizeChange: (Size s) {
        final Size size = _textSize(_text, _style);
        _textFieldWidth = size.width + 8;
      },
      isOperating: widget.isOperating,
    );
  }

  ///仅文本
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

  ///正在编辑
  Widget get _buildEditingBox {
    return FittedBox(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: SizedBox(
          width: _textFieldWidth,
          child: TextFormField(
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
