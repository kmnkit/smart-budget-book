import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zan/core/constants/enums.dart';
import 'package:zan/presentation/providers/subscription_provider.dart';
import 'package:zan/presentation/widgets/paywall_bottom_sheet.dart';

class FeatureGateWidget extends ConsumerWidget {
  const FeatureGateWidget({
    super.key,
    required this.feature,
    required this.child,
    this.lockedChild,
    this.onBlocked,
  });

  final FeatureType feature;
  final Widget child;
  final Widget? lockedChild;
  final VoidCallback? onBlocked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(featureAccessProvider(feature));

    if (access.allowed) return child;

    return lockedChild ??
        GestureDetector(
          onTap: () {
            onBlocked?.call();
            PaywallBottomSheet.show(
              context,
              reason: access.reason,
              remaining: access.remaining,
              limit: access.limit,
            );
          },
          child: Opacity(
            opacity: 0.5,
            child: AbsorbPointer(child: child),
          ),
        );
  }
}
