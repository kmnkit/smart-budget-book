import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zan/core/constants/enums.dart';
import 'package:zan/domain/entities/feature_access.dart';
import 'package:zan/presentation/providers/subscription_provider.dart';
import 'package:zan/presentation/widgets/feature_gate_widget.dart';

void main() {
  Widget buildTestWidget({
    required FeatureAccess access,
    required FeatureType feature,
    Widget? lockedChild,
  }) {
    return ProviderScope(
      overrides: [
        featureAccessProvider(feature).overrideWith((ref) => access),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: FeatureGateWidget(
            feature: feature,
            lockedChild: lockedChild,
            child: const Text('Unlocked Content'),
          ),
        ),
      ),
    );
  }

  testWidgets('should show child when feature is allowed', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        access: FeatureAccess.granted,
        feature: FeatureType.createTransaction,
      ),
    );

    expect(find.text('Unlocked Content'), findsOneWidget);
  });

  testWidgets('should show lockedChild when feature is blocked', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        access: const FeatureAccess(
          allowed: false,
          reason: 'Limit reached',
          remaining: 0,
          limit: 50,
        ),
        feature: FeatureType.createTransaction,
        lockedChild: const Text('Locked'),
      ),
    );

    expect(find.text('Locked'), findsOneWidget);
    expect(find.text('Unlocked Content'), findsNothing);
  });

  testWidgets('should show dimmed child when blocked without lockedChild',
      (tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        access: const FeatureAccess(
          allowed: false,
          reason: 'Limit reached',
        ),
        feature: FeatureType.createTransaction,
      ),
    );

    // Should find the child but wrapped in Opacity
    final opacity = tester.widget<Opacity>(find.byType(Opacity));
    expect(opacity.opacity, 0.5);
  });
}
