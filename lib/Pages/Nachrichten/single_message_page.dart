import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SingleMessagePage extends StatelessWidget{
  
  SingleMessagePage({this.message});
  
  DocumentSnapshot message;
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(this.message.data['title']),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Text(this.message.data['body']),
        ),
      ),
    );
  }
}