import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

class CircularCountdown extends StatefulWidget {
  const CircularCountdown({
    super.key,
    this.controller,
    required this.duration,
    this.radius = 16,
    this.onRefresh,
    this.remaining,
    this.showNumber = true,
    this.isLoop = false,
    this.autoStart = true,
  });

  final AnimationController? controller;
  // 倒计时总时长，单位为秒
  final int duration;
  // 如果传入 from，则表示 OTP 已经过了 from 秒，即倒计时从 (duration - from) 秒开始
  final int? remaining;
  final double radius;
  final bool isLoop;
  final bool autoStart;
  final bool showNumber;

  /// 一周期结束(duration 10 -> 0)
  final VoidCallback? onRefresh;

  @override
  State<CircularCountdown> createState() => _CircularCountdownState();
}

class _CircularCountdownState extends State<CircularCountdown> with SingleTickerProviderStateMixin {
  late final AnimationController _internalController;
  AnimationController get _effectiveController => widget.controller ?? _internalController;
  bool get _shouldDisposeController => widget.controller == null;

  late Animation<double> _progressAnimation;
  Timer? _timer;
  // 剩余时间，如果 widget.from 不为空，则初始剩余时间为 widget.duration - widget.from
  int _remainingTime = 0;

  bool _isFirstBuild = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    // 创建 AnimationController，duration 仍然取 widget.duration，
    // 但通过 forward(from:) 来确定动画起点（起点为 widget.from/widget.duration）
    _internalController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.duration),
    );
    // 设置 Tween，从 1.0 到 0.0，最终的进度由 1 - controller.value 得到
    _progressAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_effectiveController)
      ..addListener(() {
        setState(() {});
      });

    if (widget.autoStart) {
      _startAnimationAndTimer(_calcFromValue());
    }
  }

  double _calcFromValue() {
    // 根据 from 参数计算初始剩余时间
    double startValue;
    if (_isFirstBuild) {
      _remainingTime = widget.remaining ?? widget.duration;

      // 启动动画，从指定的初始比例开始：如果 from 非空，则以 (widget.from/widget.duration) 开始，
      // 此时进度 = 1 - (from/duration)，例如 duration=30，from=10，则初始进度为 1 - 10/30 = 0.67
      startValue = widget.remaining != null ? 1 - (widget.remaining! / widget.duration) : 0.0;
      _isFirstBuild = false;
    } else {
      _remainingTime = widget.duration;
      startValue = 0.0;
    }
    return startValue;
  }

  void _refresh() {
    widget.onRefresh?.call();
    // 清理并重新初始化动画和 Timer
    if (widget.isLoop) {
      _effectiveController.reset();
      _startAnimationAndTimer(_calcFromValue());
    }
  }

  // 启动定时器，用于每秒更新倒计时数字
  void _startAnimationAndTimer(double fromValue) {
    _effectiveController.forward(from: fromValue);

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime <= 1) {
        timer.cancel();
        _refresh();
      } else {
        setState(() {
          _remainingTime--;
        });
      }
    });
  }

  @override
  void dispose() {
    if (_shouldDisposeController) {
      _internalController.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 指定一个固定尺寸的容器
    return Center(
      child: SizedBox.fromSize(
        size: Size.fromRadius(widget.radius),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 使用 CustomPaint 绘制背景圆形与进度圆弧
            CustomPaint(
              size: Size.fromRadius(widget.radius),
              painter: _CircleProgressPainter(context: context, progress: _progressAnimation.value),
            ),
            // 中间显示倒计时剩余时间
            Text(
              widget.showNumber ? '$_remainingTime' : '',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 自定义的 CustomPainter 绘制圆形进度条
class _CircleProgressPainter extends CustomPainter {
  _CircleProgressPainter({required this.context, required this.progress});

  /// progress 范围 0.0 - 1.0，1.0 表示进度全满
  final double progress;
  final BuildContext context;
  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 4; // 边框粗细
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth;
    // 绘制背景圆形（灰色）
    final Paint backgroundPaint =
        Paint()
          ..color = Theme.of(context).colorScheme.surfaceContainerHighest
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, backgroundPaint);
    // 绘制进度圆弧（蓝色），起始角度-90度（-pi/2）表示从顶部开始
    final Paint progressPaint =
        Paint()
          ..color = Theme.of(context).colorScheme.primary
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;
    // 计算圆弧的扫过角度(剩余进度比例)
    double sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // 起始角度：从顶部开始
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
