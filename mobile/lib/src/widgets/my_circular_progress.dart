import 'package:flutter/material.dart';

class MyCircularProgress extends StatelessWidget {
  const MyCircularProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
          valueColor:
              AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
    );
  }
}
