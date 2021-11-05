import 'package:flutter/material.dart';
import 'package:stack_board/src/helper/case_style.dart';
import 'package:stack_board/src/helper/ex_value_builder.dart';
import 'package:stack_board/src/helper/get_size.dart';
import 'package:stack_board/src/helper/safe_state.dart';
import 'package:stack_board/src/helper/safe_value_notifier.dart';

///配置项
class _Config {
  _Config(this.size, this.offset);

  ///默认配置
  _Config.def({this.offset = Offset.zero});

  ///尺寸
  Size? size;

  ///位置
  late Offset offset;

  ///拷贝
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

  ///子控件
  final Widget child;

  ///工具层
  final Widget? tools;

  ///是否进行居中对齐(自动包裹Center)
  final bool isCenter;

  ///是否正在操作
  final bool? isOperating;

  ///初始化编辑状态
  final bool? isEditing;

  ///编辑动作回调
  final void Function(bool isEditing)? onEdit;

  ///移除拦截
  final void Function()? onDel;

  ///尺寸变化回调
  ///返回值可控制是否继续进行
  final bool? Function(Size size)? onSizeChanged;

  ///位置变化回调
  final bool? Function(Offset offset)? onOffsetChanged;

  ///外框样式
  final CaseStyle? caseStyle;
}

class _ItemCaseState extends State<ItemCase> with SafeState<ItemCase> {
  ///基础参数状态
  late SafeValueNotifier<_Config> _config;

  ///编辑状态
  late bool _isEditing = widget.isEditing ?? false;

  ///操作状态
  late bool _isOperating = widget.isOperating ?? true;

  ///外框样式
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

    ///移动拦截
    if (!(widget.onOffsetChanged?.call(changeToOffset) ?? true)) return;

    _config.value.offset = changeToOffset;
    _config.value = _config.value.copy;

    widget.onOffsetChanged?.call(_config.value.offset);
  }

  ///缩放
  void _scaleHandle(DragUpdateDetails dud) {
    if (_isEditing) {
      _isEditing = false;
      widget.onEdit?.call(false);
    }

    if (_config.value.size == null) return;

    final Offset delta = dud.delta;
    final Offset start = _config.value.offset;
    final Offset global = dud.globalPosition;
    final Offset offSize = global - start;
    final double w = offSize.dx + _caseStyle.iconSize / 2;
    final double h = offSize.dy - _caseStyle.iconSize * 2.5;

    if (w <= 0 || h <= 0) return;
    final Size s = Size(w, h);

    ///达到极小值
    if (delta.dx < 0 || delta.dy < 0) {
      if (s.width - _caseStyle.iconSize * 2 <= 0 ||
          s.height - _caseStyle.iconSize * 2 <= 0) return;
    }

    ///缩放拦截
    if (!(widget.onSizeChanged?.call(s) ?? true)) return;

    if (widget.caseStyle?.boxAspectRatio != null) {
      if (s.width < s.height) {
        _config.value.size =
            Size(s.width, s.width / widget.caseStyle!.boxAspectRatio!);
      } else {
        _config.value.size =
            Size(s.height * widget.caseStyle!.boxAspectRatio!, s.height);
      }
    } else {
      _config.value.size = s;
    }

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
            _config.value.size = Size(size.width + _caseStyle.iconSize + 40,
                size.height + _caseStyle.iconSize + 40);
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

  ///缩放
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
