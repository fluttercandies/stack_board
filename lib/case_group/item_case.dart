import 'package:flutter/material.dart';
import 'package:stack_board/helper/case_style.dart';
import 'package:stack_board/helper/ex_value_builder.dart';
import 'package:stack_board/helper/get_size.dart';
import 'package:stack_board/helper/safe_value_notifier.dart';

import '../helper/safe_state.dart';

///配置项
class _Config {
  _Config(this.size, this.offset);

  _Config.def({
    this.offset = Offset.zero,
  });

  Size? size;
  late Offset offset;

  _Config get copy => _Config(size, offset);
}

///操作外壳
class ItemCase extends StatefulWidget {
  const ItemCase({
    Key? key,
    required this.child,
    this.isCenter = true,
    this.onEdit,
    this.onDel,
    this.onSizeChanged,
    this.tools,
    this.onOffsetChanged,
    this.caseStyle = const CaseStyle(),
    this.isOperating,
    this.isEditing,
  }) : super(key: key);

  @override
  _ItemCaseState createState() => _ItemCaseState();

  final Widget child;
  final Widget? tools;

  final bool isCenter;
  final bool? isOperating;
  final bool? isEditing;

  final void Function(bool isEditing)? onEdit;
  final void Function()? onDel;

  ///尺寸变化回调
  ///返回值可控制是否继续进行
  final bool? Function(Size size)? onSizeChanged;
  final bool? Function(Offset offset)? onOffsetChanged;

  final CaseStyle? caseStyle;
}

class _ItemCaseState extends State<ItemCase> with SafeState<ItemCase> {
  late SafeValueNotifier<_Config> _config;
  late bool _isEditing = widget.isEditing ?? false;
  late bool _isOperating = widget.isOperating ?? true;

  CaseStyle get _caseStyle => widget.caseStyle ?? const CaseStyle();

  @override
  void initState() {
    super.initState();
    _config = SafeValueNotifier<_Config>(_Config.def());
  }

