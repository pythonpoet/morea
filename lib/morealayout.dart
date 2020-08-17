import 'package:flutter/material.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/morea_firestore.dart';

import 'Pages/About/about.dart';
import 'Pages/Personenverzeichniss/personen_verzeichniss_page.dart';
import 'Pages/Personenverzeichniss/profile_page.dart';
import 'Widgets/Action/scan.dart';
import 'morea_strings.dart';

class MoreaColors {
  static Color violett = Color(0xff7a62ff);
  static Color orange = Color(0xffff9262);
  static int violettInt = 0xff7a62ff;
  static int orangeInt = 0xffff9262;
  static int appBarInt = 0xffFF9B70;
  static Color bottomAppBar = Color.fromRGBO(43, 16, 42, 1);
  static Color greyButton = Color.fromRGBO(230, 230, 230, 1);

  //306bac 3626A7
  static Map<int, Color> violettMaterialColor = {
    50: Color.fromRGBO(122, 98, 255, 0.1),
    100: Color.fromRGBO(122, 98, 255, 0.2),
    200: Color.fromRGBO(122, 98, 255, 0.3),
    300: Color.fromRGBO(122, 98, 255, 0.4),
    400: Color.fromRGBO(122, 98, 255, 0.5),
    500: Color.fromRGBO(122, 98, 255, 0.6),
    600: Color.fromRGBO(122, 98, 255, 0.7),
    700: Color.fromRGBO(122, 98, 255, 0.8),
    800: Color.fromRGBO(122, 98, 255, 0.9),
    900: Color.fromRGBO(122, 98, 255, 1),
  };
}

class MoreaShadow {
  static BoxDecoration teleblitz = BoxDecoration(
      color: Color.fromRGBO(255, 255, 255, 0.9),
//      boxShadow: [
//        BoxShadow(
//            color: Color.fromRGBO(0, 0, 0, 0.16),
//            offset: Offset(3, 3),
//            blurRadius: 40)
//      ],
      borderRadius: BorderRadius.all(Radius.circular(10)));
}

class MoreaShadowContainer extends Container {
  MoreaShadowContainer({
    this.child,
  });

  @override
  final Decoration decoration = MoreaShadow.teleblitz;
  final EdgeInsetsGeometry margin =
      EdgeInsets.only(top: 20, right: 20, left: 20, bottom: 40);
  final Widget child;
  final Color color = Color.fromRGBO(255, 255, 255, 0.8);
  final BoxConstraints constraints = BoxConstraints(maxWidth: 450);
}

class MoreaBackgroundContainer extends Container {
  MoreaBackgroundContainer({this.child, this.constraints});

  @override
  final BoxConstraints constraints;
  final Decoration decoration = BoxDecoration(
    color: MoreaColors.orange,
    image: DecorationImage(
        image: AssetImage('assets/images/background.png'),
        alignment: Alignment.bottomCenter,
        fit: BoxFit.fitWidth),
  );
  final Widget child;
  final Alignment alignment = Alignment.topCenter;
  final Color color = Color.fromRGBO(255, 255, 255, 0.8);
}

const TextStyle MoreaTextStyleTop = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w600,
);

const TextStyle MoreaTextStyleBottom = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w400,
);

Widget moreaLoadingIndicator(
    AnimationController _controller, Animation<double> animation) {
  return Container(
    child: AnimatedBuilder(
      animation: _controller,
      child: Image(image: AssetImage('assets/icon/logo_loading.png')),
      builder: (BuildContext context, Widget child) {
        return Transform.rotate(
          angle: animation.value,
          child: child,
        );
      },
    ),
  );
}



class MoreaDivider extends Divider {
  final double thickness = 1;
  final Color color = Colors.black26;
}

