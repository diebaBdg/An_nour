import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class ArabicText extends StatelessWidget {
  const ArabicText({
    super.key,
    required this.text,
    this.fontSize = 24,
    this.textAlign = TextAlign.right,
    this.color,
  });

  final String text;
  final double fontSize;
  final TextAlign textAlign;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      textDirection: TextDirection.rtl,
      style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: fontSize,
            color: color ?? Theme.of(context).colorScheme.onSurface,
            height: 1.8,
          ),
    );
  }
}

class ReferenceBadge extends StatelessWidget {
  const ReferenceBadge({super.key, required this.reference});

  final String reference;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
      ),
      child: Text(
        reference,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.goldDark,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
