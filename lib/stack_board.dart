library stack_board;

import 'package:flutter/material.dart';

import 'case_group/adaptive_image_case.dart';
import 'case_group/adaptive_text_case.dart';
import 'case_group/drawing_board_case.dart';
import 'case_group/item_case.dart';
import 'helper/case_style.dart';
import 'helper/safe_state.dart';
import 'item_group/adaptive_image.dart';
import 'item_group/adaptive_text.dart';
import 'item_group/stack_board_item.dart';
import 'item_group/stack_drawing.dart';

export 'item_group/adaptive_image.dart';
export 'item_group/adaptive_text.dart';
export 'item_group/stack_board_item.dart';
export 'item_group/stack_drawing.dart';

///层叠板
class StackBoard extends StatefulWidget {
  const StackBoard({
    Key? key,
    this.controller,
    this.background,
    this.caseStyle,
  }) : super(key: key);

  @override
  _StackBoardState createState() => _StackBoardState();

  final StackBoardController? controller;
  final Widget? background;
  final CaseStyle? caseStyle;
}

class _StackBoardState extends State<StackBoard> with SafeState<StackBoard> {
  late List<StackBoardItem> _children;
  int _lastId = 0;

  Key _getKey(int? id) => Key('StackBoardItem$id');

  @override
  void initState() {
    super.initState();
    _children = <StackBoardItem>[];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.controller?._stackBoardState = this;
  }

  ///添加一个
  void _add(StackBoardItem item) {
    if (_children.contains(item)) throw 'duplicate id';

    switch (item.runtimeType) {
      case AdaptiveText:
        _children.add((item as AdaptiveText).copyWith(
          id: item.id ?? _lastId,
          caseStyle: item.caseStyle ?? widget.caseStyle,
        ));
        break;
      case AdaptiveImage:
        _children.add((item as AdaptiveImage).copyWith(
          id: item.id ?? _lastId,
          caseStyle: item.caseStyle ?? widget.caseStyle,
        ));
        break;
      case StackDrawing:
        _children.add((item as StackDrawing).copyWith(
          id: item.id ?? _lastId,
          caseStyle: item.caseStyle ?? widget.caseStyle,
        ));
        break;
      default:
        _children.add(item.copyWith(
          id: item.id ?? _lastId,
          caseStyle: item.caseStyle ?? widget.caseStyle,
        ));
    }

    _lastId++;
    safeSetState(() {});
  }

  ///移除指定id item
  void _remove(int id) {
    _children.removeWhere((StackBoardItem b) => b.id == id);
    safeSetState(() {});
  }

  ///清理
  void _clear() {
    _children.clear();
    safeSetState(() {});
  }

  ///删除动作
  Future<void> _onDel(StackBoardItem box) async {
    final bool del = (await box.onDel?.call()) ?? true;
    if (del) _remove(box.id!);
  }

  @override
  Widget build(BuildContext context) {
    Widget _child;
    if (widget.background == null)
      _child = Stack(
        fit: StackFit.expand,
        children: _children.map((StackBoardItem box) => _buildItem(box)).toList(),
      );

    _child = Stack(
      fit: StackFit.expand,
      children: <Widget>[
        widget.background!,
        ..._children.map((StackBoardItem box) => _buildItem(box)).toList(),
      ],
    );

    return _child;
  }

  ///构建项
  Widget _buildItem(StackBoardItem box) {
    switch (box.runtimeType) {
      case AdaptiveText:
        return AdaptiveTextCase(
          key: _getKey(box.id),
          adaptiveText: box as AdaptiveText,
          onDel: () => _onDel(box),
        );
      case AdaptiveImage:
        return AdaptiveImageCase(
          key: _getKey(box.id),
          adaptiveImage: box as AdaptiveImage,
          onDel: () => _onDel(box),
        );
      case StackDrawing:
        return DrawingBoardCase(
          key: _getKey(box.id),
          stackDrawing: box as StackDrawing,
          onDel: () => _onDel(box),
        );
      default:
        return ItemCase(
          key: _getKey(box.id),
          child: box.child,
          onDel: () => _onDel(box),
          onEdit: box.onEdit,
          caseStyle: box.caseStyle,
        );
    }
  }
}

///控制器
class StackBoardController {
  _StackBoardState? _stackBoardState;

  ///检查是否加载
  void _check() {
    if (_stackBoardState == null) throw '_stackBoardState is empty';
  }

  ///添加一个
  void add(StackBoardItem item) {
    _check();
    _stackBoardState?._add(item);
  }

  ///移除
  void remove(int id) {
    _check();
    _stackBoardState?._remove(id);
  }

  ///清理全部
  void clear() {
    _check();
    _stackBoardState?._clear();
  }

  ///刷新
  void refresh() {
    _check();
    _stackBoardState?.safeSetState(() {});
  }

  ///销毁
  void dispose() {
    _stackBoardState = null;
  }
}
