import 'package:flutter/material.dart';

class UsageMeterWidget extends StatelessWidget {
  const UsageMeterWidget({
    super.key,
    required this.label,
    required this.current,
    required this.limit,
    this.compact = false,
  });

  final String label;
  final int current;
  final int limit;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnlimited = limit < 0;
    final remaining = isUnlimited ? -1 : limit - current;
    final progress = isUnlimited ? 0.0 : (limit > 0 ? current / limit : 0.0);
    final isNearLimit = !isUnlimited && progress >= 0.8;

    if (compact) {
      return Text(
        isUnlimited ? label : '$label ($current/$limit)',
        style: theme.textTheme.labelSmall?.copyWith(
          color: isNearLimit ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodySmall),
            Text(
              isUnlimited ? '∞' : '$remaining',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isNearLimit ? theme.colorScheme.error : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: isUnlimited ? 0 : progress.clamp(0.0, 1.0),
            minHeight: 4,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            color: isNearLimit
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
