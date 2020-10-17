import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:morea/Widgets/home/teleblitz.dart';
import 'package:morea/services/Event/data_types/Teleblitz_data.dart';
import 'package:morea/services/Event/event_data.dart';
import 'package:morea/services/crud.dart';
import 'package:morea/services/morea_firestore.dart';

class TeleblitzWidget extends StatelessWidget {
  TeleblitzWidget(
      {@required this.eventData,
      @required this.moreaFirebase,
      @required this.crudMedthods,
      @required this.eventID,
      @required this.function});

  final TeleblitzData eventData;
  final MoreaFirebase moreaFirebase;
  final CrudMedthods crudMedthods;
  final String eventID;
  final Stream<String> Function(String, String) function;

  @override
  Widget build(BuildContext context) {
    Teleblitz teleblitz = new Teleblitz(moreaFirebase, crudMedthods);
    return teleblitz.simpleTeleblitz(eventData, eventID, function);
  }
}
