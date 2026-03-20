import 'package:flutter/material.dart';

enum ContentWidth {
  wide(1200),
  narrow(600);

  final double width;
  const ContentWidth(this.width);
}

class ConstrainedContent extends StatelessWidget {
  final ContentWidth width;
  final Widget child;

  const ConstrainedContent({
    super.key,
    required this.width,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width.width),
      child: child,
    ),
  );
}
