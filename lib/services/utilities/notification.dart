import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';

notificationGetPermission() async {
  if(Platform.isIOS != null){
    return await FirebaseMessaging.instance.requestPermission();
  }
}