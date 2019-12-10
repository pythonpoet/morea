import 'package:flutter/material.dart';
import 'package:morea/Pages/Agenda/Agenda_Eventadd_page.dart';
import 'package:morea/morealayout.dart';

class ViewLagerPageState extends StatelessWidget {
  ViewLagerPageState({this.info, this.pos});

  var info;
  String pos;

  @override
  Widget build(BuildContext context) {
    print(info['Kontakt']['Pfadiname']);
    return Container(
        child: Scaffold(
      appBar: AppBar(
        title: Text(info['Lagername'].toString()),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return MoreaBackgroundContainer(
            child: SingleChildScrollView(
                child: MoreaShadowContainer(
              child: viewLager(),
            )),
          );
        },
      ),
      floatingActionButton: Opacity(
        opacity: istLeiter() ? 1.0 : 0.0,
        child: new FloatingActionButton(
          elevation: 0.0,
          child: new Icon(Icons.edit),
          backgroundColor: Color(0xff7a62ff),
          onPressed: () => routeToLagerbearb(context),
        ),
      ),
    ));
  }

  Widget viewLager() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            info['Lagername'],
            style: MoreaTextStyle.title,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: MoreaDivider(),
        ),
        ListTile(
            title: Text(
              'Datum',
              style: MoreaTextStyle.lable,
            ),
            subtitle: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'von: ' + info['Datum'],
                    style: MoreaTextStyle.normal,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    'bis: ' + info['Datum bis'],
                    style: MoreaTextStyle.normal,
                  ),
                )
              ],
            )),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: MoreaDivider(),
        ),
        ListTile(
          title: Text(
            'Lagerort',
            style: MoreaTextStyle.lable,
          ),
          subtitle: Text(
            info['Lagerort'],
            style: MoreaTextStyle.normal,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: MoreaDivider(),
        ),
        ListTile(
          title: Text(
            'Besammlung',
            style: MoreaTextStyle.lable,
          ),
          subtitle: Text(
            info['Anfangszeit'] + ' Uhr, ' + info['Anfangsort'],
            style: MoreaTextStyle.normal,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: MoreaDivider(),
        ),
        ListTile(
          title: Text(
            'Schluss',
            style: MoreaTextStyle.lable,
          ),
          subtitle: Text(
            info['Schlusszeit'] + ' Uhr, ' + info['Schlussort'],
            style: MoreaTextStyle.normal,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: MoreaDivider(),
        ),
        ListTile(
          title: Text(
            'Beschreibung',
            style: MoreaTextStyle.lable,
          ),
          contentPadding: EdgeInsets.all(15),
          subtitle: Text(
            info['Beschreibung'],
            style: MoreaTextStyle.normal,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: MoreaDivider(),
        ),
        ListTile(
          title: Text(
            'Mitnehmen',
            style: MoreaTextStyle.lable,
          ),
          contentPadding: EdgeInsets.all(15),
          subtitle: ListView.builder(
              itemCount: info['Mitnehmen'].length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    info['Mitnehmen'][index],
                    style: MoreaTextStyle.normal,
                  ),
                );
              }),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: MoreaDivider(),
        ),
        ListTile(
          title: Text(
            'Kontakt',
            style: MoreaTextStyle.lable,
          ),
          subtitle: Text(
            info['Kontakt']['Pfadiname'] + ': ' + info['Kontakt']['Email'],
            style: MoreaTextStyle.normal,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 20),
        )
      ],
    );
  }

  bool istLeiter() {
    if (pos == 'Leiter') {
      return true;
    } else {
      return false;
    }
  }

  void routeToLagerbearb(context) {
    Navigator.of(context)
        .push(new MaterialPageRoute(
            builder: (BuildContext context) => EventAddPage(
                  eventinfo: info,
                  agendaModus: AgendaModus.lager,
                )))
        .then((onValue) {});
  }
}
