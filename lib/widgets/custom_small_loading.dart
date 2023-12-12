import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomSmallLoading extends StatelessWidget {
  const CustomSmallLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: SpinKitChasingDots(color: Theme.of(context).primaryColor, size: 30.0),
      )
    );
  }
}
