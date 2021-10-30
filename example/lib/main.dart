import 'package:flutter/material.dart';
import 'package:stack_board/stack_board.dart';

void main() {
  runApp(const MyApp());
}

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
      backgroundColor: Colors.grey,
      appBar: AppBar(title: const Text('Package example app')),
      body: StackBoard(
        controller: _boardController,
        background: const ColoredBox(color: Colors.grey),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () {
              _boardController.add(const AdaptiveText('自适应文本'));
            },
            child: const Icon(Icons.border_color),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () {
              _boardController.add(
                const AdaptiveImage('https://flutter.dev/assets/images/shared/brand/flutter/logo/flutter-lockup.png'),
              );
            },
            child: const Icon(Icons.image),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () {
              _boardController.add(const StackDrawing());
            },
            child: const Icon(Icons.color_lens),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () {
              _boardController.add(
                StackBoardItem(
                  child: const Text('XXXXXXXX XXXXX Test1', style: TextStyle(color: Colors.white)),
                  onDel: _onDel,
                ),
              );
            },
            child: const Icon(Icons.text_format),
          ),
        ],
      ),
    );
  }
}
