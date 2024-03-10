import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:morea/Widgets/Group/Group_Face.dart';
import 'package:morea/Widgets/Group/Group_ListView.dart';
import 'package:morea/Widgets/standart/info.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/morealayout.dart';
import 'package:morea/services/auth.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/services/mailchimp_api_manager.dart';
import 'package:showcaseview/showcaseview.dart';

class GroupPage extends StatefulWidget {
  final auth;
  final MoreaFirebase moreaFire;
  final Map<String, Function> navigationMap;
  final FirebaseFirestore firestore;

  GroupPage(
      {required this.auth,
      required this.moreaFire,
      required this.navigationMap,
      required this.firestore});

  @override
  GroupPageState createState() => GroupPageState();
}

class GroupPageState extends State<GroupPage> {
  Map? userInfo;
  List nachrichtenGruppen = [];
  Auth auth0 = Auth();
  TextEditingController password = TextEditingController();
  String? oldEmail;
  String? newPassword;
  MailChimpAPIManager mailChimpAPIManager = MailChimpAPIManager();
  late CrudMedthods crud0;
  GlobalKey _floatingActionButtonKey = GlobalKey();
  GlobalKey _floatingActionButtonKey2 = GlobalKey();

  @override
  void initState() {
    super.initState();
    this.userInfo = widget.moreaFire.getUserMap;
    crud0 = CrudMedthods(widget.firestore);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoreaColors.bottomAppBar,
      drawer: moreaDrawer(this.userInfo!['Pos'], widget.moreaFire.getDisplayName,
          this.userInfo!['Email'], context, widget.moreaFire, crud0, _signedOut),
      body: MoreaBackgroundContainer(
          child: Column(
        children: [
          GroupListView(widget.moreaFire.getMapGroupData),
          StreamBuilder(
            stream: GroupListView.selectedGroupID.stream,
            builder: (context, AsyncSnapshot<String> aSGroupID) {
              if (!aSGroupID.hasData) return simpleMoreaLoadingIndicator();
              return GroupFace(
                groupID: aSGroupID.data!,
                moreaFire: widget.moreaFire,
              );
            },
          )
        ],
      )),
      appBar: AppBar(
        title: Text('Profil'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () => tutorial(),
          )
        ],
      ),
    );
  }

  void _signedOut() {
    widget.navigationMap[signedOut]!();
  }

  void updateProfile() async {
    await widget.moreaFire.getData(userInfo!['UID']);
    this.userInfo = widget.moreaFire.getUserMap;
  }

  FloatingActionButtonLocation _locationFloatingActionButton() {
    if (widget.moreaFire.getPos == "Leiter") {
      return FloatingActionButtonLocation.centerDocked;
    } else {
      return FloatingActionButtonLocation.endFloat;
    }
  }

  BottomAppBar _bottomAppBarBuilder() {
    if (widget.moreaFire.getPos == "Leiter") {
      return moreaLeiterBottomAppBar(widget.navigationMap, 'Ändern', MoreaBottomAppBarActivePage.none);
    } else {
      return moreaChildBottomAppBar(widget.navigationMap);
    }
  }

  void tutorial() {
    ShowCaseWidget.of(context)
        .startShowCase([_floatingActionButtonKey, _floatingActionButtonKey2]);
  }
}
