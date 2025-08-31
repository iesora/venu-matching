import 'package:flutter/material.dart';

class SwipeStack extends StatelessWidget {
  final List<Widget> children;

  const SwipeStack({
    Key? key,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: children.map((child) {
        return Positioned.fill(
          child: child,
        );
      }).toList(),
    );
  }
}
