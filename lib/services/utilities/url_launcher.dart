import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

// Mehr Infos auf: https://pub.dartlang.org/packages/url_launcher

abstract class BaseUrllauncher {
  Future<void> openMail(String email);

  Future<void> openPhone(String phonenumber);

  Future<void> openlinkMaps(String url);

  Future<void> openLatLongMaps(double latitude, double longitude);

  Future<void> openLink(Uri url);
}

class Urllauncher implements BaseUrllauncher {
  Urllauncher();
  Future<void> openMail(String email, {String? subject, String? body}) async {
    Uri url = Uri(scheme: 'mailto', path: email, queryParameters: {
      'subject': subject == null ? "" : subject,
      'body': body == null ? '' : body
    });
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> openPhone(String phonenumber) async {
    Uri url = Uri(scheme: 'tel', path: phonenumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
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
    Uri googleUrl = Uri.https(
        'www.google.com', 'maps/search/?api=1&query=$latitude,$longitude');
    if (await canLaunchUrl(googleUrl)) {
      await launchUrl(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

  Future<void> openLink(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
