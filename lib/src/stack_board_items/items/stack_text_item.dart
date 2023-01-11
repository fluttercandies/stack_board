import 'package:flutter/painting.dart';
import 'package:stack_board/src/core/stack_board_item/stack_item.dart';
import 'package:stack_board/src/core/stack_board_item/stack_item_content.dart';
import 'package:stack_board/src/core/stack_board_item/stack_item_status.dart';
import 'package:stack_board/src/helpers/as_t.dart';
import 'package:stack_board/src/helpers/ex_enum.dart';
import 'package:widget_style_extension/widget_style_extension.dart';

/// TextItemContent
class TextItemContent implements StackItemContent {
  TextItemContent({
    this.data,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  });

  factory TextItemContent.fromJson(Map<String, dynamic> data) {
    return TextItemContent(
      data: data['data'] == null ? null : asT<String>(data['data']),
      style: data['style'] == null ? null : jsonToTextStyle(asMap(data['style'])),
      strutStyle: data['strutStyle'] == null ? null : StackTextStrutStyle.fromJson(asMap(data['strutStyle'])),
      textAlign: ExEnum.tryParse<TextAlign>(TextAlign.values, asT<String>(data['textAlign'])),
      textDirection: ExEnum.tryParse<TextDirection>(TextDirection.values, asT<String>(data['textDirection'])),
      locale: data['locale'] == null ? null : jsonToLocale(asMap(data['locale'])),
      softWrap: data['softWrap'] == null ? null : asT<bool>(data['softWrap']),
      overflow: ExEnum.tryParse<TextOverflow>(TextOverflow.values, asT<String>(data['overflow'])),
      textScaleFactor: data['textScaleFactor'] == null ? null : asT<double>(data['textScaleFactor']),
      maxLines: data['maxLines'] == null ? null : asT<int>(data['maxLines']),
      semanticsLabel: data['semanticsLabel'] == null ? null : asT<String>(data['semanticsLabel']),
      textWidthBasis: ExEnum.tryParse<TextWidthBasis>(TextWidthBasis.values, asT<String>(data['textWidthBasis'])),
      textHeightBehavior:
          data['textHeightBehavior'] == null ? null : jsonToTextHeightBehavior(asMap(data['textHeightBehavior'])),
      selectionColor: data['selectionColor'] == null ? null : Color(asT<int>(data['selectionColor'])),
    );
  }
  final String? data;
  final TextStyle? style;
  final StackTextStrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final double? textScaleFactor;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;

  TextItemContent copyWith({
    String? data,
    TextStyle? style,
    StackTextStrutStyle? strutStyle,
    TextAlign? textAlign,
    TextDirection? textDirection,
    Locale? locale,
    bool? softWrap,
    TextOverflow? overflow,
    double? textScaleFactor,
    int? maxLines,
    String? semanticsLabel,
    TextWidthBasis? textWidthBasis,
    TextHeightBehavior? textHeightBehavior,
    Color? selectionColor,
  }) {
    return TextItemContent(
      data: data ?? this.data,
      style: style ?? this.style,
      strutStyle: strutStyle ?? this.strutStyle,
      textAlign: textAlign ?? this.textAlign,
      textDirection: textDirection ?? this.textDirection,
      locale: locale ?? this.locale,
      softWrap: softWrap ?? this.softWrap,
      overflow: overflow ?? this.overflow,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      maxLines: maxLines ?? this.maxLines,
      semanticsLabel: semanticsLabel ?? this.semanticsLabel,
      textWidthBasis: textWidthBasis ?? this.textWidthBasis,
      textHeightBehavior: textHeightBehavior ?? this.textHeightBehavior,
      selectionColor: selectionColor ?? this.selectionColor,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (data != null) 'data': data,
      if (style != null) 'style': style?.toJson(),
      if (strutStyle != null) 'strutStyle': strutStyle?.toJson(),
      if (textAlign != null) 'textAlign': textAlign?.toString(),
      if (textDirection != null) 'textDirection': textDirection?.toString(),
      if (locale != null) 'locale': locale?.toJson(),
      if (softWrap != null) 'softWrap': softWrap,
      if (overflow != null) 'overflow': overflow?.toString(),
      if (textScaleFactor != null) 'textScaleFactor': textScaleFactor,
      if (maxLines != null) 'maxLines': maxLines,
      if (semanticsLabel != null) 'semanticsLabel': semanticsLabel,
      if (textWidthBasis != null) 'textWidthBasis': textWidthBasis?.toString(),
      if (textHeightBehavior != null) 'textHeightBehavior': textHeightBehavior?.toJson(),
      if (selectionColor != null) 'selectionColor': selectionColor?.value,
    };
  }
}

/// StackTextItem
class StackTextItem extends StackItem<TextItemContent> {
  StackTextItem({
    TextItemContent? content,
    String? id,
    double? angle,
    Size? size,
    Offset? offset,
    StackItemStatus? status,
  }) : super(
          id: id,
          size: size,
          offset: offset,
          angle: angle,
          status: status,
          content: content,
        );

  factory StackTextItem.fromJson(Map<String, dynamic> data) {
    return StackTextItem(
      id: data['id'] == null ? null : asT<String>(data['id']),
      angle: data['angle'] == null ? null : asT<double>(data['angle']),
      size: data['size'] == null ? null : jsonToSize(asMap(data['size'])),
      offset: data['offset'] == null ? null : jsonToOffset(asMap(data['offset'])),
      status: StackItemStatus.values[data['status'] as int],
      content: TextItemContent.fromJson(asMap(data['content'])),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'type': 'StackTextItem',
      if (angle != null) 'angle': angle,
      if (size != null) 'size': size?.toJson(),
      if (offset != null) 'offset': offset?.toJson(),
      if (status != null) 'status': status?.index,
      if (content != null) 'content': content?.toJson(),
    };
  }

  @override
  StackTextItem copyWith({
    double? angle,
    Size? size,
    Offset? offset,
    StackItemStatus? status,
    TextItemContent? content,
  }) {
    return StackTextItem(
      id: id,
      angle: angle ?? this.angle,
      size: size ?? this.size,
      offset: offset ?? this.offset,
      status: status ?? this.status,
      content: content ?? this.content,
    );
  }
}
