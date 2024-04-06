import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:morea/Pages/Agenda/Agenda_Eventadd_page.dart';
import 'package:morea/Widgets/standart/buttons.dart';
import 'package:morea/Widgets/standart/moreaTextStyle.dart';
import 'package:morea/morealayout.dart';
import 'package:morea/services/agenda.dart';
import 'package:morea/services/morea_firestore.dart';

class ViewEventPageState extends StatelessWidget {
  ViewEventPageState({required this.info, required this.pos, required this.moreaFire, required this.agenda, required this.fireStore});

  final MoreaFirebase moreaFire;
  final Agenda agenda;
  final Map<String, dynamic> info;
  final String pos;
  final FirebaseFirestore fireStore;

  @override
  Widget build(BuildContext context) {
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
              (info['Anfangszeit'] == 'Zeit wählen'
                  ? 'Zeitpunkt noch nicht entschieden'
                  : info['Anfangszeit'] + ' Uhr') +
                  ', ' +
                  (info['Anfangsort'] ==
                      ''
                      ? 'Ort noch nicht entschieden'
                      : info['Anfangsort']),
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
              (info['Schlusszeit'] == 'Zeit wählen'
                              ? 'Zeitpunkt noch nicht entschieden'
                              : info['Schlusszeit'] + ' Uhr') +
                          ', ' +
                          (info['Schlussort'] ==
                      ''
                  ? 'Ort noch nicht entschieden'
                  : info['Schlussort']),
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
          contentPadding:
              EdgeInsets.only(left: 15, right: 15, bottom: 10, top: 10),
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
                  firestore: fireStore,
                )))
        .then((onValue) {
      Navigator.of(context).pop();
    });
  }

  FloatingActionButton? floatingActionButton(context) {
    if (istLeiter()) {
      return moreaEditActionbutton(route: () => routeToLagerbearb(context));
    } else {
      return null;
    }
  }
}
