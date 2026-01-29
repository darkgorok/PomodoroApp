import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isOutlined = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isOutlined;

  @override
  Widget build(BuildContext context) {
    final style = isOutlined
        ? OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          )
        : ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          );

    final child = Text(label, style: const TextStyle(fontSize: 16));

    return isOutlined
        ? OutlinedButton(onPressed: onPressed, style: style, child: child)
        : ElevatedButton(onPressed: onPressed, style: style, child: child);
  }
}
