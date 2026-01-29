import 'package:flutter/material.dart';

class SessionCard extends StatelessWidget {
  const SessionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.icon,
    required this.gradient,
    this.backgroundImage,
    this.backgroundScale = const Offset(1, 1),
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final IconData icon;
  final Gradient gradient;
  final String? backgroundImage;
  final Offset backgroundScale;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
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
          child: Stack(
            clipBehavior: Clip.hardEdge,
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: gradient,
                      ),
                      child: Icon(icon, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
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
                    const Icon(Icons.chevron_right, color: Color(0xFF9AA0C8)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
