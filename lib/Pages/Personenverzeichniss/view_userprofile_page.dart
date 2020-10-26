import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:morea/Widgets/animated/MoreaLoading.dart';
import 'package:morea/Widgets/standart/moreaTextStyle.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/morealayout.dart';
import 'package:morea/services/utilities/url_launcher.dart';
import 'edit_userprofile_page.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/Widgets/standart/info.dart';
import 'package:morea/services/crud.dart';

class ViewUserProfilePage extends StatefulWidget {
  ViewUserProfilePage(this.uID, this.moreaFire, this.crud0);

  final String uID;
  final CrudMedthods crud0;
  final MoreaFirebase moreaFire;

  @override
  _ViewUserProfilePageState createState() => _ViewUserProfilePageState();
}

class _ViewUserProfilePageState extends State<ViewUserProfilePage>
    with TickerProviderStateMixin {
  Map<String, dynamic> profile;
  MoreaLoading moreaLoading;

  final Urllauncher urllauncher = new Urllauncher();

  @override
  void initState() {
    super.initState();
    moreaLoading = MoreaLoading(this);
  }

  @override
  void dispose() {
    moreaLoading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Container(
            child: FutureBuilder<DocumentSnapshot>(
                future: widget.crud0.getDocument(pathUser, widget.uID),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return moreaLoading.loading();
                  } else if (!snapshot.hasData) {
                    return Scaffold(
                      appBar: AppBar(
                        title: Text('Profil nicht vorhanden'),
                      ),
                    );
                  } else {
                    this.profile = snapshot.data.data();
                    return Scaffold(
                        appBar: AppBar(
                          title: Text(this.profile[userMapVorName]),
                        ),
                        body: MoreaBackgroundContainer(
                            child: SingleChildScrollView(
                          child: MoreaShadowContainer(
                            child: viewprofile(),
                          ),
                        )),
                        floatingActionButton: new FloatingActionButton(
                            elevation: 1.0,
                            child: new Icon(Icons.edit),
                            backgroundColor: Color(0xff7a62ff),
                            onPressed: () => Navigator.of(context).push(
                                new MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        new EditUserProfilePage(
                                            profile: profile,
                                            moreaFire: widget.moreaFire,
                                            crud0: widget.crud0)))));
                  }
                })));
  }

  Widget viewprofile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Profil',
            style: MoreaTextStyle.title,
          ),
        ),
        ListTile(
          title: Text(
            'Name',
            style: MoreaTextStyle.lable,
          ),
          subtitle: Text(
            profile['Pfadinamen'] == null
                ? '${profile["Vorname"]} ${profile["Nachname"]}'
                : '${profile["Vorname"]} ${profile["Nachname"]} v/o ${profile["Pfadinamen"]}',
            style: MoreaTextStyle.normal,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: MoreaDivider(),
        ),
        ListTile(
          title: Text(
            'Adresse',
            style: MoreaTextStyle.lable,
          ),
          subtitle: Text(
            '${profile["Adresse"]}, ${profile["PLZ"]} ${profile["Ort"]}',
            style: MoreaTextStyle.normal,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: MoreaDivider(),
        ),
        ListTile(
          title: Text(
            'E-Mail-Adresse',
            style: MoreaTextStyle.lable,
          ),
          subtitle: Text(
            profile["Email"] == null ? '' : profile['Email'],
            style: MoreaTextStyle.normal,
          ),
          onTap: () => urllauncher.openMail(profile['Email']),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: MoreaDivider(),
        ),
        ListTile(
          title: Text(
            'Handynummer',
            style: MoreaTextStyle.lable,
          ),
          subtitle: Text(
            profile['Handynummer'] == null ? '' : profile['Handynummer'],
            style: MoreaTextStyle.normal,
          ),
          onTap: () => urllauncher.openPhone(profile['Handynummer']),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: MoreaDivider(),
        ),
        ListTile(
          title: Text(
            'Geschlecht',
            style: MoreaTextStyle.lable,
          ),
          subtitle: Text(
            profile['Geschlecht'],
            style: MoreaTextStyle.normal,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: MoreaDivider(),
        ),
        ListTile(
          title: Text(
            'Geburtstag',
            style: MoreaTextStyle.lable,
          ),
          subtitle: Text(
            profile['Geburtstag'] == null ? '' : profile['Geburtstag'],
            style: MoreaTextStyle.normal,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: MoreaDivider(),
        ),
        ListTile(
          title: Text(
            'Rolle',
            style: MoreaTextStyle.lable,
          ),
          subtitle: Text(
            profile['Pos'],
            style: MoreaTextStyle.normal,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20),
        ),
      ],
    );
  }

  List<Widget> parentWidget() {
    List<Widget> elternWidget = new List();
    for (Future<DocumentSnapshot> dSParent in getParentMap()) {
      elternWidget.add(Container(
        child: FutureBuilder(
          future: dSParent,
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> aSParent) {
            if (!aSParent.hasData)
              return simpleMoreaLoadingIndicator();
            else
              return displayEltern(aSParent.data.data());
          },
        ),
      ));
    }
    return elternWidget;
  }

  Widget displayEltern(Map<String, dynamic> eltern) {
    return Column(
      children: <Widget>[
        Container(
            alignment: Alignment.center, //
            decoration: new BoxDecoration(
              border: new Border.all(color: Colors.black, width: 2),
              borderRadius: new BorderRadius.all(
                Radius.circular(4.0),
              ),
            ),
            child: Container(
                padding: EdgeInsets.all(5),
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                              child: Container(
                            child: Text(
                              'Rolle:',
                              style: TextStyle(fontSize: 20),
                            ),
                          )),
                          Expanded(
                              child: Container(
                                  child: Text(
                            eltern[userMapPos],
                            style: TextStyle(fontSize: 20),
                          )))
                        ],
                      ),
                    ),
                    Container(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                              child: Container(
                            child: Text(
                              'Vorname:',
                              style: TextStyle(fontSize: 20),
                            ),
                          )),
                          Expanded(
                              child: Container(
                                  child: Text(
                            eltern['Vorname'],
                            style: TextStyle(fontSize: 20),
                          )))
                        ],
                      ),
                    ),
                    Container(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                              child: Container(
                            child: Text(
                              'Nachname:',
                              style: TextStyle(fontSize: 20),
                            ),
                          )),
                          Expanded(
                              child: Container(
                                  child: Text(
                            eltern['Nachname'],
                            style: TextStyle(fontSize: 20),
                          ))),
                        ],
                      ),
                    ),
                    Container(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                              child: Container(
                            child: Text(
                              'Telefon:',
                              style: TextStyle(fontSize: 20),
                            ),
                          )),
                          Expanded(
                            child: InkWell(
                              child: Container(
                                  child: Text(
                                eltern['Handynummer'],
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Color.fromARGB(255, 0, 0, 255),
                                    decoration: TextDecoration.underline),
                              )),
                              onTap: () =>
                                  urllauncher.openPhone(eltern['Handynummer']),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                              child: Container(
                            child: Text(
                              'Email:',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          )),
                          Expanded(
                              child: InkWell(
                            child: Container(
                                child: Text(
                              eltern['Email'],
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Color.fromARGB(255, 0, 0, 255),
                                  decoration: TextDecoration.underline),
                            )),
                            onTap: () => urllauncher.openMail(eltern['Email']),
                          ))
                        ],
                      ),
                    ),
                  ],
                ))),
        SizedBox(
          height: 15,
        )
      ],
    );
  }

  List<Future<DocumentSnapshot>> getParentMap() {
    List<Future<DocumentSnapshot>> elternMap = new List();
    Map<String, String> elt = Map<String, String>.from(profile[userMapEltern]);
    List<String> elternUID = new List();
    elternUID.addAll(elt.values);
    elternUID.forEach(
        (uid) => elternMap.add(widget.moreaFire.getUserInformation(uid)));
    return elternMap;
  }
}
