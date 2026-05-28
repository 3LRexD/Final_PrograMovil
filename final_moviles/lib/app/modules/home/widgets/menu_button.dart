import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = enabled ? color : Colors.grey.shade400;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: enabled ? 6 : 2,
        shadowColor: effectiveColor.withValues(alpha: 0.3),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: effectiveColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: effectiveColor, size: 32),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: enabled ? Colors.black87 : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: enabled ? Colors.black45 : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  enabled ? Icons.arrow_forward_ios_rounded : Icons.lock_outline_rounded,
                  color: effectiveColor,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
