import 'dart:io';

import 'package:flutter/material.dart';

///通用图片
class AutoImage extends StatelessWidget {
  const AutoImage({
    Key? key,
    required this.url,
    this.frameBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.semanticLabel,
    this.width,
    this.height,
    this.color,
    this.opacity,
    this.colorBlendMode,
    this.fit,
    this.centerSlice,
    this.excludeFromSemantics = false,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
    this.isAntiAlias = false,
    this.filterQuality = FilterQuality.low,
    this.scale = 1.0,
    this.headers,
  }) : super(key: key);

  final String url;

  final Widget Function(BuildContext, Widget, int?, bool)? frameBuilder;
  final Widget Function(BuildContext, Widget, ImageChunkEvent?)? loadingBuilder;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  final String? semanticLabel;
  final bool excludeFromSemantics;
  final double? width;
  final double? height;
  final Color? color;
  final Animation<double>? opacity;
  final BlendMode? colorBlendMode;
  final BoxFit? fit;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final Rect? centerSlice;
  final bool matchTextDirection;
  final bool gaplessPlayback;
  final bool isAntiAlias;
  final FilterQuality filterQuality;

  final double scale;
  final Map<String, String>? headers;

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) return const Text('Empty url');

    late ImageProvider<Object> _image;

    if (url.startsWith('http')) {
      _image = NetworkImage(url, headers: headers, scale: scale);
    } else if (url.startsWith('/')) {
      _image = FileImage(File(url), scale: scale);
    } else {
      _image = AssetImage(url);
    }

    return Image(
      image: _image,
      frameBuilder: frameBuilder,
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      centerSlice: centerSlice,
      excludeFromSemantics: excludeFromSemantics,
      alignment: alignment,
      repeat: repeat,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      filterQuality: filterQuality,
    );
  }
}
