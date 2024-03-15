import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:morea/Widgets/animated/MoreaLoading.dart';
import 'package:morea/Widgets/home/elternpend.dart';
import 'package:morea/Widgets/standart/buttons.dart';
import 'package:morea/morea_strings.dart';
import 'package:morea/services/Event/event_Widget.dart';
import 'package:morea/services/Group/group_data.dart';
import 'package:morea/services/crud.dart';
import 'package:showcaseview/showcaseview.dart';
import 'select_stufe.dart';
import 'package:morea/services/morea_firestore.dart';
import 'package:morea/morealayout.dart';

class HomePage extends StatefulWidget {
  HomePage(
      {required this.firestore,
      required this.navigationMap,
      required this.moreafire,
      required this.tutorial});

  final FirebaseFirestore firestore;
  final Map<String, Function> navigationMap;
  final MoreaFirebase moreafire;
  final bool tutorial;

  @override
  State<StatefulWidget> createState() => HomePageState();
}

enum FormType { leiter, teilnehmer, eltern, loading }

enum Anmeldung { angemolden, abgemolden, verchilt }

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late CrudMedthods crud0;
  late MoreaFirebase moreafire;
  late MoreaLoading moreaLoading;
  GlobalKey _changeTeleblitzKey = GlobalKey();
  GlobalKey _bottomAppBarLeiterKey = GlobalKey();
  GlobalKey _drawerKey = GlobalKey();
  GlobalKey _bottomAppBarTNKey = GlobalKey();

  static final ScrollController homeScreenScrollController =
      new ScrollController();

  //final formKey = new GlobalKey<FormState>();

  //Dekleration welche ansicht gewählt wird für TN's Eltern oder Leiter
  FormType _formType = FormType.loading;

  bool chunnt = false;
  var messagingGroups;

  void getuserinfo() async {
    forminit();
    setState(() {});
  }

  void _signedOut() {
    widget.navigationMap[signedOut]!();
  }

  void forminit() {
    try {
      switch (moreafire.getPos) {
        case 'Teilnehmer':
          _formType = FormType.teilnehmer;
          break;
        case 'Leiter':
          _formType = FormType.leiter;
          break;
        case 'Mutter':
          _formType = FormType.eltern;
          break;
        case 'Vater':
          _formType = FormType.eltern;
          break;
        case 'Erziehungsberechtigter':
          _formType = FormType.eltern;
          break;
        case 'Erziehungsberechtigte':
          _formType = FormType.eltern;
          break;
      }
    } catch (e) {
      print(e);
    }
  }

  void autostartTutorial() {
    switch (_formType) {
      case FormType.leiter:
        tutorialLeiter();
        break;
      case FormType.teilnehmer:
        tutorialTN();
        break;
      case FormType.eltern:
        tutorialEltern();
        break;
      case FormType.loading:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    moreafire = widget.moreafire;
    crud0 = new CrudMedthods(widget.firestore);
    moreaLoading = new MoreaLoading(this);
    getuserinfo();
    if (widget.tutorial) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => this.autostartTutorial());
    }
  }

  @override
  void dispose() {
    moreaLoading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return teleblitzwidget();
  }

  Widget scrollView() {
    return MoreaBackgroundContainer(
      child: SingleChildScrollView(
        child: arrangeEvents(),
        controller: homeScreenScrollController,
      ),
    );
  }

  Widget arrangeEvents() {
    return StreamBuilder(
      stream: moreafire.getGroupDataStream,
      builder:
          (BuildContext context, AsyncSnapshot<Map<String, GroupData>> aSData) {
        if (!(aSData.connectionState == ConnectionState.active))
          return MoreaShadowContainer(
              child: Container(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height - 220),
                  child: Center(child: moreaLoading.loading())));

        List<String> sortedEvents = sortHomeFeedByStartDate(aSData.data!);
        if (sortedEvents.length == 0) return requestPrompttoParent();
        return Column(children: [
          ...sortedEvents.map((String eventID) => EventWidget(
              moreaFirebase: this.moreafire,
              crudMedthods: this.crud0,
              eventID: eventID,
              function: moreafire.tbz!.anmeldeStatus))
        ]);
      },
    );
  }

  Widget teleblitzwidget() {
    return Scaffold(
      backgroundColor: MoreaColors.bottomAppBar,
      appBar: AppBar(
        title: Text('Teleblitz'),
        backgroundColor: MoreaColors.orange,
      ),
      drawer: moreaDrawer(moreafire.getPos!, moreafire.getDisplayName!,
          moreafire.getEmail!, context, moreafire, crud0, _signedOut),
      body: MoreaBackgroundContainer(child: scrollView()),
      floatingActionButton: (moreafire.getPos == "Leiter")
          ? Showcase(
              key: _changeTeleblitzKey,
              disableMovingAnimation: true,
              description: 'Hier kannst du den Teleblitz ändern',
              child: moreaEditActionbutton(
                route: routeEditTelebliz,
              ))
          : SizedBox(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: (moreafire.getPos == "Leiter")
          ? Showcase.withWidget(
              key: _bottomAppBarLeiterKey,
              disableMovingAnimation: true,
              height: 500,
              width: 150,
              container: Container(
                padding: EdgeInsets.all(5),
                constraints: BoxConstraints(minWidth: 150, maxWidth: 150),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white),
                child: Column(
                  children: [
                    Text(
                      'Hier kannst du zu den verschiedenen Screens wechseln. Wechsle zum nächsten Screen und drücke dort den Hilfeknopf oben rechts.',
                    ),
                  ],
                ),
              ),
              child: moreaLeiterBottomAppBar(widget.navigationMap, "Ändern",
                  MoreaBottomAppBarActivePage.teleblitz))
          : Showcase.withWidget(
              key: _bottomAppBarTNKey,
              height: 300,
              width: 150,
              disableMovingAnimation: true,
              container: Container(
                padding: EdgeInsets.all(5),
                constraints: BoxConstraints(minWidth: 150, maxWidth: 150),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white),
                child: Column(
                  children: [
                    Text(
                      'Hier kannst du zu den verschiedenen Screens wechseln. Wechsle zum nächsten Screen und drücke dort den Hilfeknopf oben rechts.',
                    ),
                  ],
                ),
              ),
              child: moreaChildBottomAppBar(
                widget.navigationMap,
              )),
    );
  }

  List<Widget> navigation() {
    return [
      ListTile(
        leading: Text('Loading...'),
      )
    ];
  }

  void routeEditTelebliz() {
    Navigator.of(context)
        .push(new MaterialPageRoute(
            builder: (BuildContext context) => new SelectStufe(moreafire)))
        .then((onValue) {
      setState(() {});
    });
  }

  List<Widget> tutorialButton() {
    switch (_formType) {
      case FormType.leiter:
        return [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () => tutorialLeiter(),
          )
        ];
      case FormType.teilnehmer:
        return [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () => tutorialTN(),
          )
        ];
      case FormType.eltern:
        return [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () => tutorialEltern(),
          )
        ];
      case FormType.loading:
        return [];
      default:
        return [];
    }
  }

  void tutorialLeiter() {
    ShowCaseWidget.of(context).startShowCase(
        [_changeTeleblitzKey, _drawerKey, _bottomAppBarLeiterKey]);
  }

  void tutorialTN() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Text(
                  'Auf diesem Screen kannst du den Teleblitz deines Fähnlis sehen und dich dafür anmelden (ist nur möglich wenn eine Aktivität stattfindet)'),
            )).then((value) => ShowCaseWidget.of(context)
        .startShowCase([_drawerKey, _bottomAppBarTNKey]));
  }

  void tutorialEltern() {
    ShowCaseWidget.of(context).startShowCase([_drawerKey, _bottomAppBarTNKey]);
  }

  String tutorialDrawer() {
    switch (_formType) {
      case FormType.leiter:
        return 'Hier kannst du als Leiter das Profil deiner TNs ändern, TNs zu Leitern machen und dich ausloggen.';
      case FormType.teilnehmer:
        return 'Hier kannst du das Konto deiner Eltern verlinken, damit sie dich für Aktivitäten anmelden können, und dich ausloggen.';
      case FormType.eltern:
        return 'Hier kannst du das Konto deiner Kinder verlinken, damit du sie für Aktivitäten anmelden kannst, und dich ausloggen.';
      case FormType.loading:
        return 'Loading';
      default:
        return 'Loading';
    }
  }
}
