import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:peak_pass/utils/loc.dart';

class PrivacyProtection extends StatefulWidget {
  const PrivacyProtection({super.key, required this.child});
  final Widget child;

  @override
  State<PrivacyProtection> createState() => _PrivacyProtectionState();
}

class _PrivacyProtectionState extends State<PrivacyProtection>
    with WidgetsBindingObserver {
  // bool _hidden = false;
  late final ValueNotifier<bool> _hidden;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _hidden = ValueNotifier(false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _debounceTimer?.cancel();
    // 如果是从非活跃状态恢复到活跃状态，且当前是隐藏状态，则立即显示
    if (state == AppLifecycleState.resumed && _hidden.value) {
      _hidden.value = false;
    } else {
      // 添加延迟处理以避免屏幕旋转时的闪烁问题
      // 例如: 屏幕旋转时生命周期状态变化: resumed -> inactive -> resumed
      // 如果不使用延迟，会在旋转过程中短暂显示隐私保护页面，影响用户体验
      // 注意：这种解决方案并不完美，因为延迟时间难以精确控制
      _debounceTimer = Timer(const Duration(milliseconds: 200), () {
        _hidden.value = state != AppLifecycleState.resumed;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounceTimer?.cancel();
    _hidden.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        ValueListenableBuilder<bool>(
          valueListenable: _hidden,
          builder: (context, value, child) {
            return IgnorePointer(
              ignoring: !value,
              child: Opacity(opacity: value ? 1 : 0, child: child),
            );
          },
          child: const _PrivacyProtectionOverlay(),
        ),
      ],
    );
  }
}

class _PrivacyProtectionOverlay extends StatelessWidget {
  const _PrivacyProtectionOverlay();
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
      child: Container(
        color: Colors.white38,
        child: Center(
          child: Text(
            loc(context).privacyProtection,
            style: TextStyle(
              fontSize: 16,
              decoration: TextDecoration.none,
              color: Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}
