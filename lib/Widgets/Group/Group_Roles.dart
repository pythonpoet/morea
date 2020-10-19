import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:morea/services/morea_firestore.dart';

class GroupRoles extends StatefulWidget {
  final MoreaFirebase moreaFire;
  final String groupID;
  GroupRoles({@required this.moreaFire, @required this.groupID});

  GroupRolesState createState() => GroupRolesState();
}

class GroupRolesState extends State<GroupRoles> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount:
            widget.moreaFire.getMapGroupData[widget.groupID].roles.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(widget
                .moreaFire.getMapGroupData[widget.groupID].roles.keys
                .toList()[index]),
          );
        });
  }
}
