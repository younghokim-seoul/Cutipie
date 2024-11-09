
import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
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
    return Container();
  }
}
