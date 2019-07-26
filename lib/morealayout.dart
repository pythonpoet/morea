import 'package:flutter/material.dart';

class MoreaColors {

  static Color violett = Color(0xff7a62ff);
  static Color orange = Color(0xffff9262);
  static int violettInt = 0xff7a62ff;
  static int orangeInt = 0xffff9262;
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

class MainContainer extends StatelessWidget{

  MainContainer(this.child);

  Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: this.child
    );
  }

}
