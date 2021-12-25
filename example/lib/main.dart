import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:stack_board/stack_board.dart';

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

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late StackBoardController _boardController;

  @override
  void initState() {
    super.initState();
    _boardController = StackBoardController();
  }

  @override
  void dispose() {
    _boardController.dispose();
    super.dispose();
  }

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
                        IconButton(onPressed: () => Navigator.pop(context, true), icon: const Icon(Icons.check)),
                        IconButton(onPressed: () => Navigator.pop(context, false), icon: const Icon(Icons.clear)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Stack Board Demo'),
        elevation: 0,
      ),
      body: StackBoard(
        controller: _boardController,

        caseStyle: const CaseStyle(
          borderColor: Colors.grey,
          iconColor: Colors.white,
        ),

        /// 背景
        background: ColoredBox(color: Colors.grey[100]!),

        /// 点击取消全部选中状态
        /// tapToCancelAllItem: true,

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
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  const SizedBox(width: 25),
                  FloatingActionButton(
                    onPressed: () {
                      _boardController.add(
                        const AdaptiveText(
                          'Flutter Candies',
                          tapToEdit: true,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                    child: const Icon(Icons.border_color),
                  ),
                  _spacer,
                  FloatingActionButton(
                    onPressed: () {
                      _boardController.add(
                        StackBoardItem(
                          child: Image.network('https://avatars.githubusercontent.com/u/47586449?s=200&v=4'),
                        ),
                      );
                    },
                    child: const Icon(Icons.image),
                  ),
                  _spacer,
                  FloatingActionButton(
                    onPressed: () {
                      _boardController.add(
                        const StackDrawing(
                          caseStyle: CaseStyle(
                            borderColor: Colors.grey,
                            iconColor: Colors.white,
                            boxAspectRatio: 1,
                          ),
                        ),
                      );
                    },
                    child: const Icon(Icons.color_lens),
                  ),
                  _spacer,
                  FloatingActionButton(
                    onPressed: () {
                      _boardController.add(
                        StackBoardItem(
                          child: const Text(
                            'Custom Widget',
                            style: TextStyle(color: Colors.black),
                          ),
                          onDel: _onDel,
                          // caseStyle: const CaseStyle(initOffset: Offset(100, 100)),
                        ),
                      );
                    },
                    child: const Icon(Icons.add_box),
                  ),
                  _spacer,
                  FloatingActionButton(
                    onPressed: () {
                      _boardController.add<CustomItem>(
                        CustomItem(
                          color: Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
                          onDel: () async => true,
                        ),
                      );
                    },
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ),
          FloatingActionButton(
            onPressed: () => _boardController.clear(),
            child: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget get _spacer => const SizedBox(width: 5);
}

class ItemCaseDemo extends StatefulWidget {
  const ItemCaseDemo({Key? key}) : super(key: key);

  @override
  _ItemCaseDemoState createState() => _ItemCaseDemoState();
}

class _ItemCaseDemoState extends State<ItemCaseDemo> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ItemCase(
          isCenter: false,
          child: const Text('Custom case'),
          onDel: () async {},
          onOperatStateChanged: (OperatState operatState) {},
          onOffsetChanged: (Offset offset) {},
          onSizeChanged: (Size size) {},
        ),
      ],
    );
  }
}
