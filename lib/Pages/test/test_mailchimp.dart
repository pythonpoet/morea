import 'package:flutter/material.dart';
import 'package:morea/services/mailchimp_api_manager.dart';
import 'package:morea/services/morea_firestore.dart';

class TestMailchimp extends StatelessWidget {

  MailChimpAPIManager mailChimpAPIManager = MailChimpAPIManager();
  MoreaFirebase moreafire;

  TestMailchimp(this.moreafire);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: FlatButton(
        child: Text('test'),
        onPressed: () => mailChimpAPIManager.updateUserInfo('test@morea.ch', 'Test', 'TestNachname', 'Männlich', '3775', moreafire),
      ),
    );
  }
}
