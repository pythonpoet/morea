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
      length: 1 + widget.moreaFire.getGroupIDs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Personen'),
          bottom: TabBar(
            tabs: <Widget>[
              ...widget.moreaFire.getGroupIDs.map((groupID) => Tab(
                    text: convMiDatatoWebflow(groupID),
                  ))
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            ...widget.moreaFire.getGroupIDs.map((groupID) => personen(groupID))
          ],
        ),
      ),
    );
  }

  Widget personen(String groupID) {
    return FutureBuilder(
        future:
            widget.crud0.getCollection('$pathGroups/$groupID/$pathPriviledge'),
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> groupSnap) {
          if (!groupSnap.hasData) return moreaLoading.loading();
          List<Map<String, Map<String, dynamic>>> person = new List();

          if (groupSnap.data.documents.length > 0) {
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
                        Map<String, dynamic> person = Map<String, dynamic>.from(
                            groupSnap.data.documents[index].data);
                        String name = person[groupMapDisplayName];
                        String userUID =
                            groupSnap.data.documents[index].documentID;

                        return ListTile(
                          title: new Text(
                            name,
                            style: MoreaTextStyle.lable,
                          ),
                          onTap: () => navigatetoprofile(
                              person[groupMapPriviledgeEntryCustomInfo]),
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