BottomAppBar moreaChildBottomAppBar(Map navigationMap) {
  return BottomAppBar(
    color: MoreaColors.bottomAppBar,
    elevation: 0,
    child: Container(
      child: Row(
        children: <Widget>[
          Expanded(
            child: FlatButton(
              padding: EdgeInsets.symmetric(vertical: 15),
              onPressed: navigationMap[toMessagePage],
              child: Column(
                children: <Widget>[
                  Icon(Icons.message, color: Colors.white),
                  Text(
                    'Nachrichten',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.white),
                  )
                ],
                mainAxisSize: MainAxisSize.min,
              ),
            ),
            flex: 1,
          ),
          Expanded(
            child: FlatButton(
              padding: EdgeInsets.symmetric(vertical: 15),
              onPressed: navigationMap[toAgendaPage],
              child: Column(
                children: <Widget>[
                  Icon(Icons.event, color: Colors.white),
                  Text(
                    'Agenda',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.white),
                  )
                ],
                mainAxisSize: MainAxisSize.min,
              ),
            ),
            flex: 1,
          ),
          Expanded(
            child: FlatButton(
              padding: EdgeInsets.symmetric(vertical: 15),
              onPressed: navigationMap[toHomePage],
              child: Column(
                children: <Widget>[
                  Icon(Icons.flash_on, color: Colors.white),
                  Text(
                    'Teleblitz',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.white),
                  )
                ],
                mainAxisSize: MainAxisSize.min,
              ),
            ),
            flex: 1,
          ),
          Expanded(
            child: FlatButton(
              padding: EdgeInsets.symmetric(vertical: 15),
              onPressed: navigationMap[toProfilePage],
              child: Column(
                children: <Widget>[
                  Icon(Icons.person, color: Colors.white),
                  Text(
                    'Profil',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.white),
                  )
                ],
                mainAxisSize: MainAxisSize.min,
              ),
            ),
            flex: 1,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        textBaseline: TextBaseline.alphabetic,
      ),
    ),
    shape: CircularNotchedRectangle(),
  );
}

BottomAppBar moreaLeiterBottomAppBar(Map navigationMap, String centerText) {
  return BottomAppBar(
    elevation: 0,
    color: MoreaColors.bottomAppBar,
    child: Container(
      child: Row(
        children: <Widget>[
          Expanded(
            child: FlatButton(
              padding: EdgeInsets.symmetric(vertical: 15),
              onPressed: navigationMap[toMessagePage],
              child: Column(
                children: <Widget>[
                  Icon(Icons.message, color: Colors.white),
                  Text(
                    'Nachrichten',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.white),
                  )
                ],
                mainAxisSize: MainAxisSize.min,
              ),
            ),
            flex: 1,
          ),
          Expanded(
            child: FlatButton(
              padding: EdgeInsets.symmetric(vertical: 15),
              onPressed: navigationMap[toAgendaPage],
              child: Column(
                children: <Widget>[
                  Icon(Icons.event, color: Colors.white),
                  Text(
                    'Agenda',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.white),
                  )
                ],
                mainAxisSize: MainAxisSize.min,
              ),
            ),
            flex: 1,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Text(
                centerText,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
            flex: 1,
          ),
          Expanded(
            child: FlatButton(
              padding: EdgeInsets.symmetric(vertical: 15),
              onPressed: navigationMap[toHomePage],
              child: Column(
                children: <Widget>[
                  Icon(Icons.flash_on, color: Colors.white),
                  Text(
                    'Teleblitz',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.white),
                  )
                ],
                mainAxisSize: MainAxisSize.min,
              ),
            ),
            flex: 1,
          ),
          Expanded(
            child: FlatButton(
              padding: EdgeInsets.symmetric(vertical: 15),
              onPressed: navigationMap[toProfilePage],
              child: Column(
                children: <Widget>[
                  Icon(Icons.person, color: Colors.white),
                  Text(
                    'Profil',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.white),
                  )
                ],
                mainAxisSize: MainAxisSize.min,
              ),
            ),
            flex: 1,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        textBaseline: TextBaseline.alphabetic,
      ),
    ),
    shape: CircularNotchedRectangle(),
  );
}

