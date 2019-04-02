import 'package:flutter/material.dart';

class ToChildNavigation extends StatefulWidget {
  ToChildNavigation(this.profile);

  var profile;

  @override
  State<StatefulWidget> createState() => _ToChildNavigationState();
}

class _ToChildNavigationState extends State<ToChildNavigation> {
  List _kinder = [];

  @override
  void initState() {
    super.initState();
    _kinder = List.from(widget.profile["Kinder"].keys);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Kind auswählen/hinzufügen'),
      ),
      body: Container(
        child: Container(
          child: Column(children: [
            checkIfChildren(),
            RaisedButton(
                onPressed: () {
                  return null;
                  /*return Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => AddChild()))*/
                  ;
                },
                child: Text('Kind hinzufügen'))
          ]),
          alignment: Alignment.center,
          constraints: BoxConstraints(maxWidth: 200),
          margin: EdgeInsets.all(50),
        ),
        alignment: Alignment.topCenter,
      ),
    );
  }

  Widget checkIfChildren() {
    if (_kinder != null) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: _kinder.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(_kinder[index]),
            );
          });
    } else {
      return Container(
        height: 200,
      );
    }
  }
}