  @override
  void didUpdateWidget(covariant ItemCase oldWidget) {
    if (widget.isOperating != null && widget.isOperating != _isOperating) {
      safeSetState(() {
        _isOperating = widget.isOperating!;
      });
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _config.dispose();
    super.dispose();
  }

  ///移动
  void _moveHandle(DragUpdateDetails dud) {
    if (_isEditing) {
      _isEditing = false;
      widget.onEdit?.call(false);
    }

    if (!_isOperating) {
      safeSetState(() => _isOperating = true);
    }

    final Offset d = dud.delta;
    final Offset changeToOffset = _config.value.offset.translate(d.dx, d.dy);
    if (!(widget.onOffsetChanged?.call(changeToOffset) ?? true)) return;

    _config.value.offset = changeToOffset;
    _config.value = _config.value.copy;

    widget.onOffsetChanged?.call(_config.value.offset);
  }

  ///拖放
  void _scaleHandle(DragUpdateDetails dud) {
    if (_isEditing) {
      _isEditing = false;
      widget.onEdit?.call(false);
    }

    if (_config.value.size == null) return;

    final Offset d = dud.delta;

    final Size s = Size(_config.value.size!.width + d.dx, _config.value.size!.height + d.dy);

    if (d.dx < 0 || d.dy < 0) {
      if (s.width - _caseStyle.iconSize * 2 <= 0 || s.height - _caseStyle.iconSize * 2 <= 0) return;
    }

    final Size changeToSize = Size(_config.value.size!.width + d.dx, _config.value.size!.height + d.dy);

    if (!(widget.onSizeChanged?.call(_config.value.size!) ?? true)) return;

    _config.value.size = changeToSize;
    _config.value = _config.value.copy;
  }

  @override
  Widget build(BuildContext context) {
    return ExValueBuilder<_Config>(
      shouldRebuild: (_Config p, _Config n) => p.offset != n.offset,
      valueListenable: _config,
      child: GestureDetector(
        onPanUpdate: _moveHandle,
        onTap: () {
          if (!_isOperating) safeSetState(() => _isOperating = true);
        },
        child: Stack(children: <Widget>[
          _border,
          _child,
          if (widget.tools != null) _tools,
          if (widget.onEdit != null && _isOperating) _edit,
          if (_isOperating) _check,
          if (widget.onDel != null && _isOperating) _del,
          if (_isOperating) _scale,
        ]),
      ),
      builder: (_, _Config c, Widget? child) {
        return Positioned(top: c.offset.dy, left: c.offset.dx, child: child!);
      },
    );
  }

  ///子控件
  Widget get _child {
    Widget content = widget.child;
    if (_config.value.size == null) {
      content = GetSize(
        onChange: (Size? size) {
          if (size != null && _config.value.size == null) {
            _config.value.size = Size(size.width + _caseStyle.iconSize + 40, size.height + _caseStyle.iconSize + 40);
            safeSetState(() {});
          }
        },
        child: content,
      );
    }

    if (widget.isCenter) content = Center(child: content);

    return ExValueBuilder<_Config>(
      shouldRebuild: (_Config p, _Config n) => p.size != n.size,
      valueListenable: _config,
      child: Padding(
        padding: EdgeInsets.all(_caseStyle.iconSize / 2),
        child: content,
      ),
      builder: (_, _Config c, Widget? child) {
        return SizedBox.fromSize(
          size: c.size,
          child: child,
        );
      },
    );
  }

  ///边框
  Widget get _border {
    return Positioned(
      top: _caseStyle.iconSize / 2,
      bottom: _caseStyle.iconSize / 2,
      left: _caseStyle.iconSize / 2,
      right: _caseStyle.iconSize / 2,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: _isOperating ? _caseStyle.borderColor : Colors.transparent,
            width: _caseStyle.borderWidth,
          ),
        ),
      ),
    );
  }

  ///编辑
  Widget get _edit {
    return GestureDetector(
      onTap: () {
        _isEditing = !_isEditing;
        widget.onEdit?.call(_isEditing);
        safeSetState(() {});
      },
      child: _toolCase(Icon(_isEditing ? Icons.border_color : Icons.edit)),
    );
  }

  ///删除
  Widget get _del {
    return Positioned(
      top: 0,
      right: 0,
      child: GestureDetector(
        onTap: () => widget.onDel?.call(),
        child: _toolCase(const Icon(Icons.clear)),
      ),
    );
  }

  ///缩放
  Widget get _scale {
    return Positioned(
      bottom: 0,
      right: 0,
      child: GestureDetector(
        onPanUpdate: _scaleHandle,
        child: _toolCase(
          const RotatedBox(
            quarterTurns: 1,
            child: Icon(Icons.open_in_full_outlined),
          ),
        ),
      ),
    );
  }

  ///完成操作
  Widget get _check {
    return Positioned(
      bottom: 0,
      left: 0,
      child: GestureDetector(
        onTap: () {
          if (_isOperating) {
            safeSetState(() {
              _isOperating = false;
              _isEditing = false;
              widget.onEdit?.call(false);
            });
          }
        },
        child: _toolCase(const Icon(Icons.check)),
      ),
    );
  }

  ///操作手柄壳
  Widget _toolCase(Widget child) {
    return Container(
      width: _caseStyle.iconSize,
      height: _caseStyle.iconSize,
      child: IconTheme(
        data: Theme.of(context).iconTheme.copyWith(
              color: _caseStyle.iconColor,
              size: _caseStyle.iconSize * 0.6,
            ),
        child: child,
      ),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _caseStyle.borderColor,
      ),
    );
  }

  ///工具栏
  Widget get _tools {
    return Positioned(
      left: _caseStyle.iconSize / 2,
      top: _caseStyle.iconSize / 2,
      right: _caseStyle.iconSize / 2,
      bottom: _caseStyle.iconSize / 2,
      child: widget.tools!,
    );
  }
}
