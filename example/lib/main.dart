import 'package:flutter/material.dart';
import 'package:stack_board/stack_board.dart';

///自定义类型 Custom item type
class CustomItem extends StackBoardItem {
  const CustomItem({
    Future<bool> Function()? onDel,
    int? id, // <==== must
  }) : super(
          child: const Text('CustomItem'),
          onDel: onDel,
          id: id, // <==== must
        );

  @override // <==== must
  CustomItem copyWith({
    CaseStyle? caseStyle,
    Widget? child,
    int? id,
    Future<bool> Function()? onDel,
    dynamic Function(bool)? onEdit,
  }) =>
      CustomItem(onDel: onDel, id: id);
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

  ///删除拦截
  Future<bool> _onDel() async {
    final bool? r = await showDialog<bool>(
      context: context,
      builder: (_) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100),
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
      appBar: AppBar(title: const Text('Stack Board Demo')),
      backgroundColor: Colors.blueGrey,
      body: StackBoard(
        controller: _boardController,

        ///背景
        background: const ColoredBox(color: Colors.grey),

        ///如果使用了继承于StackBoardItem的自定义item
        ///使用这个接口进行重构
        customBuilder: (StackBoardItem t) {
          if (t is CustomItem) {
            return ItemCase(
              key: Key('CustomStackItem${t.id}'), // <==== must
              isCenter: false,
              onDel: () async => _boardController.remove(t.id),
              child: Container(width: 100, height: 100, color: Colors.blue),
            );
          }
        },
      ),
      floatingActionButton: Row(
        children: <Widget>[
          const SizedBox(width: 25),
          FloatingActionButton(
            onPressed: () {
              _boardController.add(const AdaptiveText('自适应文本'));
            },
            child: const Icon(Icons.border_color),
          ),
          _spacer,
          FloatingActionButton(
            onPressed: () {
              _boardController.add(
                const AdaptiveImage('https://flutter.dev/assets/images/shared/brand/flutter/logo/flutter-lockup.png'),
              );
            },
            child: const Icon(Icons.image),
          ),
          _spacer,
          FloatingActionButton(
            onPressed: () {
              _boardController.add(const StackDrawing());
            },
            child: const Icon(Icons.color_lens),
          ),
          _spacer,
          FloatingActionButton(
            onPressed: () {
              _boardController.add(
                StackBoardItem(
                  child: const Text('Custom Widget', style: TextStyle(color: Colors.white)),
                  onDel: _onDel,
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
                  onDel: () async => true,
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
          const Spacer(),
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
          onEdit: (bool isEditing) {},
          onOffsetChanged: (Offset offset) {},
          onSizeChanged: (Size size) {},
        ),
      ],
    );
  }
}
