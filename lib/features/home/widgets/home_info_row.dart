import 'package:flutter/material.dart';

/// A reusable row widget displaying an icon followed by text.
class HomeInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;
  final Color? textColor;
  final FontWeight? fontWeight;

  const HomeInfoRow({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor,
    this.textColor,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Icon(
            icon,
            color: iconColor ?? colorScheme.onSurface,
            size: 24,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: textTheme.labelMedium?.copyWith(
              color: textColor ?? colorScheme.onSurface,
              fontWeight: fontWeight,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
