import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "There was an error loading this page",
              style: Theme.of(context).textTheme.headline3,
              textAlign: TextAlign.center,
            ),
            Text("😞", style: Theme.of(context).textTheme.headline1),
            Text("Try reloading? Could be a server error...",
                style: Theme.of(context).textTheme.caption,
                textAlign: TextAlign.center)
          ],
        ));
  }
}
