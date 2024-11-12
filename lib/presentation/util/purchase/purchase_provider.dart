import 'dart:io';

import 'package:cutipie/presentation/util/dev_log.dart';
import 'package:cutipie/presentation/util/extension/bool_extension.dart';
import 'package:cutipie/presentation/util/http/http_provider.dart';
import 'package:cutipie/presentation/util/recrod/record_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

final purchaseProvider = Provider.autoDispose<PurchaseProvider>((ref) {
  final httpServiceProvider = ref.watch(networkProvider);
  final provider = PurchaseProvider(httpProvider: httpServiceProvider);

  return provider;
});

class PurchaseProvider {
  /// 구매를 위한 인스턴스
  final _inAppPurchase = InAppPurchase.instance;

  final bool _kAutoConsume = Platform.isIOS || true;

  ///가능한 상품 목록
  var products = <ProductDetails>[];

  final Set<String> kProductIds = {
    'com.pie.appcash.125',
    'com.pie.appcash.250',
    'com.pie.appcash.500',
    'com.vip.subscription'
  };

  final HttpProvider httpProvider;

  PurchaseProvider({required this.httpProvider});

  /// 인앱 결제 사용 가능 여부 체크
  Future<bool> isAvailable() async {
    final available = await _inAppPurchase.isAvailable();
    return available;
  }

  /// 상품 정보 요청
  Future<void> fetchUserProducts() async {
    ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(kProductIds);

    if (response.notFoundIDs.isNotEmpty) {
      Log.d("상품 정보를 찾을수 없음.");
    }

    Log.d("response " + response.productDetails.toString());
  }

  // void purchaseProduct(ProductDetails prod) {
  //   final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
  //   _inAppPurchase.buyConsumable(purchaseParam: purchaseParam, autoConsume: false);
  // }

  Future<void> purchaseProduct(ProductDetails productDetails, {bool consumable = true}) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);

    /// 비소모성은 정기구독 결제.
    if (consumable) {
      buyConsumable(purchaseParam);
    } else {
      buyNonConsumable(purchaseParam);
    }
  }

  void buyConsumable(PurchaseParam purchaseParam) {
    _inAppPurchase.buyConsumable(
      purchaseParam: purchaseParam,
      autoConsume: _kAutoConsume || Platform.isIOS,
    );
  }

  void buyNonConsumable(PurchaseParam purchaseParam) {
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }
}
