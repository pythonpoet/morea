import 'package:flutter/cupertino.dart';

class BlockedByDevToken extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      padding: EdgeInsets.all(15),
      child: new Text("Dieses Gerät wurde gesperrt.",
          style: new TextStyle(fontSize: 20)),
    ));
  }
}
