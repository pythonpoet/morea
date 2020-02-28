import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';

notificationGetPermission(){
  if(Platform.isIOS != null){
    return FirebaseMessaging().requestNotificationPermissions();
  }
  FirebaseMessaging().configure();
}