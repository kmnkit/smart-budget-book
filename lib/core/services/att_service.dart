import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';

class AttService {
  AttService._();
  static final instance = AttService._();

  /// Request ATT permission. Only shows on iOS 14+.
  /// Should be called after onboarding completes.
  Future<TrackingStatus> requestPermission() async {
    if (!Platform.isIOS) return TrackingStatus.notSupported;

    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status == TrackingStatus.notDetermined) {
      // Small delay recommended by Apple for better UX
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return AppTrackingTransparency.requestTrackingAuthorization();
    }
    return status;
  }

  Future<TrackingStatus> getStatus() async {
    if (!Platform.isIOS) return TrackingStatus.notSupported;
    return AppTrackingTransparency.trackingAuthorizationStatus;
  }
}
