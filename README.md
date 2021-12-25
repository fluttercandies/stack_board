# Stack Board

A Flutter package of custom stack board. 

[![pub package](https://img.shields.io/pub/v/stack_board?logo=dart&label=stable&style=flat-square)](https://pub.dev/packages/stack_board)
[![GitHub stars](https://img.shields.io/github/stars/fluttercandies/stack_board?logo=github&style=flat-square)](https://github.com/fluttercandies/stack_board/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/fluttercandies/stack_board?logo=github&style=flat-square)](https://github.com/fluttercandies/stack_board/network/members)
[![CodeFactor](https://img.shields.io/codefactor/grade/github/fluttercandies/stack_board?logo=codefactor&logoColor=%23ffffff&style=flat-square)](https://www.codefactor.io/repository/github/fluttercandies/stack_board)
<a target="_blank" href="https://jq.qq.com/?_wv=1027&k=5bcc0gy"><img border="0" src="https://pub.idqqimg.com/wpa/images/group.png" alt="FlutterCandies" title="FlutterCandies"></a>

<br>

## 效果预览

预览网址:[https://stack.liugl.cn](https://stack.liugl.cn)

---

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

<img src="https://raw.githubusercontent.com/fluttercandies/stack_board/master/preview/text.gif" height=400>

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

<img src="https://raw.githubusercontent.com/fluttercandies/stack_board/master/preview/img.gif" height=400>

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

<img src="https://raw.githubusercontent.com/fluttercandies/stack_board/master/preview/draw.gif" height=400>

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

### 添加自定义Widget

<br>

<img src="https://raw.githubusercontent.com/fluttercandies/stack_board/master/preview/cw.gif" height=400>

<br>

```dart
_boardController.add(
    StackBoardItem(
        child: const Text(
            'Custom Widget',
            style: TextStyle(color: Colors.black),
        ),
        onDel: _onDel,
    ),
);
```


---

<details>
  <summary>_onDel</summary>

```dart
/// 删除拦截
Future<bool> _onDel() async {
    final bool? r = await showDialog<bool>(
        context: context,
        builder: (_) {
            return Center(
                child: SizedBox(
                    width: 400,
                    child: Material(
                        child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                    const Padding(
                                        padding: EdgeInsets.only(top: 10, bottom: 60),
                                        child: Text('确认删除?'),
                                    ),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                            IconButton(
                                                onPressed: () => Navigator.pop(context, true),
                                                icon: const Icon(Icons.check)),
                                            IconButton(
                                                onPressed: () => Navigator.pop(context, false),
                                                icon: const Icon(Icons.clear)),
                                        ],
                                    ),
                                ],
                            ),
                        ),
                    ),
                ),
            );
        },
    );

    return r ?? false;
}
```

</details> 

---

<br>

### 添加自定义item

<br>

<img src="https://raw.githubusercontent.com/fluttercandies/stack_board/master/preview/stack.gif" height=400>

<br>

> 1.继承自StackBoardItem
```dart
///自定义类型 Custom item type
class CustomItem extends StackBoardItem {
  const CustomItem({
    required this.color,
    Future<bool> Function()? onDel,
    int? id, // <==== must
  }) : super(
          child: const Text('CustomItem'),
          onDel: onDel,
          id: id, // <==== must
        );

  final Color? color;

  @override // <==== must
  CustomItem copyWith({
    CaseStyle? caseStyle,
    Widget? child,
    int? id,
    Future<bool> Function()? onDel,
    dynamic Function(bool)? onEdit,
    bool? tapToEdit,
    Color? color,
  }) =>
      CustomItem(
        onDel: onDel,
        id: id,
        color: color ?? this.color,
      );
}
```
> 2.使用controller添加
```dart
import 'dart:math' as math;

...

_boardController.add<CustomItem>(
    CustomItem(
        color: Color((math.Random().nextDouble() * 0xFFFFFF).toInt()),
        onDel: () async => true,
    ),
);
```
> 3.使用customBuilder构建
```dart
StackBoard(
    controller: _boardController,
        /// 如果使用了继承于StackBoardItem的自定义item
        /// 使用这个接口进行重构
    customBuilder: (StackBoardItem t) {
        if (t is CustomItem) {
            return ItemCase(
                key: Key('StackBoardItem${t.id}'), // <==== must
                isCenter: false,
                onDel: () async => _boardController.remove(t.id),
                onTap: () => _boardController.moveItemToTop(t.id),
                caseStyle: const CaseStyle(
                    borderColor: Colors.grey,
                    iconColor: Colors.white,
                ),
                child: Container(
                    width: 100,
                    height: 100,
                    color: t.color,
                    alignment: Alignment.center,
                    child: const Text(
                        'Custom item',
                        style: TextStyle(color: Colors.white),
                    ),
                ),
            );
        }
    },
)
```

<br>

## 2.使用ItemCase进行完全自定义

<br>

```dart
Stack(
    children: <Widget>[
        ItemCase(
            isCenter: false,
            child: const Text('Custom case'),
            onDel: () async {},
            onOffsetChanged: (Offset offset) {},
            onSizeChanged: (Size size) {},
        ),
    ],
)
```





