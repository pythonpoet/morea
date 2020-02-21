import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:morea/Pages/Personenverzeichniss/view_userprofile_page.dart';
import 'package:morea/Widgets/animated/MoreaLoading.dart';
import 'package:morea/Widgets/standart/moreaTextStyle.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/morealayout.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/services/utilities/MiData.dart';

class PersonenVerzeichnisState extends StatefulWidget {
  PersonenVerzeichnisState({this.moreaFire, this.crud0});

  final MoreaFirebase moreaFire;
  final CrudMedthods crud0;

  @override
  State<StatefulWidget> createState() => PersonenVerzeichnisStatePage();
}

class PersonenVerzeichnisStatePage extends State<PersonenVerzeichnisState>
    with TickerProviderStateMixin {
  MoreaLoading moreaLoading;

  @override
  void initState() {
    super.initState();
    moreaLoading = new MoreaLoading(this);
  }

  @override
  void dispose() {
    moreaLoading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1 + widget.moreaFire.getSubscribedGroups.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Personen'),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                text: convMiDatatoWebflow(widget.moreaFire.getGroupID),
              ),
              ...widget.moreaFire.getSubscribedGroups.map((groupID) => Tab(
                    text: convMiDatatoWebflow(groupID),
                  ))
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            personen(widget.moreaFire.getGroupID),
            ...widget.moreaFire.getSubscribedGroups
                .map((groupID) => personen(groupID))
          ],
        ),
      ),
    );
  }

  Widget personen(String groupID) {
    return FutureBuilder(
        future: widget.crud0.getDocument(pathGroups, groupID),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> groupSnap) {
          if (!groupSnap.hasData) return moreaLoading.loading();
          List<Map<String, Map<String, dynamic>>> person = new List();
          if (groupSnap.data.data.containsKey(groupMapPriviledge)) if (groupSnap
                  .data[groupMapPriviledge].length >
              0) {
            Map<String, dynamic>.from(groupSnap.data[groupMapPriviledge])
                .forEach((k, v) => {
                      if (k != 'groupID')
                        {
                          person.add({k: Map<String, dynamic>.from(v)})
                        }
                    });
            return MoreaBackgroundContainer(
                child: SingleChildScrollView(
              child: MoreaShadowContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        convMiDatatoWebflow(groupID),
                        style: MoreaTextStyle.title,
                      ),
                    ),
                    ListView.separated(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: person.length,
                      itemBuilder: (context, int index) {
                        String name, userUID;
                        person[index].forEach((k, v) {
                          name = v[groupMapDisplayName];
                          userUID = k;
                        });
                        return ListTile(
                          title: new Text(
                            name,
                            style: MoreaTextStyle.lable,
                          ),
                          onTap: () => navigatetoprofile(
                              widget.moreaFire.getUserInformation(userUID)),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.black,
                          ),
                        );
                      },
                      separatorBuilder: (context, int index) {
                        return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: MoreaDivider());
                      },
                    ),
                    Container(
                      height: 20,
                    )
                  ],
                ),
              ),
            ));
          }
          return Center(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Text(
                "Niemand ist für diese Stufe Registriert",
                style: TextStyle(fontSize: 20),
              ),
            ),
          );
        });
  }

  navigatetoprofile(Future<DocumentSnapshot> userdata) {
    Navigator.of(context).push(new MaterialPageRoute(
        builder: (BuildContext context) =>
            new ViewUserProfilePage(userdata, widget.moreaFire, widget.crud0)));
  }
}
