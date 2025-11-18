import 'package:flutter/material.dart';

/// 箭头指示动画组件
/// 用于引导用户点击某个区域
class ArrowHintAnimation extends StatefulWidget {
  const ArrowHintAnimation({
    super.key,
    required this.targetPosition,
    this.arrowColor,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.onAnimationComplete,
  });

  /// 目标位置（相对于父组件的偏移）
  final Offset targetPosition;
  
  /// 箭头颜色
  final Color? arrowColor;
  
  /// 动画持续时间
  final Duration animationDuration;
  
  /// 动画完成回调
  final VoidCallback? onAnimationComplete;

  @override
  State<ArrowHintAnimation> createState() => _ArrowHintAnimationState();
}

class _ArrowHintAnimationState extends State<ArrowHintAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // 弹跳动画：箭头上下移动
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 8.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // 淡入淡出动画
    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 0.3,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 0.4,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 0.3,
      ),
    ]).animate(_controller);

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arrowColor = widget.arrowColor ?? Theme.of(context).primaryColor;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(widget.targetPosition.dx, widget.targetPosition.dy + _bounceAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: CustomPaint(
              size: const Size(50, 30),
              painter: _ArrowPainter(
                color: arrowColor,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ArrowPainter extends CustomPainter {
  _ArrowPainter({
    required this.color,
  });

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // 绘制箭头（指向右侧）
    final centerY = size.height / 2;
    const arrowHeadSize = 12.0;
    
    // 箭头主体（水平线）
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width - arrowHeadSize, centerY),
      paint,
    );
    
    // 箭头头部（三角形）
    final path = Path();
    path.moveTo(size.width - arrowHeadSize, centerY);
    path.lineTo(size.width, centerY - 6);
    path.lineTo(size.width, centerY + 6);
    path.close();
    
    canvas.drawPath(path, paint);
    
    // 添加一个圆形指示点
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width, centerY),
      3,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ArrowPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

