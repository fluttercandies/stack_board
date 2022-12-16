import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:stack_board_item/helpers.dart';
import 'package:stack_board_item/stack_board_item.dart';

class StackConfig {
  StackConfig({
    required this.data,
  });

  factory StackConfig.init() => StackConfig(data: <StackItem<StackItemContent>>[]);

  final List<StackItem<StackItemContent>> data;

  StackConfig copyWith({List<StackItem<StackItemContent>>? data}) {
    return StackConfig(data: data ?? this.data);
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

  final Set<String> selected = <String>{};

  static final StackBoardController _defaultController = StackBoardController(tag: 'def');

  List<StackItem<StackItemContent>> get data => value.data;

  StackItem<StackItemContent>? getById(String id) =>
      data.firstWhereOrNull((StackItem<StackItemContent> item) => item.id == id);

  void addItem(StackItem<StackItemContent> item, {bool selectIt = false}) {
    if (this.data.contains(item)) {
      print('StackBoardController addItem: item already exists');
      return;
    }

    final List<StackItem<StackItemContent>> data = List<StackItem<StackItemContent>>.from(value.data);

    selected.clear();

    // 其它 item EditStatus 重置为 idle
    for (int i = 0; i < data.length; i++) {
      final StackItem<StackItemContent> item = data[i];
      data[i] = item.copyWith(status: StackItemStatus.idle);
    }

    data.add(item);
    selected.add(item.id);

    value = value.copyWith(data: data);
  }

  void removeItem(StackItem<StackItemContent> item) {
    final List<StackItem<StackItemContent>> data = List<StackItem<StackItemContent>>.from(value.data);

    data.remove(item);
    selected.remove(item.id);

    value = value.copyWith(data: data);
  }

  void removeById(String id) {
    final List<StackItem<StackItemContent>> data = List<StackItem<StackItemContent>>.from(value.data);

    data.removeWhere((StackItem<StackItemContent> item) => item.id == id);
    selected.remove(id);

    value = value.copyWith(data: data);
  }

  void selectOne(int index) {
    final StackItem<StackItemContent> item = value.data[index];
    final List<StackItem<StackItemContent>> data = List<StackItem<StackItemContent>>.from(value.data);

    if (selected.contains(item.id)) {
      // 如果没有置顶，进行置顶操作
      if (index == value.data.length - 1) {
        return;
      }

      data.removeAt(index);
      data.add(item.copyWith(status: StackItemStatus.selected));
      value = value.copyWith(data: data);

      return;
    }

    selected.clear();

    data.remove(item);

    // 其它 item EditStatus 重置为 idle
    for (int i = 0; i < data.length; i++) {
      final StackItem<StackItemContent> item = data[i];
      data[i] = item.copyWith(status: StackItemStatus.idle);
    }

    data.add(item.copyWith(status: StackItemStatus.selected));

    selected.add(item.id);

    value = value.copyWith(data: data);
  }

  void unSelectAll() {
    final List<StackItem<StackItemContent>> data = List<StackItem<StackItemContent>>.from(value.data);

    for (int i = 0; i < data.length; i++) {
      final StackItem<StackItemContent> item = data[i];
      data[i] = item.copyWith(status: StackItemStatus.idle);
    }

    selected.clear();

    value = value.copyWith(data: data);
  }

  void updateBasic(int index, {Size? size, Offset? offset, double? angle, StackItemStatus? status}) {
    final List<StackItem<StackItemContent>> data = List<StackItem<StackItemContent>>.from(value.data);

    data[index] = data[index].copyWith(
      size: size,
      offset: offset,
      angle: angle,
      status: status,
    );

    value = value.copyWith(data: data);
  }

  /// * index Item index
  /// * id Item id
  /// * update Update function
  void updateItem({
    int? index,
    String? id,
    StackItem<StackItemContent> Function(StackItem<StackItemContent> oldItem)? update,
  }) {
    assert(index != null || id != null, 'index or id must not be null');

    final List<StackItem<StackItemContent>> data = List<StackItem<StackItemContent>>.from(value.data);

    final StackItem<StackItemContent>? item = index != null ? data[index] : getById(id!);

    assert(item != null, 'item not found');

    final StackItem<StackItemContent>? newItem = update?.call(item!);

    assert(newItem != null, 'newItem must not be null');

    if (index != null) {
      data[index] = newItem!;
    } else {
      data[data.indexOf(item!)] = newItem!;
    }

    value = value.copyWith(data: data);
  }

  void clear() {
    value = StackConfig.init();
    selected.clear();
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
