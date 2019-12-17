import 'package:flutter/material.dart';
import 'package:morea/Pages/Agenda/Agenda_Eventadd_page.dart';
import 'package:morea/morealayout.dart';

class ViewEventPageState extends StatelessWidget {
  ViewEventPageState({this.info, this.pos});

  var info;
  String pos;

  @override
  Widget build(BuildContext context) {
    if (istLeiter()) {
      return Container(
          child: Scaffold(
        appBar: AppBar(
          title: Text(info['Eventname'].toString()),
        ),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return MoreaBackgroundContainer(
              child: SingleChildScrollView(
                  child: MoreaShadowContainer(
                child: viewEvent(),
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
    } else {
      return Container(
          child: Scaffold(
              appBar: AppBar(
                backgroundColor: Color(0xff7a62ff),
                title: Text(info['Eventname'].toString()),
              ),
              body: LayoutBuilder(
                builder:
                    (BuildContext context, BoxConstraints viewportConstraints) {
                  return SingleChildScrollView(
                      child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: viewportConstraints.maxHeight,
                    ),
                    child: viewEvent(),
                  ));
                },
              )));
    }
  }

  Widget viewEvent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            info['Eventname'],
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
          subtitle: Text(
            info['Datum'],
            style: MoreaTextStyle.normal,
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
          subtitle: Text(
            info['Beschreibung'],
            style: MoreaTextStyle.normal,
          ),
          contentPadding: EdgeInsets.all(15),
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
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: info['Mitnehmen'].length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  info['Mitnehmen'][index],
                  style: MoreaTextStyle.normal,
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
                  agendaModus: AgendaModus.event,
                )))
        .then((onValue) {});
  }
}
