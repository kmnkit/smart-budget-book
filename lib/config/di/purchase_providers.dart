import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zan/data/datasources/local/purchase_service.dart';
import 'package:zan/data/datasources/local/subscription_cache.dart';
import 'package:zan/data/datasources/remote/supabase_providers.dart';
import 'package:zan/data/repositories/purchase_repository_impl.dart';
import 'package:zan/domain/repositories/purchase_repository.dart';
import 'package:zan/domain/usecases/purchase_subscription_usecase.dart';
import 'package:zan/domain/usecases/restore_purchases_usecase.dart';

part 'purchase_providers.g.dart';

@riverpod
PurchaseService purchaseService(Ref ref) {
  final service = PurchaseService();
  service.initialize();
  ref.onDispose(service.dispose);
  return service;
}

@riverpod
SubscriptionCache subscriptionCache(Ref ref) {
  return SubscriptionCache();
}

@riverpod
PurchaseRepository purchaseRepository(Ref ref) {
  return PurchaseRepositoryImpl(
    ref.watch(purchaseServiceProvider),
    ref.watch(supabaseClientProvider),
    ref.watch(subscriptionCacheProvider),
  );
}

@riverpod
PurchaseSubscriptionUseCase purchaseSubscriptionUseCase(Ref ref) {
  return PurchaseSubscriptionUseCase(ref.watch(purchaseRepositoryProvider));
}

@riverpod
RestorePurchasesUseCase restorePurchasesUseCase(Ref ref) {
  return RestorePurchasesUseCase(ref.watch(purchaseRepositoryProvider));
}
