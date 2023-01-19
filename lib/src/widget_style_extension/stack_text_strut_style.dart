import 'package:flutter/widgets.dart';
import 'package:stack_board/src/helpers/as_t.dart';
import 'package:stack_board/src/helpers/ex_enum.dart';

class StackTextStrutStyle {
  StackTextStrutStyle({
    this.fontFamily,
    this.fontFamilyFallback,
    this.fontSize,
    this.height,
    this.leadingDistribution,
    this.leading,
    this.fontWeight,
    this.fontStyle,
    this.forceStrutHeight,
  });

  factory StackTextStrutStyle.fromJson(Map<String, dynamic> data) {
    return StackTextStrutStyle(
      fontFamily: asNullT<String?>(data['fontFamily']),
      fontFamilyFallback: asNullT<String?>(data['fontFamilyFallback'])?.split(','),
      fontSize: asNullT<double?>(data['fontSize']),
      height: asNullT<double?>(data['height']),
      leadingDistribution: ExEnum.tryParse<TextLeadingDistribution>(
          TextLeadingDistribution.values, asNullT<String?>(data['leadingDistribution'])),
      leading: asNullT<double?>(data['leading']),
      fontWeight: ExEnum.tryParse<FontWeight>(FontWeight.values, asNullT<String?>(data['fontWeight'])),
      fontStyle: ExEnum.tryParse<FontStyle>(FontStyle.values, asNullT<String?>(data['fontStyle'])),
      forceStrutHeight: asNullT<bool?>(data['forceStrutHeight']),
    );
  }

  final String? fontFamily;
  final List<String>? fontFamilyFallback;
  final double? fontSize;
  final double? height;
  final TextLeadingDistribution? leadingDistribution;
  final double? leading;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final bool? forceStrutHeight;

  StrutStyle get style {
    return StrutStyle(
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      fontSize: fontSize,
      height: height,
      leadingDistribution: leadingDistribution,
      leading: leading,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      forceStrutHeight: forceStrutHeight,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (fontFamily != null) 'fontFamily': fontFamily,
      if (fontFamilyFallback != null) 'fontFamilyFallback': fontFamilyFallback?.join(','),
      if (fontSize != null) 'fontSize': fontSize,
      if (height != null) 'height': height,
      if (leadingDistribution != null) 'leadingDistribution': leadingDistribution.toString(),
      if (leading != null) 'leading': leading,
      if (fontWeight != null) 'fontWeight': fontWeight,
      if (fontStyle != null) 'fontStyle': fontStyle,
      if (forceStrutHeight != null) 'forceStrutHeight': forceStrutHeight,
    };
  }
}
