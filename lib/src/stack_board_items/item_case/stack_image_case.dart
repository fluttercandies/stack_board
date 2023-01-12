import 'package:flutter/material.dart';
import 'package:stack_board/src/stack_board_items/items/stack_image_item.dart';

class StackImageCase extends StatelessWidget {
  const StackImageCase({
    Key? key,
    required this.item,
  }) : super(key: key);

  final StackImageItem item;

  ImageItemContent get content => item.content!;

  @override
  Widget build(BuildContext context) {
    return Image(
      image: content.image,
      width: content.width,
      height: content.height,
      fit: content.fit,
      color: content.color,
      colorBlendMode: content.colorBlendMode,
      repeat: content.repeat,
      filterQuality: content.filterQuality,
      gaplessPlayback: content.gaplessPlayback,
      isAntiAlias: content.isAntiAlias,
      matchTextDirection: content.matchTextDirection,
      excludeFromSemantics: content.excludeFromSemantics,
      semanticLabel: content.semanticLabel,
    );
  }
}
