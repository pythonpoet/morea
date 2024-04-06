import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract class BaseQrCode {
  Widget generate(String str);

  Future<void> germanScanQR();
}

class QrCode implements BaseQrCode {
  String? qrResult,
      germanError =
          'Um den Kopplungsvorgang mit deinem Kind abzuschliessen, scanne den Qr-Code, der im Profil deines Kindes ersichtlich ist.';

  Widget generate(String str) {
    return QrImageView(
      data: str,
      size: 200,
    );
  }

  /* Future<void> germanScanQR() async {
    try {
      qrResult = await BarcodeScanner.scan().toString();
      return;
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        germanError = 'Erlaube uns deine Kamera zu benutzen';
      } else {
        germanError = "Etwas ist schief gelaufen: $e";
      }
    } on FormatException {
      germanError = "Du hast den Scannvorgang abgebrochen";
    } catch (e) {
      germanError =
          "Etwas ist hat nicht funktioniert, bitte kontaktiere ein Leiter: $e";
    }
    return;
  } */

  Future<void> germanScanQR() async {
    try {
      qrResult = await FlutterBarcodeScanner.scanBarcode(
          '#FF0000', 'Abbrechen', true, ScanMode.QR);
      return;
    } on PlatformException catch (e) {
      print(e);
    }
  }
}
