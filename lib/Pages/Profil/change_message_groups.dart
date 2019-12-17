import 'package:flutter/material.dart';
import 'package:morea/morealayout.dart';

class ChangeMessageGroups extends StatefulWidget {
  final bool biber, wombat, nahani, drason;
  final Function _changeMessageGroups;

  ChangeMessageGroups(this.biber, this.wombat, this.nahani, this.drason,
      this._changeMessageGroups);

  @override
  _ChangeMessageGroupsState createState() => _ChangeMessageGroupsState();
}

class _ChangeMessageGroupsState extends State<ChangeMessageGroups> {
  bool biber, wombat, nahani, drason;

  @override
  void initState() {
    super.initState();
    biber = widget.biber;
    wombat = widget.wombat;
    nahani = widget.nahani;
    drason = widget.drason;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nachrichtengruppen'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        backgroundColor: MoreaColors.violett,
        onPressed: () {
          widget._changeMessageGroups(biber, wombat, nahani, drason);
          Navigator.of(context).pop();
        },
      ),
      body: MoreaBackgroundContainer(
        child: SingleChildScrollView(
          child: MoreaShadowContainer(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Nachrichtengruppen ändern',
                    style: MoreaTextStyle.title,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: CheckboxListTile(
                      title: Text(
                        'Biber',
                        style: MoreaTextStyle.lable,
                      ),
                      value: biber,
                      onChanged: (val) => this.setState(() {
                        biber = val;
                      }),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: CheckboxListTile(
                      title: Text(
                        'Wombat (Wölfe)',
                        style: MoreaTextStyle.lable,
                      ),
                      value: wombat,
                      onChanged: (val) => this.setState(() {
                        wombat = val;
                      }),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: CheckboxListTile(
                      title: Text(
                        'Nahani (Meitli)',
                        style: MoreaTextStyle.lable,
                      ),
                      value: nahani,
                      onChanged: (val) => this.setState(() {
                        nahani = val;
                      }),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: CheckboxListTile(
                      title: Text(
                        'Drason (Buebe)',
                        style: MoreaTextStyle.lable,
                      ),
                      value: drason,
                      onChanged: (val) => this.setState(() {
                        drason = val;
                      }),
                    ),
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
