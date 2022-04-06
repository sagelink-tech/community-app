import 'package:flutter/material.dart';

class ListSpacer extends StatelessWidget {
  final double height;
  final double width;

  const ListSpacer({this.height = 10, this.width = 10, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height, width: width);
  }
}
