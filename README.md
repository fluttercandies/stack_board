# Stack Board

A Flutter package of custom stack board. 

[![pub package](https://img.shields.io/pub/v/stack_board?logo=dart&label=stable&style=flat-square)](https://pub.dev/packages/stack_board)
[![GitHub stars](https://img.shields.io/github/stars/fluttercandies/stack_board?logo=github&style=flat-square)](https://github.com/fluttercandies/stack_board/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/fluttercandies/stack_board?logo=github&style=flat-square)](https://github.com/fluttercandies/stack_board/network/members)
[![CodeFactor](https://img.shields.io/codefactor/grade/github/fluttercandies/stack_board?logo=codefactor&logoColor=%23ffffff&style=flat-square)](https://www.codefactor.io/repository/github/fluttercandies/stack_board)
<a target="_blank" href="https://jq.qq.com/?_wv=1027&k=5bcc0gy"><img border="0" src="https://pub.idqqimg.com/wpa/images/group.png" alt="FlutterCandies" title="FlutterCandies"></a>

<br>

## 1.使用 StackBoardController

<br>

```dart
import 'package:stack_board/stack_board.dart';

StackBoard(
    controller: _boardController,
    ///添加背景
    background: const ColoredBox(color: Colors.grey),
),
```

### 添加自适应文本

<br>

<img src="https://raw.githubusercontent.com/xSILENCEx/project_images/main/stack_board/sb_txt.gif" height=400>

<br>

```dart
_boardController.add(
    const AdaptiveText(
        'Flutter Candies',
        tapToEdit: true,
        style: TextStyle(fontWeight: FontWeight.bold),
    ),
);
```

<br>

### 添加自适应图片

<br>

<img src="https://raw.githubusercontent.com/xSILENCEx/project_images/main/stack_board/sb_image.gif" height=400>

<br>

```dart
_boardController.add(
    StackBoardItem(
        child: Image.network('https://avatars.githubusercontent.com/u/47586449?s=200&v=4'),
    ),
);
```

<br>

### 添加画板

<br>

<img src="https://raw.githubusercontent.com/xSILENCEx/project_images/main/stack_board/sb_draw.gif" height=400>

<br>

```dart
_boardController.add(
    const StackDrawing(
        caseStyle: CaseStyle(
            borderColor: Colors.grey,
            iconColor: Colors.white,
            boxAspectRatio: 1,
        ),
    ),
);
```

<br>

### 添加自定义item

<br>

<img src="https://raw.githubusercontent.com/xSILENCEx/project_images/main/stack_board/sb_custom.gif" height=400>

<br>

> 1.继承自 StackItemContent 和 StackItem
```dart
class ColorContent extends StackItemContent {
  ColorContent({required this.color});

  Color color;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'color': color.value,
    };
  }
}

class ColorStackItem extends StackItem<ColorContent> {
  ColorStackItem({
    required Size size,
    String? id,
    Offset? offset,
    double? angle,
    StackItemStatus? status,
    ColorContent? content,
  }) : super(
          id: id,
          size: size,
          offset: offset,
          angle: angle,
          status: status,
          content: content,
        );

  @override
  ColorStackItem copyWith({
    Size? size,
    Offset? offset,
    double? angle,
    StackItemStatus? status,
    ColorContent? content,
  }) {
    return ColorStackItem(
      id: id, // <= must !!
      size: size ?? this.size,
      offset: offset ?? this.offset,
      angle: angle ?? this.angle,
      status: status ?? this.status,
      content: content ?? this.content,
    );
  }
}
```
> 2.使用controller添加
```dart
import 'dart:math' as math;

...

/// Add custom item
void _addCustomItem() {
    final Color color = Colors.primaries[Random().nextInt(Colors.primaries.length)];
    _boardController.addItem(
        ColorStackItem(
        size: const Size.square(100),
        content: ColorContent(color: color),
        ),
    );
}
```
> 3.使用customBuilder构建
```dart
StackBoard(
    controller: _boardController,
        /// 如果使用了继承于StackBoardItem的自定义item
        /// 使用这个接口进行重构
      customBuilder: (StackItem<StackItemContent> item) {
          if (...) {

           ...

          } else if (item is ColorStackItem) {
            return Container(
              width: item.size.width,
              height: item.size.height,
              color: item.content?.color,
            );
          }

          ...
        },
)
```



