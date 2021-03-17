import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:morea/Widgets/Group/Group_Roles.dart';
import 'package:morea/Widgets/standart/moreaTextStyle.dart';
import 'package:morea/morealayout.dart';
import 'package:morea/services/morea_firestore.dart';

class GroupFace extends StatefulWidget {
  final MoreaFirebase moreaFire;
  final String groupID;
  GroupFace({@required this.groupID, @required this.moreaFire});

  @override
  GroupFaceState createState() => GroupFaceState();
}

enum GroupFaceStateTypes { face, admin, priviledge, users, admin_face }

class GroupFaceState extends State<GroupFace> {
  GroupFaceStateTypes groupFaceStateTypes = GroupFaceStateTypes.face;

  @override
  Widget build(BuildContext context) {
    switch (groupFaceStateTypes) {
      case GroupFaceStateTypes.admin:
        return SingleChildScrollView(
            child: MoreaShadowContainer(
                child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: this.getTitel(),
                ),
                backToFace(),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
              child: Column(children: <Widget>[
                ElevatedButton(
                    child: Text("Edit Roles"),
                    onPressed: () {
                      setState(() {
                        groupFaceStateTypes = GroupFaceStateTypes.priviledge;
                      });
                    }),
                ElevatedButton(
                    child: Text("Edit users"),
                    onPressed: () => {
                          setState(() {
                            groupFaceStateTypes = GroupFaceStateTypes.users;
                          })
                        }),
                ElevatedButton(
                    child: Text("Edit GroupFace"),
                    onPressed: () => setState(() {
                          groupFaceStateTypes = GroupFaceStateTypes.priviledge;
                        })),
              ]),
            ),
          ],
        )));
      case GroupFaceStateTypes.priviledge:
        return SingleChildScrollView(
            child: MoreaShadowContainer(
                child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: this.getTitel(),
                ),
                backToFace(),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
              child: Column(children: <Widget>[
                GroupRoles(moreaFire: widget.moreaFire, groupID: widget.groupID)
              ]),
            ),
          ],
        )));
        break;

      default:
        return SingleChildScrollView(
            child: MoreaShadowContainer(
                child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: this.getTitel(),
                ),
                settings(),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, bottom: 15),
              child: Column(children: <Widget>[]),
            ),
          ],
        )));
        break;
    }
  }

  Container getTitel() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 0),
      alignment: Alignment.topLeft,
      child: Text(
          widget.moreaFire.getMapGroupData[widget.groupID].groupNickName,
          style: MoreaTextStyle.title),
    );
  }

  Widget settings() {
    //validate if user has rights to edit group
    if (widget.moreaFire.getMapGroupData[widget.groupID].priviledge.role
            .groupPriviledge >
        0)
      return IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            groupFaceStateTypes = GroupFaceStateTypes.admin;
            setState(() {});
          });
    else
      return Container();
  }

  Widget backToFace() {
    //validate if user has rights to edit group

    return IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          groupFaceStateTypes = GroupFaceStateTypes.face;
          setState(() {});
        });
  }
}
