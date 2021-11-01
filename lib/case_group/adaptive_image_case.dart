import 'package:flutter/material.dart';
import 'package:stack_board/helper/auto_image.dart';
import 'package:stack_board/helper/safe_state.dart';
import 'package:stack_board/item_group/adaptive_image.dart';

import 'item_case.dart';

///自适应图片外壳
class AdaptiveImageCase extends StatefulWidget {
  const AdaptiveImageCase({
    Key? key,
    required this.adaptiveImage,
    this.onDel,
    this.isOperating = true,
  }) : super(key: key);

  @override
  _AdaptiveImageCaseState createState() => _AdaptiveImageCaseState();

  final AdaptiveImage adaptiveImage;
  final void Function()? onDel;
  final bool isOperating;
}

class _AdaptiveImageCaseState extends State<AdaptiveImageCase> with SafeState<AdaptiveImageCase> {
  bool _isEditing = false;
  late String _url = widget.adaptiveImage.url;
  double _textFieldWidth = 100;

  @override
  Widget build(BuildContext context) {
    return ItemCase(
      isCenter: false,
      child: _isEditing ? _buildUrlBox : _buildImageBox,
      onDel: widget.onDel,
      caseStyle: widget.adaptiveImage.caseStyle,
      onEdit: widget.adaptiveImage.canEdit
          ? (bool isEditing) {
              if (isEditing != _isEditing) {
                safeSetState(() => _isEditing = isEditing);
              }
            }
          : null,
      isOperating: widget.isOperating,
      onSizeChanged: (Size size) {
        _textFieldWidth = size.width;
      },
    );
  }

  ///仅图片
  Widget get _buildImageBox {
    return AutoImage(
      url: _url,
      frameBuilder: widget.adaptiveImage.frameBuilder,
      loadingBuilder: widget.adaptiveImage.loadingBuilder,
      errorBuilder: widget.adaptiveImage.errorBuilder,
      semanticLabel: widget.adaptiveImage.semanticLabel,
      width: widget.adaptiveImage.width,
      height: widget.adaptiveImage.height,
      color: widget.adaptiveImage.color,
      opacity: widget.adaptiveImage.opacity,
      colorBlendMode: widget.adaptiveImage.colorBlendMode,
      fit: widget.adaptiveImage.fit,
      centerSlice: widget.adaptiveImage.centerSlice,
      excludeFromSemantics: widget.adaptiveImage.excludeFromSemantics,
      alignment: widget.adaptiveImage.alignment,
      repeat: widget.adaptiveImage.repeat,
      matchTextDirection: widget.adaptiveImage.matchTextDirection,
      gaplessPlayback: widget.adaptiveImage.gaplessPlayback,
      isAntiAlias: widget.adaptiveImage.isAntiAlias,
      filterQuality: widget.adaptiveImage.filterQuality,
    );
  }

  ///正在编辑
  Widget get _buildUrlBox {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: SizedBox(
          width: _textFieldWidth,
          child: TextFormField(
            initialValue: _url,
            onChanged: (String v) => _url = v,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
