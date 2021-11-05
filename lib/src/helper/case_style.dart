import 'package:flutter/material.dart';

///操作壳样式
class CaseStyle {
  const CaseStyle({
    this.borderColor = Colors.white,
    this.borderWidth = 1,
    this.iconColor,
    this.iconSize = 20,
    this.boxAspectRatio,
  });

  final Color borderColor;
  final double borderWidth;
  final Color? iconColor;
  final double iconSize;
  final double? boxAspectRatio;
}
