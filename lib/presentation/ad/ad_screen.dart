import 'package:auto_route/auto_route.dart';
import 'package:cutipie/presentation/util/ad_helper.dart';
import 'package:cutipie/presentation/widget/size_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

@RoutePage()
class AdScreen extends ConsumerStatefulWidget {
  const AdScreen({super.key});

  @override
  ConsumerState createState() => _AdScreenState();
}

class _AdScreenState extends ConsumerState<AdScreen> {
  @override
  Widget build(BuildContext context) {
    return Full(child: AdWidget(ad: AdHelper.instance.rewardAd!));
  }
}
