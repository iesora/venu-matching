import 'package:flutter/material.dart';

class DefaultButton extends StatelessWidget {
  // Variables
  final Widget child;
  final void Function()? onPressed;
  final double? width;
  final double? height;
  final Color? backgroundColor;

  const DefaultButton(
      {super.key,
      required this.child,
      required this.onPressed,
      this.width,
      this.height,
      this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height ?? 45,
      child: ElevatedButton(
        onPressed: onPressed,
        style: backgroundColor != null
            ? ElevatedButton.styleFrom(backgroundColor: backgroundColor)
            : null,
        child: child,
      ),
    );
  }
}
