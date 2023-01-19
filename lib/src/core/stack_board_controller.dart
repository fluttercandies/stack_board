import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:stack_board/src/core/stack_board_item/stack_item.dart';
import 'package:stack_board/src/core/stack_board_item/stack_item_content.dart';
import 'package:stack_board/src/core/stack_board_item/stack_item_status.dart';
import 'package:stack_board/src/helpers/ex_list.dart';
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
      : assert(tag != 'def', 'tag can not be "def"'),
        _tag = tag,
        super(StackConfig.init());

  factory StackBoardController.def() => _defaultController;

  final String? _tag;

  final Map<String, int> _indexMap = <String, int>{};

  static final StackBoardController _defaultController = StackBoardController(tag: 'def');

  List<StackItem<StackItemContent>> get innerData => value.data;

  Map<String, int> get _newIndexMap => Map<String, int>.from(_indexMap);

  /// * 通过 id 获取 item
  /// * get item by id
  StackItem<StackItemContent>? getById(String id) {
    if (!_indexMap.containsKey(id)) return null;
    return innerData[_indexMap[id]!];
  }

  /// * 通过 id 获取索引
  /// * get index by id
  int getIndexById(String id) {
    return _indexMap[id]!;
  }

  /// * 重排索引
  /// * reorder index
  List<StackItem<StackItemContent>> _reorder(List<StackItem<StackItemContent>> data) {
    for (int i = 0; i < data.length; i++) {
      _indexMap[data[i].id] = i;
    }

    return data;
  }

  /// * 添加 item
  /// * add item
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

  /// * 移除 item
  /// * remove item
  void removeItem(StackItem<StackItemContent> item) {
    final List<StackItem<StackItemContent>> data = List<StackItem<StackItemContent>>.from(innerData);

    data.remove(item);
    _indexMap.remove(item.id);

    _reorder(data);

    value = value.copyWith(data: data, indexMap: _newIndexMap);
  }

  /// * 通过 id 移除 item
  /// * remove item by id
  void removeById(String id) {
    if (!_indexMap.containsKey(id)) return;

    final List<StackItem<StackItemContent>> data = List<StackItem<StackItemContent>>.from(innerData);

    data.removeAt(_indexMap[id]!);
    _indexMap.remove(id);
    // selected.remove(id);

    value = value.copyWith(data: data, indexMap: _newIndexMap);
  }

  /// * 选中唯一 item
  /// * select only item
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

  /// * 取消选中所有 item
  /// * unselect all items
  void unSelectAll() {
    final List<StackItem<StackItemContent>> data = List<StackItem<StackItemContent>>.from(innerData);

    for (int i = 0; i < data.length; i++) {
      final StackItem<StackItemContent> item = data[i];
      data[i] = item.copyWith(status: StackItemStatus.idle);
    }

    // selected.clear();

    value = value.copyWith(data: data);
  }

  /// * 更新基础配置
  /// * update basic config
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

  /// * 更新 item
  /// * update item
  void updateItem(StackItem<StackItemContent> item) {
    if (!_indexMap.containsKey(item.id)) return;

    final List<StackItem<StackItemContent>> data = List<StackItem<StackItemContent>>.from(innerData);

    data[_indexMap[item.id]!] = item;

    value = value.copyWith(data: data);
  }

  /// * 清空
  /// * clear
  void clear() {
    value = StackConfig.init();
    _indexMap.clear();
  }

  /// * 获取选中 item json 数据
  /// * get selected item json data
  Map<String, dynamic>? getSelectedData() {
    return innerData
        .firstWhereOrNull(
          (StackItem<StackItemContent> item) => item.status == StackItemStatus.selected,
        )
        ?.toJson();
  }

  /// * 通过 id 获取数据 json
  /// * get data json by id
  Map<String, dynamic>? getDataById(String id) {
    return innerData.firstWhereOrNull((StackItem<StackItemContent> item) => item.id == id)?.toJson();
  }

  /// * 通过类型获取数据 json 列表
  /// * get data json list by type
  List<Map<String, dynamic>> getTypeData<T extends StackItem<StackItemContent>>() {
    final List<StackItem<StackItemContent>> data = List<StackItem<StackItemContent>>.from(innerData);

    final List<Map<String, dynamic>> list = <Map<String, dynamic>>[];

    for (int i = 0; i < data.length; i++) {
      final StackItem<StackItemContent> item = data[i];
      if (item is T) {
        final Map<String, dynamic> map = item.toJson();
        list.add(map);
      }
    }

    return list;
  }

  /// * 获取数据 json 列表
  /// * get data json list
  List<Map<String, dynamic>> getAllData() {
    final List<StackItem<StackItemContent>> data = List<StackItem<StackItemContent>>.from(innerData);

    final List<Map<String, dynamic>> list = <Map<String, dynamic>>[];

    for (int i = 0; i < data.length; i++) {
      final StackItem<StackItemContent> item = data[i];
      final Map<String, dynamic> map = item.toJson();
      list.add(map);
    }

    return list;
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
