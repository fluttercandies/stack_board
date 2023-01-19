import 'package:flutter/material.dart';
import 'package:stack_board/helpers.dart';
import 'package:stack_board/src/core/stack_board_item/stack_item.dart';
import 'package:stack_board/src/core/stack_board_item/stack_item_content.dart';
import 'package:stack_board/src/core/stack_board_item/stack_item_status.dart';
import 'package:stack_board/src/widget_style_extension/ex_offset.dart';
import 'package:stack_board/src/widget_style_extension/ex_size.dart';

class ImageItemContent extends StackItemContent {
  ImageItemContent({
    this.url,
    this.assetName,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.width,
    this.height,
    this.color,
    this.colorBlendMode,
    this.fit,
    this.repeat = ImageRepeat.noRepeat,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
    this.isAntiAlias = false,
    this.filterQuality = FilterQuality.low,
  }) {
    _init();
  }

  factory ImageItemContent.fromJson(Map<String, dynamic> json) {
    return ImageItemContent(
      url: asT<String>(json['url']),
      assetName: asT<String>(json['assetName']),
      semanticLabel: asT<String>(json['semanticLabel']),
      excludeFromSemantics: asT<bool>(json['excludeFromSemantics'], false),
      width: asT<double>(json['width']),
      height: asT<double>(json['height']),
      color: Color(asT<int>(json['color'])),
      colorBlendMode: BlendMode.values[asT<int>(json['colorBlendMode'])],
      fit: BoxFit.values[asT<int>(json['fit'])],
      repeat: ImageRepeat.values[asT<int>(json['repeat'])],
      matchTextDirection: asT<bool>(json['matchTextDirection'], false),
      gaplessPlayback: asT<bool>(json['gaplessPlayback'], false),
      isAntiAlias: asT<bool>(json['isAntiAlias'], false),
      filterQuality: FilterQuality.values[asT<int>(json['filterQuality'])],
    );
  }

  void _init() {
    if (url != null && assetName != null) {
      throw Exception('url and assetName can not be set at the same time');
    }

    if (url == null && assetName == null) {
      throw Exception('url and assetName can not be null at the same time');
    }

    if (url != null) {
      _image = NetworkImage(url!);
    } else if (assetName != null) {
      _image = AssetImage(assetName!);
    }
  }

  late ImageProvider _image;
  String? url;
  String? assetName;
  String? semanticLabel;
  bool excludeFromSemantics;
  double? width;
  double? height;
  Color? color;
  BlendMode? colorBlendMode;
  BoxFit? fit;
  ImageRepeat repeat;
  bool matchTextDirection;
  bool gaplessPlayback;
  bool isAntiAlias;
  FilterQuality filterQuality;

  ImageProvider get image => _image;

  void setRes({
    String? url,
    String? assetName,
  }) {
    if (url != null) this.url = url;
    if (assetName != null) this.assetName = assetName;
    _init();
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (url != null) 'url': url,
      if (assetName != null) 'assetName': assetName,
      if (semanticLabel != null) 'semanticLabel': semanticLabel,
      'excludeFromSemantics': excludeFromSemantics,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (color != null) 'color': color?.value,
      if (colorBlendMode != null) 'colorBlendMode': colorBlendMode?.index,
      if (fit != null) 'fit': fit?.index,
      'repeat': repeat.index,
      'matchTextDirection': matchTextDirection,
      'gaplessPlayback': gaplessPlayback,
      'isAntiAlias': isAntiAlias,
      'filterQuality': filterQuality.index,
    };
  }
}

class StackImageItem extends StackItem<ImageItemContent> {
  StackImageItem({
    required ImageItemContent? content,
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

  factory StackImageItem.fromJson(Map<String, dynamic> data) {
    return StackImageItem(
      id: data['id'] == null ? null : asT<String>(data['id']),
      angle: data['angle'] == null ? null : asT<double>(data['angle']),
      size: data['size'] == null ? null : jsonToSize(asMap(data['size'])),
      offset: data['offset'] == null ? null : jsonToOffset(asMap(data['offset'])),
      status: StackItemStatus.values[data['status'] as int],
      content: ImageItemContent.fromJson(asMap(data['content'])),
    );
  }

  void setUrl(String url) {
    content?.setRes(url: url);
  }

  void setAssetName(String assetName) {
    content?.setRes(assetName: assetName);
  }

  @override
  StackImageItem copyWith({
    Size? size,
    Offset? offset,
    double? angle,
    StackItemStatus? status,
    ImageItemContent? content,
  }) {
    return StackImageItem(
      id: id,
      size: size ?? this.size,
      offset: offset ?? this.offset,
      angle: angle ?? this.angle,
      status: status ?? this.status,
      content: content ?? this.content,
    );
  }
}
