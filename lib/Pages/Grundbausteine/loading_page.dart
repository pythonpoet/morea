import 'package:flutter/cupertino.dart';
import 'package:morea/Widgets/standart/info.dart';

class LoadingPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Center(
      child: simpleMoreaLoadingIndicator(),
    );
  }
}