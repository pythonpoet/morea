import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

// Mehr Infos auf: https://pub.dartlang.org/packages/url_launcher

abstract class BaseUrllauncher {
  Future<void> openMail(String email);

  Future<void> openPhone(String phonenumber);

  Future<void> openlinkMaps(String url);

  Future<void> openLatLongMaps(double latitude, double longitude);

  Future<void> openLink(String url);
}

class Urllauncher implements BaseUrllauncher {
  Urllauncher();
  Future<void> openMail(String email, {String subject, String body}) async {
    String url =
        'mailto:$email?${subject == null ? "" : ("subject=" + subject)}${body == null ? "" : ("&body=" + body)}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> openPhone(String phonenumber) async {
    String url = 'tel:$phonenumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> openlinkMaps(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> openLatLongMaps(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

  Future<void> openLink(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
