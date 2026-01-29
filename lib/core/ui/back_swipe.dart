import 'package:flutter/material.dart';

class BackSwipe extends StatefulWidget {
  const BackSwipe({
    super.key,
    required this.child,
    this.onBack,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onBack;
  final bool enabled;

  @override
  State<BackSwipe> createState() => _BackSwipeState();
}

class _BackSwipeState extends State<BackSwipe> {
  double _startX = 0;
  double _dragDx = 0;
  bool _active = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragStart: (details) {
            if (!widget.enabled) return;
            _startX = details.localPosition.dx;
            _dragDx = 0;
            final maxX = width * 0.45;
            _active = _startX <= maxX;
          },
          onHorizontalDragUpdate: (details) {
            if (!_active) return;
            _dragDx += details.delta.dx;
          },
          onHorizontalDragEnd: (details) {
            if (!_active) return;
            final velocity = details.velocity.pixelsPerSecond.dx;
            if (_dragDx > 80 || velocity > 800) {
              widget.onBack?.call();
            }
            _active = false;
          },
          child: widget.child,
        );
      },
    );
  }
}
