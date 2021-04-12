import 'package:flutter/material.dart';
import 'package:morea/Widgets/standart/moreaTextStyle.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/morealayout.dart';
import 'select_teleblitz_type.dart';

class SelectStufe extends StatefulWidget {
  SelectStufe(this.moreaFire);

  final MoreaFirebase moreaFire;

  @override
  _SelectStufeState createState() => _SelectStufeState();
}

class _SelectStufeState extends State<SelectStufe> {
  List<Map<String, dynamic>> subgroups = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Stufe wählen"),
        ),
        body: MoreaBackgroundContainer(
          child: SingleChildScrollView(
            child: MoreaShadowContainer(
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: FutureBuilder(
                    future: widget.moreaFire.getSubgroups(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return Text(
                          'Loading...',
                          style: MoreaTextStyle.normal,
                        );
                      } else {
                        this.initSubgroups(snapshot.data);
                        return ListView.separated(
                            shrinkWrap: true,
                            itemCount: this.subgroups.length,
                            separatorBuilder:
                                (BuildContext context, int index) {
                              if (index < this.subgroups.length - 1) {
                                return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    child: Divider(
                                      thickness: 1,
                                      color: Colors.black26,
                                    ));
                              } else {
                                return null;
                              }
                            },
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                  title: Text(
                                    this.subgroups[index]
                                        [groupMapgroupNickName],
                                    style: MoreaTextStyle.lable,
                                  ),
                                  contentPadding: EdgeInsets.only(
                                    right: 15,
                                    left: 15,
                                  ),
                                  trailing: Icon(Icons.arrow_forward_ios),
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                SelectTeleblitzType(
                                                    subgroups[index],
                                                    widget.moreaFire)));
                                  });
                            });
                      }
                    }),
              ),
            ),
          ),
        ));
  }

  void initSubgroups(Map<String, dynamic> subgroups) async {
    subgroups.forEach((key, value) {
      this.subgroups.add(value);
    });
  }
}
