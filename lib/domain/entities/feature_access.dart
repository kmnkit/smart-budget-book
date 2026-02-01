import 'package:freezed_annotation/freezed_annotation.dart';

part 'feature_access.freezed.dart';

@Freezed()
sealed class FeatureAccess with _$FeatureAccess {
  const factory FeatureAccess({
    required bool allowed,
    String? reason,
    int? remaining,
    int? limit,
  }) = _FeatureAccess;

  static const FeatureAccess granted = FeatureAccess(allowed: true);
}
