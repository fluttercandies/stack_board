import 'package:flutter/painting.dart';
import 'package:stack_board/src/helpers/as_t.dart';
import 'package:stack_board/src/helpers/ex_enum.dart';
import 'ex_ locale.dart';

extension ExTextStyle on TextStyle {
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (color != null) 'color': color?.value,
      if (decoration != null) 'decoration': decoration?.toString(),
      if (decorationColor != null) 'decorationColor': decorationColor?.value,
      if (decorationStyle != null) 'decorationStyle': decorationStyle?.toString(),
      if (decorationThickness != null) 'decorationThickness': decorationThickness,
      if (fontWeight != null) 'fontWeight': fontWeight?.toString(),
      if (fontStyle != null) 'fontStyle': fontStyle?.toString(),
      if (fontFamily != null) 'fontFamily': fontFamily,
      if (fontFamilyFallback != null) 'fontFamilyFallback': fontFamilyFallback?.join(','),
      if (fontSize != null) 'fontSize': fontSize,
      if (letterSpacing != null) 'letterSpacing': letterSpacing,
      if (wordSpacing != null) 'wordSpacing': wordSpacing,
      if (textBaseline != null) 'textBaseline': textBaseline?.toString(),
      if (height != null) 'height': height,
      if (locale != null) 'locale': locale?.toJson(),
    };
  }
}

TextStyle? jsonToTextStyle(Map<String, dynamic> data) {
  return TextStyle(
    color: data['color'] == null ? null : Color(asT<int>(data['color'])),
    decoration: data['decoration'] == null ? null : stringToTextDecoration(asT<String>(data['decoration'])),
    decorationColor: data['decorationColor'] == null ? null : Color(asT<int>(data['decorationColor'])),
    decorationStyle:
        ExEnum.tryParse<TextDecorationStyle>(TextDecorationStyle.values, asT<String>(data['decorationStyle'])),
    decorationThickness: data['decorationThickness'] == null ? null : asT<double>(data['decorationThickness']),
    fontWeight: ExEnum.tryParse<FontWeight>(FontWeight.values, asT<String>(data['fontWeight'])),
    fontStyle: ExEnum.tryParse<FontStyle>(FontStyle.values, asT<String>(data['fontStyle'])),
    fontFamily: data['fontFamily'] == null ? null : asT<String>(data['fontFamily']),
    fontFamilyFallback: data['fontFamilyFallback'] == null ? null : asT<String>(data['fontFamilyFallback']).split(','),
    fontSize: data['fontSize'] == null ? null : asT<double>(data['fontSize']),
    letterSpacing: data['letterSpacing'] == null ? null : asT<double>(data['letterSpacing']),
    wordSpacing: data['wordSpacing'] == null ? null : asT<double>(data['wordSpacing']),
    textBaseline: ExEnum.tryParse(TextBaseline.values, asT<String>(data['textBaseline'])),
    height: data['height'] == null ? null : asT<double>(data['height']),
    locale: data['locale'] == null ? null : jsonToLocale(asMap(data['locale'])),
  );
}

TextDecoration? stringToTextDecoration(String data) {
  if (!data.contains('combine')) {
    switch (data) {
      case 'TextDecoration.none':
        return TextDecoration.none;
      case 'TextDecoration.underline':
        return TextDecoration.underline;
      case 'TextDecoration.overline':
        return TextDecoration.overline;
      case 'TextDecoration.lineThrough':
        return TextDecoration.lineThrough;
      default:
        return TextDecoration.none;
    }
  }

  final List<String> values = data.split('[')[1].split(']')[0].split(', ');
  final List<TextDecoration> decorations = <TextDecoration>[];
  for (final String value in values) {
    switch (value) {
      case 'underline':
        decorations.add(TextDecoration.underline);
        break;
      case 'overline':
        decorations.add(TextDecoration.overline);
        break;
      case 'lineThrough':
        decorations.add(TextDecoration.lineThrough);
        break;
      default:
        break;
    }
  }

  return TextDecoration.combine(decorations);
}
