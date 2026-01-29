import 'package:flutter/material.dart';

class PresetTile extends StatelessWidget {
  const PresetTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.onLongPress,
    this.locked = false,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Ink(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 10,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E2138),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B6F8C),
                        ),
                      ),
                    ],
                  ),
                ),
                if (locked)
                  const Icon(Icons.lock_rounded, color: Color(0xFF9AA0C8))
                else
                  const Icon(Icons.chevron_right, color: Color(0xFF9AA0C8)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
