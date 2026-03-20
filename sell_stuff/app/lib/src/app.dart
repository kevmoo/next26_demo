import 'package:flutter/material.dart';
import 'router.dart';
import 'theme.dart';

class SellStuffApp extends StatelessWidget {
  const SellStuffApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    debugShowCheckedModeBanner: false,
    title: 'Sell Stuff Demo',
    theme: getAppTheme(),
    routerConfig: router,
  );
}
