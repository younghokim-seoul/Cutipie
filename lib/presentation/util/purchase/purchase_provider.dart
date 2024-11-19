import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:cutipie/presentation/util/dev_log.dart';
import 'package:cutipie/presentation/util/http/http_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

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


  var userId = '';


  final Set<String> kProductIds = {
    'com.pie.appcash.125',
    'com.pie.appcash.250',
    'com.pie.appcash.500',
    'com.vip.subscription'
  };

  final HttpProvider httpProvider;

  PurchaseProvider({required this.httpProvider});

  Stream<List<PurchaseDetails>> get purchaseStream =>
      _inAppPurchase.purchaseStream;


  /// 구매 유저 ID
  void setUser(String userId){
    Log.d("로그인된 구매 유저 ID $userId");
    this.userId = userId;
  }

  /// 인앱 결제 사용 가능 여부 체크
  Future<bool> isAvailable() async {
    final available = await _inAppPurchase.isAvailable();
    return available;
  }

  /// 상품 정보 요청
  Future<bool> fetchUserProducts() async {
    if (products.isEmpty) {
      ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(kProductIds);

      if (response.notFoundIDs.isNotEmpty) {
        Log.d("상품 정보를 찾을수 없음.");
        return false;
      }
      products = response.productDetails;

      for (var element in products) {
        Log.d("상품 정보 ID : ${element.id}");
        Log.d("상품 정보 TITLE : ${element.title}");
        Log.d("상품 정보 PRICE : ${element.price}");
      }
    }
    return true;
  }

  /// 상품 구매
  Future<void> purchaseProduct(String productId,{bool consumable = true}) async {
    Log.d("purchaseProduct $productId");

    final productDetails = products.firstWhereOrNull((element) => element.id == productId);

    if(productDetails == null){
      throw Exception("상품 정보를 찾을수 없음.");
    }

    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: productDetails);

    /// 비소모성은 정기구독 결제. 정기결제는 추후 서버 구축시 활성화, 단건결제만 사용
    if (consumable) {
      buyConsumable(purchaseParam);
    } else {
      buyNonConsumable(purchaseParam);
    }
  }

  ///단건 결제
  void buyConsumable(PurchaseParam purchaseParam) {
    _inAppPurchase.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: _kAutoConsume || Platform.isIOS);
  }

  ///정기 결제
  void buyNonConsumable(PurchaseParam purchaseParam) {
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }


  ///검증은 서버에서 진행 예정
  Future<bool> verifyPurchase(PurchaseDetails purchaseDetails) async {
    // 마켓에 등록한 상품 아이디(문자열)
    Log.d("마켓에 등록한 상품 아이디(문자열) ${purchaseDetails.productID}");



    // 구매 상태 PurchaseStatus.purchased 형태로 리턴한다 - android
    Log.d(purchaseDetails.status.toString());

    // 구매 날짜 1679542316652 형태로 리턴한다 - android
    Log.d(purchaseDetails.transactionDate.toString());

    // 구매 영수증 검증데이터가 base64로 암호화된 문자열로 리턴된다 - ios
    // 구매 영수증 아래와 같은 형태로 리턴된다 - android
    /*
    {
    "orderId":"주문아이디","
    packageName":"패키지명",
    "productId":"상품 아이디",
    "purchaseTime": 주문시간,
    "purchaseState": 0, // 주문상태
    "purchaseToken": "구매토큰",
    "quantity":1, // 수량
    "acknowledged":false // 정기결제 여부
    }
    */

    Log.d(purchaseDetails.verificationData.localVerificationData);

    // 구매 토큰
    Log.d(purchaseDetails.verificationData.serverVerificationData);

    // 구매 마켓 안드로이드면 google_play를 리턴한다
    Log.d("구매 마켓 ${purchaseDetails.verificationData.source}");
    return await httpProvider.sendToPayment(userId, purchaseDetails); // 임시로 true 반환
  }

  Future<void> completePurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchaseDetails);
    }
  }


}
