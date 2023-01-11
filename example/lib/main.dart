import 'package:flutter/material.dart';
import 'package:stack_board/flutter_stack_board.dart';
import 'package:stack_board/stack_board_item.dart';
import 'package:stack_board/stack_case.dart';
import 'package:stack_board/stack_items.dart';

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
  Future<void> _onDel(StackItem<StackItemContent> item) async {
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

    if (r == true) {
      _boardController.removeById(item.id);
    }
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
        onDel: _onDel,
        controller: _boardController,
        caseStyle: const CaseStyle(
          borderColor: Colors.grey,
          iconColor: Colors.white,
        ),

        /// 背景
        background: ColoredBox(color: Colors.grey[100]!),
        customBuilder: (StackItem<StackItemContent> item) {
          if (item is StackTextItem) {
            return StackTextCase(
              item: item,
              onChanged: (String str) => _boardController.updateItem(
                item.copyWith(
                  contentGenerators: (TextItemContent oldContent) => oldContent.copyWith(data: str),
                ),
              ),
            );
          } else if (item is StackDrawItem) {
            return StackDrawCase(item: item);
          }

          return const SizedBox.shrink();
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
                      _boardController.addItem(
                        StackTextItem(
                          size: const Size(200, 100),
                          content: TextItemContent(data: '哈哈哈哈哈'),
                        ),
                      );
                    },
                    child: const Icon(Icons.border_color),
                  ),
                  _spacer,
                  FloatingActionButton(
                    onPressed: () {},
                    child: const Icon(Icons.image),
                  ),
                  _spacer,
                  FloatingActionButton(
                    onPressed: () {
                      _boardController.addItem(StackDrawItem(size: const Size.square(300)));
                    },
                    child: const Icon(Icons.color_lens),
                  ),
                  _spacer,
                  FloatingActionButton(
                    onPressed: () {
                      // _boardController.add(
                      //   StackBoardItem(
                      //     child: const Text(
                      //       'Custom Widget',
                      //       style: TextStyle(color: Colors.black),
                      //     ),
                      //     onDel: _onDel,
                      //     // caseStyle: const CaseStyle(initOffset: Offset(100, 100)),
                      //   ),
                      // );
                    },
                    child: const Icon(Icons.add_box),
                  ),
                  _spacer,
                  FloatingActionButton(
                    onPressed: () {
                      // _boardController.add<CustomItem>(
                      //   CustomItem(
                      //     color: Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
                      //     onDel: () async => true,
                      //   ),
                      // );
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

// class ItemCaseDemo extends StatefulWidget {
//   const ItemCaseDemo({Key? key}) : super(key: key);

//   @override
//   _ItemCaseDemoState createState() => _ItemCaseDemoState();
// }

// class _ItemCaseDemoState extends State<ItemCaseDemo> {
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: <Widget>[
//         ItemCase(
//           isCenter: false,
//           child: const Text('Custom case'),
//           onDel: () async {},
//           onOperatStateChanged: (OperatingState operatState) => null,
//           onOffsetChanged: (Offset offset) => null,
//           onSizeChanged: (Size size) => null,
//         ),
//       ],
//     );
//   }
// }
