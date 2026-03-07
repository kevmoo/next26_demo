import 'package:flutter/material.dart';
import 'router.dart';

class SellStuffApp extends StatelessWidget {
  const SellStuffApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    debugShowCheckedModeBanner: false,
    title: 'Sell Stuff Demo',
    routerConfig: router,
  );
}
