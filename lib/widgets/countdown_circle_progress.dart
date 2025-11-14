import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 倒计时圆圈进度组件
/// 显示一个带数字的圆圈进度条，用于倒计时显示
class CountdownCircleProgress extends StatefulWidget {
  const CountdownCircleProgress({
    super.key,
    required this.totalSeconds,
    required this.onComplete,
    this.size = 20.0,
    this.progressColor,
    this.backgroundColor,
    this.textStyle,
  });

  /// 总倒计时秒数
  final int totalSeconds;
  
  /// 倒计时完成回调
  final VoidCallback onComplete;
  
  /// 圆圈大小，默认20.0
  final double size;
  
  /// 进度条颜色，默认蓝色
  final Color? progressColor;
  
  /// 背景颜色，默认根据主题自动选择
  final Color? backgroundColor;
  
  /// 数字文本样式
  final TextStyle? textStyle;

  @override
  State<CountdownCircleProgress> createState() => _CountdownCircleProgressState();
}

class _CountdownCircleProgressState extends State<CountdownCircleProgress> {
  late final RxInt remainingSeconds;
  late final RxDouble progress;
  Timer? _countdownTimer;
  final _startTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    remainingSeconds = widget.totalSeconds.obs;
    progress = 1.0.obs;
    
    // 启动倒计时 - 使用更频繁的更新以实现平滑动画
    _countdownTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      final elapsed = DateTime.now().difference(_startTime);
      final elapsedSeconds = elapsed.inMilliseconds / 1000.0;
      final remaining = widget.totalSeconds - elapsedSeconds;
      
      // 计算剩余秒数（整数，用于显示）
      final remainingInt = remaining.ceil();
      
      // 计算平滑进度：基于实际经过的时间
      progress.value = remaining / widget.totalSeconds;
      if (progress.value < 0.0) progress.value = 0.0;
      
      // 更新显示的剩余秒数
      if (remainingInt > 0) {
        remainingSeconds.value = remainingInt;
      } else {
        remainingSeconds.value = 0;
        // 等待进度真正为0或接近0时才触发完成回调，确保与通知的显示时间同步
        if (progress.value <= 0.0) {
          timer.cancel();
          // 延迟一小段时间，确保通知的displayTime也到了
          Future.delayed(const Duration(milliseconds: 50), () {
            widget.onComplete();
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progressColor = widget.progressColor ?? Colors.blueAccent;
    final backgroundColor = widget.backgroundColor ?? 
        (isDark ? Colors.grey.shade800 : Colors.grey.shade200);
    final progressBgColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
    final textColor = widget.textStyle?.color ?? theme.textTheme.bodyLarge?.color;

    return Obx(() {
      if (remainingSeconds.value <= 0) {
        return const SizedBox.shrink();
      }

      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 圆圈进度条（使用动画平滑过渡）
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: 0.0,
                  end: progress.value,
                ),
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeOut,
                builder: (context, animatedProgress, child) {
                  return CircularProgressIndicator(
                    value: animatedProgress,
                    strokeWidth: 2,
                    backgroundColor: progressBgColor,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  );
                },
              ),
            ),
            // 数字显示在中心
            Text(
              '${remainingSeconds.value}',
              style: widget.textStyle ?? TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      );
    });
  }
}

