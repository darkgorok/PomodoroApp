import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isOutlined = false,
    this.icon,
    this.height = 48,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isOutlined;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    final gradient = const LinearGradient(
      colors: [Color(0xFF5B68FF), Color(0xFF9A7BFF)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: isOutlined ? const Color(0xFF4B55C9) : Colors.white),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: TextStyle(
            color: isOutlined ? const Color(0xFF4B55C9) : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ],
    );

    if (isOutlined) {
      return SizedBox(
        height: height,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: radius),
            side: const BorderSide(color: Color(0xFFCCD1F0)),
            backgroundColor: Colors.white,
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: gradient, borderRadius: radius),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: radius,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
