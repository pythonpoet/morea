import 'package:flutter/material.dart';
import 'package:morea/Widgets/standart/buttons.dart';
import 'package:morea/morealayout.dart';
import 'package:morea/services/cloud_functions.dart';

class AddGroup extends StatefulWidget {
  AddGroup();

  @override
  State<StatefulWidget> createState() {
    return _AddGroupState();
  }
}

class _AddGroupState extends State<AddGroup> {
  TextEditingController _nickNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gruppe erstellen"),
      ),
      body: MoreaBackgroundContainer(
        child: SingleChildScrollView(
          child: MoreaShadowContainer(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nickNameController,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Bitte nicht leer lassen";
                      } else {
                        return null;
                      }
                    },
                  ),
                  moreaRaisedButton("ERSTELLEN", () async {
                    if (_formKey.currentState!.validate()) {
                      await callFunction(getcallable("createGroup"), param: {
                        "nickName": _nickNameController.text,
                        "upperClass": ["f7bl3m4GSpvvo7iw5wNd"]
                      });
                    }
                  })
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
