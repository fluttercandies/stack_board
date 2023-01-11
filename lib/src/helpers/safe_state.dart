import 'dart:async';

import 'package:flutter/material.dart';

/// State安全扩展
mixin SafeState<T extends StatefulWidget> on State<T> {
  /// 安全刷新
  FutureOr<void> safeSetState(FutureOr<dynamic> Function() fn) async {
    if (mounted &&
        !context.debugDoingBuild &&
        context.owner?.debugBuilding == false) {
      await fn();
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration.zero, () async {
      if (mounted) {
        await contextReady();
      }
    });
  }

  @override
  void setState(Function() fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  /// context可读回调
  Future<void> contextReady() async {}
}
