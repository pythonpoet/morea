import 'package:flutter/material.dart';

import '../../morealayout.dart';

class SingleMessagePage extends StatelessWidget {
  SingleMessagePage(this.message);

  final message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(message.data['title']),
      ),
      body: MoreaBackgroundContainer(
        child: SingleChildScrollView(
          child: MoreaShadowContainer(
            child: Padding(
              padding:
                  EdgeInsets.only(top: 20, bottom: 40, left: 40, right: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Von: ' + message.data['sender'],
                    style: MoreaTextStyle.sender,
                  ),
                  MoreaDivider(),
                  Padding(
                    padding: EdgeInsets.all(10),
                  ),
                  Text(
                    message.data['title'],
                    textAlign: TextAlign.center,
                    style: MoreaTextStyle.title,
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                  ),
                  Text(
                    message.data['body'],
                    style: MoreaTextStyle.normal,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
