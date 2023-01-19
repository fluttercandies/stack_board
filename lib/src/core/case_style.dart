import 'package:flutter/material.dart';
import 'package:stack_board/src/helpers/as_t.dart';

/// * 操作壳样式
/// * case style
@immutable
class CaseStyle {
  const CaseStyle({
    this.borderColor = Colors.white,
    this.borderWidth = 1,
    this.iconColor,
    this.iconSize = 24,
    this.boxAspectRatio,
  });

  factory CaseStyle.fromJson(final Map<String, dynamic> json) {
    final Color? borderColor = asNullT<Color>(json['borderColor']);
    final double? borderWidth = asNullT<double>(json['borderWidth']);
    final Color? iconColor = asNullT<Color>(json['iconColor']);
    final double? iconSize = asNullT<double>(json['iconSize']);
    final double? boxAspectRatio = asNullT<double>(json['boxAspectRatio']);

    return CaseStyle(
      borderColor: borderColor ?? Colors.white,
      borderWidth: borderWidth ?? 1,
      iconColor: iconColor,
      iconSize: iconSize ?? 24,
      boxAspectRatio: boxAspectRatio,
    );
  }

  /// * 边框(包括操作手柄)颜色
  /// * Border color (including operation handle)
  final Color borderColor;

  /// * 边框粗细
  /// * Border thickness
  final double borderWidth;

  /// * 图标颜色
  /// * Icon color
  final Color? iconColor;

  /// * 图标大小
  /// * Icon size
  final double iconSize;

  /// * 边框比例
  /// * if(boxAspectRatio!=null) 缩放变换将固定比例
  /// * Border ratio
  /// * if(boxAspectRatio!=null) Scaling transformation will fix the ratio
  final double? boxAspectRatio;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'borderColor': borderColor,
        'borderWidth': borderWidth,
        'iconColor': iconColor,
        'iconSize': iconSize,
        'boxAspectRatio': boxAspectRatio,
      };

  @override
  int get hashCode => Object.hash(borderColor, borderWidth, iconColor, iconSize, boxAspectRatio);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CaseStyle &&
          runtimeType == other.runtimeType &&
          borderColor == other.borderColor &&
          borderWidth == other.borderWidth &&
          iconColor == other.iconColor &&
          iconSize == other.iconSize &&
          boxAspectRatio == other.boxAspectRatio;
}
