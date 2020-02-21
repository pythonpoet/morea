import 'package:flutter/material.dart';
import 'package:morea/Pages/Agenda/Agenda_Eventadd_page.dart';
import 'package:morea/Widgets/standart/buttons.dart';
import 'package:morea/Widgets/standart/moreaTextStyle.dart';
import 'package:morea/morealayout.dart';
import 'package:morea/services/agenda.dart';
import 'package:morea/services/morea_firestore.dart';

class ViewEventPageState extends StatelessWidget {
  ViewEventPageState({this.info, this.pos, this.moreaFire, this.agenda});

  final MoreaFirebase moreaFire;
  final Agenda agenda;
  final Map info;
  final String pos;

  @override
  Widget build(BuildContext context) {
    if (info == null)
      return Card(
        child: Center(
          child: Container(
              padding: EdgeInsets.all(15),
              child: Text(
                "Dieses Event ist nicht eingetragen, wende dich an deine Leiter",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )),
        ),
      );
    return Scaffold(
      appBar: AppBar(
        title: Text(info['Eventname'].toString()),
      ),
      body: MoreaBackgroundContainer(
        child: SingleChildScrollView(
            child: MoreaShadowContainer(
          child: viewEvent(),
        )),
      ),
      floatingActionButton: floatingActionButton(context),
    );
  }

  Widget viewEvent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
          contentPadding: EdgeInsets.all(20),
          title: Text(
            info['Eventname'],
            style: MoreaTextStyle.title,
          ),
          trailing: Text(
            'Event',
            style: MoreaTextStyle.sender,
          ),
        ),
        ListTile(
          title: Text(
            'Datum',
            style: MoreaTextStyle.lable,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              info['Datum'],
              style: MoreaTextStyle.subtitle,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: MoreaDivider(),
        ),
        ListTile(
          title: Text(
            'Beginn',
            style: MoreaTextStyle.lable,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              info['Anfangszeit'] + ' Uhr, ' + info['Anfangsort'],
              style: MoreaTextStyle.subtitle,
            ),
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
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              info['Schlusszeit'] + ' Uhr, ' + info['Schlussort'],
              style: MoreaTextStyle.subtitle,
            ),
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
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              info['Beschreibung'],
              style: MoreaTextStyle.subtitle,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: MoreaDivider(),
        ),
        ListTile(
          contentPadding: EdgeInsets.only(left: 15, right: 15, bottom: 10, top: 10),
          title: Text(
            'Mitnehmen',
            style: MoreaTextStyle.lable,
          ),
          subtitle: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: info['Mitnehmen'].length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  '- ' + info['Mitnehmen'][index],
                  style: MoreaTextStyle.subtitle,
                ),
              );
            },
          ),
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
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              info['Kontakt']['Pfadiname'] + ': ' + info['Kontakt']['Email'],
              style: MoreaTextStyle.subtitle,
            ),
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
                  agendaModus: AgendaModus.event,
                  moreaFire: moreaFire,
                  agenda: agenda,
                )))
        .then((onValue) {
      Navigator.of(context).pop();
    });
  }

  FloatingActionButton floatingActionButton(context) {
    if (istLeiter()) {
      return moreaEditActionbutton(route: () => routeToLagerbearb(context));
    } else {
      return null;
    }
  }
}