Drawer moreaDrawer(
    String pos,
    String displayName,
    String email,
    BuildContext context,
    MoreaFirebase moreafire,
    CrudMedthods crud0,
    Function signedOut) {
  if (pos == 'Leiter') {
    return Drawer(
      child: ListView(
        children: <Widget>[
          new UserAccountsDrawerHeader(
            accountName: new Text(displayName),
            accountEmail: new Text(email),
            decoration: new BoxDecoration(
              color: MoreaColors.orange,
            ),
          ),
          new ListTile(
              title: new Text('Personen'),
              trailing: new Icon(Icons.people),
              onTap: () => Navigator.of(context)
                  .push(new MaterialPageRoute(
                      builder: (BuildContext context) =>
                          new PersonenVerzeichnisState(
                            moreaFire: moreafire,
                            crud0: crud0,
                          )))
                  .then((onvalue) =>
                      moreafire.getData(moreafire.getUserMap[userMapUID]))),
          new ListTile(
            title: new Text("TN zu Leiter machen"),
            trailing: new Icon(Icons.enhanced_encryption),
            onTap: () => makeLeiterWidget(context,
                moreafire.getUserMap[userMapUID], moreafire.getGroupIDs[0]),
          ),
          new Divider(),
          new ListTile(
              title: new Text("Über dieses App"),
              trailing: new Icon(Icons.info),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) => new AboutThisApp()))),
          new Divider(),
          new ListTile(
            title: new Text('Logout'),
            trailing: new Icon(Icons.cancel),
            onTap: (){
              Navigator.of(context).pop();
              signedOut();
            },
          )
        ],
      ),
    );
  } else if (pos == 'Teilnehmer') {
    return Drawer(
      child: ListView(
        children: <Widget>[
          new UserAccountsDrawerHeader(
            accountName: new Text(displayName),
            accountEmail: new Text(email),
            decoration: new BoxDecoration(color: MoreaColors.orange),
          ),
          ListTile(
              title: new Text('Eltern hinzufügen'),
              trailing: new Icon(Icons.add),
              onTap: () => Navigator.of(context)
                  .push(new MaterialPageRoute(
                      builder: (BuildContext context) => new ProfilePageState(
                            profile: moreafire.getUserMap,
                            moreaFire: moreafire,
                            crud0: crud0,
                            signOut: signedOut,
                          )))
                  .then((onvalue) =>
                      moreafire.getData(moreafire.getUserMap[userMapUID]))),
          Divider(),
          new ListTile(
              title: new Text("Über dieses App"),
              trailing: new Icon(Icons.info),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) => new AboutThisApp()))),
          new Divider(),
          new ListTile(
            title: new Text('Logout'),
            trailing: new Icon(Icons.cancel),
            onTap: (){
              Navigator.of(context).pop();
              signedOut();
            },
          )
        ],
      ),
    );
  } else if (pos == 'Mutter' ||
      pos == 'Vater' ||
      pos == 'Erziehungsberechtigte' ||
      pos == 'Erziehungsberechtigter') {
    return Drawer(
      child: ListView(
        children: <Widget>[
          new UserAccountsDrawerHeader(
            accountName: Text(displayName),
            accountEmail: Text(email),
            decoration: new BoxDecoration(color: MoreaColors.orange),
          ),
          new ListTile(
              title: new Text('Kinder hinzufügen'),
              trailing: new Icon(Icons.add),
              onTap: () => Navigator.of(context)
                  .push(new MaterialPageRoute(
                      builder: (BuildContext context) => new ProfilePageState(
                            profile: moreafire.getUserMap,
                            crud0: crud0,
                            moreaFire: moreafire,
                            signOut: signedOut,
                          )))
                  .then((onvalue) =>
                      moreafire.getData(moreafire.getUserMap[userMapUID]))),
          new Divider(),
          new ListTile(
              title: new Text("Über dieses App"),
              trailing: new Icon(Icons.info),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) => new AboutThisApp()))),
          new Divider(),
          new ListTile(
            title: new Text('Logout'),
            trailing: new Icon(Icons.cancel),
            onTap: (){
              Navigator.of(context).pop();
              signedOut();
            },
          )
        ],
      ),
    );
  } else {
    return Drawer();
  }
}
