import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:morea/Pages/Grundbausteine/login_page.dart';

notificationGetPermission(){
  if(Platform.isIOS != null){
    return FirebaseMessaging().requestNotificationPermissions();
  }
  FirebaseMessaging().configure();
}