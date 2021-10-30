import 'package:flutter/material.dart';
import 'package:stack_board/helper/case_style.dart';

import 'stack_board_item.dart';

///自适应图片
class AdaptiveImage extends StackBoardItem {
  const AdaptiveImage(
    this.url, {
    final int? id,
    final Future<bool> Function()? onDel,
    CaseStyle? caseStyle,
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
    this.canEdit = true,
  }) : super(
          id: id,
          onDel: onDel,
          child: const SizedBox.shrink(),
          caseStyle: caseStyle,
        );

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

  final bool canEdit;

  @override
  AdaptiveImage copyWith({
    String? url,
    int? id,
    Widget? child,
    Function(bool)? onEdit,
    Future<bool> Function()? onDel,
    CaseStyle? caseStyle,
    Widget Function(BuildContext, Widget, int?, bool)? frameBuilder,
    Widget Function(BuildContext, Widget, ImageChunkEvent?)? loadingBuilder,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
    String? semanticLabel,
    bool? excludeFromSemantics,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry? alignment,
    ImageRepeat? repeat,
    Rect? centerSlice,
    bool? matchTextDirection,
    bool? gaplessPlayback,
    bool? isAntiAlias,
    FilterQuality? filterQuality,
    double? scale,
    Map<String, String>? headers,
    bool? canEdit,
  }) {
    return AdaptiveImage(
      url ?? this.url,
      id: id ?? this.id,
      onDel: onDel ?? this.onDel,
      caseStyle: caseStyle ?? this.caseStyle,
      frameBuilder: frameBuilder ?? this.frameBuilder,
      loadingBuilder: loadingBuilder ?? this.loadingBuilder,
      errorBuilder: errorBuilder ?? this.errorBuilder,
      semanticLabel: semanticLabel ?? this.semanticLabel,
      width: width ?? this.width,
      height: height ?? this.height,
      color: color ?? this.color,
      opacity: opacity ?? this.opacity,
      colorBlendMode: colorBlendMode ?? this.colorBlendMode,
      fit: fit ?? this.fit,
      centerSlice: centerSlice ?? this.centerSlice,
      excludeFromSemantics: excludeFromSemantics ?? this.excludeFromSemantics,
      alignment: alignment ?? this.alignment,
      repeat: repeat ?? this.repeat,
      matchTextDirection: matchTextDirection ?? this.matchTextDirection,
      gaplessPlayback: gaplessPlayback ?? this.gaplessPlayback,
      isAntiAlias: isAntiAlias ?? this.isAntiAlias,
      filterQuality: filterQuality ?? this.filterQuality,
      canEdit: canEdit ?? this.canEdit,
    );
  }
}
