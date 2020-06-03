import 'package:flutter/material.dart';

Future showWaitingProgress(BuildContext context, message) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        content: new Row(
          children: [
            CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor)),
            Container(
                margin: EdgeInsets.only(left: 5), child: Text(message)),
          ],
        ),
      );
    },
  );
}
