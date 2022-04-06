import 'package:flutter/material.dart';

class EmptyResult extends StatelessWidget {
  final String text;
  const EmptyResult({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: Theme.of(context).textTheme.headline3,
              textAlign: TextAlign.center,
            ),
            //Text("😞", style: Theme.of(context).textTheme.headlineLarge),
            Text("Check back later for any updates!",
                style: Theme.of(context).textTheme.caption,
                textAlign: TextAlign.center)
          ],
        ));
  }
}
