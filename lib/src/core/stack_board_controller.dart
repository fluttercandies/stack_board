import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:stack_board/src/core/stack_board_item/stack_item.dart';
import 'package:stack_board/src/core/stack_board_item/stack_item_content.dart';
import 'package:stack_board/src/core/stack_board_item/stack_item_status.dart';
import 'package:stack_board/src/helpers/safe_value_notifier.dart';

class StackConfig {
  StackConfig({
    required this.data,
    required this.indexMap,
  });

  factory StackConfig.init() => StackConfig(
        data: <StackItem<StackItemContent>>[],
        indexMap: <String, int>{},
      );

  final List<StackItem<StackItemContent>> data;
  final Map<String, int> indexMap;

  StackItem<StackItemContent> operator [](String id) => data[indexMap[id]!];

  StackConfig copyWith({
    List<StackItem<StackItemContent>>? data,
    Map<String, int>? indexMap,
  }) {
    return StackConfig(
      data: data ?? this.data,
      indexMap: indexMap ?? this.indexMap,
    );
  }
}

@immutable
// ignore: must_be_immutable
class StackBoardController extends SafeValueNotifier<StackConfig> {
  StackBoardController({String? tag})
      : _tag = tag,
        super(StackConfig.init());

  factory StackBoardController.def() => _defaultController;

  final String? _tag;

  // final Set<String> selected = <String>{};

  final Map<String, int> _indexMap = <String, int>{};

  static final StackBoardController _defaultController = StackBoardController(tag: 'def');

  List<StackItem<StackItemContent>> get innerData => value.data;

  Map<String, int> get _newIndexMap => Map<String, int>.from(_indexMap);

  StackItem<StackItemContent>? getById(String id) {
    if (!_indexMap.containsKey(id)) return null;
    return innerData[_indexMap[id]!];
  }

  int getIndexById(String id) {
    return _indexMap[id]!;
  }

  /// reorder index
  List<StackItem<StackItemContent>> _reorder(List<StackItem<StackItemContent>> data) {
    for (int i = 0; i < data.length; i++) {
      _indexMap[data[i].id] = i;
    }

    return data;
  }

  /// add item
  void addItem(StackItem<StackItemContent> item, {bool selectIt = false}) {
    if (innerData.contains(item)) {
      print('StackBoardController addItem: item already exists');
      return;
    }

    final List<StackItem<StackItemContent>> data = List<StackItem<StackItemContent>>.from(innerData);

    // 其它 item EditStatus 重置为 idle
    for (int i = 0; i < data.length; i++) {
      data[i] = data[i].copyWith(status: StackItemStatus.idle);
    }

    data.add(item);

    _indexMap[item.id] = data.length - 1;

    value = value.copyWith(data: data, indexMap: _newIndexMap);
  }

  /// remove item
  void removeItem(StackItem<StackItemContent> item) {
    final List<StackItem<StackItemContent>> data = List<StackItem<StackItemContent>>.from(innerData);

    data.remove(item);
    _indexMap.remove(item.id);

    _reorder(data);

    value = value.copyWith(data: data, indexMap: _newIndexMap);
  }

  /// remove item by id
  void removeById(String id) {
    if (!_indexMap.containsKey(id)) return;

    final List<StackItem<StackItemContent>> data = List<StackItem<StackItemContent>>.from(innerData);

    data.removeAt(_indexMap[id]!);
    _indexMap.remove(id);
    // selected.remove(id);

    value = value.copyWith(data: data, indexMap: _newIndexMap);
  }

  /// select only item
  void selectOne(String id) {
    if (!_indexMap.containsKey(id)) return;

    final int index = _indexMap[id]!;

    final StackItem<StackItemContent> item = innerData[index];

    if (index == innerData.length - 1 && item.status != StackItemStatus.idle) {
      return;
    }

    final List<StackItem<StackItemContent>> data = List<StackItem<StackItemContent>>.from(innerData);

    data.removeAt(index);

    // 全部 item EditStatus 重置为 idle
    for (int i = 0; i < data.length; i++) {
      final StackItem<StackItemContent> item = data[i];
      data[i] = item.copyWith(status: StackItemStatus.idle);
      _indexMap[item.id] = i;
    }

    data.add(item.copyWith(status: StackItemStatus.selected));
    _indexMap[item.id] = data.length - 1;
    // selected.add(item.id);

    value = value.copyWith(data: data, indexMap: _newIndexMap);
  }

  /// unselect all items
  void unSelectAll() {
    final List<StackItem<StackItemContent>> data = List<StackItem<StackItemContent>>.from(innerData);

    for (int i = 0; i < data.length; i++) {
      final StackItem<StackItemContent> item = data[i];
      data[i] = item.copyWith(status: StackItemStatus.idle);
    }

    // selected.clear();

    value = value.copyWith(data: data);
  }

  /// update basic config
  void updateBasic(String id, {Size? size, Offset? offset, double? angle, StackItemStatus? status}) {
    if (!_indexMap.containsKey(id)) return;

    final List<StackItem<StackItemContent>> data = List<StackItem<StackItemContent>>.from(innerData);

    data[_indexMap[id]!] = data[_indexMap[id]!].copyWith(
      size: size,
      offset: offset,
      angle: angle,
      status: status,
    );

    value = value.copyWith(data: data);
  }

  /// updateItem
  void updateItem(StackItem<StackItemContent> item) {
    if (!_indexMap.containsKey(item.id)) return;

    final List<StackItem<StackItemContent>> data = List<StackItem<StackItemContent>>.from(innerData);

    data[_indexMap[item.id]!] = item;

    value = value.copyWith(data: data);
  }

  /// * index Item index
  /// * id Item id
  /// * update Update function
  // void updateItem({
  //   int? index,
  //   String? id,
  //   StackItem<StackItemContent> Function(StackItem<StackItemContent> oldItem)? update,
  // }) {
  //   assert(index != null || id != null, 'index or id must not be null');

  //   final List<StackItem<StackItemContent>> data = List<StackItem<StackItemContent>>.from(innerData);

  //   final StackItem<StackItemContent>? item = index != null ? data[index] : getById(id!);

  //   assert(item != null, 'item not found');

  //   final StackItem<StackItemContent>? newItem = update?.call(item!);

  //   assert(newItem != null, 'newItem must not be null');

  //   if (index != null) {
  //     data[index] = newItem!;
  //   } else {
  //     data[data.indexOf(item!)] = newItem!;
  //   }

  //   value = value.copyWith(data: data);
  // }

  /// clear
  void clear() {
    value = StackConfig.init();
    _indexMap.clear();
  }

  @override
  int get hashCode => _tag.hashCode;

  @override
  bool operator ==(Object other) => other is StackBoardController && _tag == other._tag;

  @override
  void dispose() {
    if (_tag == 'def') {
      assert(false, 'default StackBoardController can not be disposed');
      return;
    }

    super.dispose();
  }
}
