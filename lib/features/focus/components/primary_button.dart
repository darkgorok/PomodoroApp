import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isOutlined = false,
    this.icon,
    this.height = 48,
    this.fullWidth = false,
    this.backgroundImage,
    this.backgroundScale = const Offset(1, 1),
    this.fontSize = 15,
    this.iconSize,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isOutlined;
  final IconData? icon;
  final double height;
  final bool fullWidth;
  final String? backgroundImage;
  final Offset backgroundScale;
  final double fontSize;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    final gradient = const LinearGradient(
      colors: [Color(0xFF5B68FF), Color(0xFF9A7BFF)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: iconSize ?? fontSize,
            color: isOutlined ? const Color(0xFF4B55C9) : Colors.white,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: TextStyle(
            color: isOutlined ? const Color(0xFF4B55C9) : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: fontSize,
          ),
        ),
      ],
    );

    if (isOutlined) {
      return SizedBox(
        height: height,
        width: fullWidth ? double.infinity : null,
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
      width: fullWidth ? double.infinity : null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: backgroundImage == null ? gradient : null,
          borderRadius: radius,
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              if (backgroundImage != null)
                Positioned.fill(
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.diagonal3Values(
                      backgroundScale.dx,
                      backgroundScale.dy,
                      1,
                    ),
                    child: Image.asset(
                      backgroundImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onPressed,
                  borderRadius: radius,
                  child: Center(child: child),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
