import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:qrcode_reader/qrcode_reader.dart';

abstract class BaseQrCode{
  Widget generate(String str);
  Future<void> german_scanQR();
}
class QrCode implements BaseQrCode{
  String qrResult, germanError = 'Um den Kopplungsvorgang mit deinem Kind abzuschliessen, scanne den Qr-Code, der im Profil deines Kindes ersichtlich ist.';
  Widget generate(String str){
    
    print(str);
    return new QrImage(
      data: str,
      size: 200,
    );
  }
  Future<void> german_scanQR() async{
    try{
      qrResult = await BarcodeScanner.scan();
      return;
    }on PlatformException catch (e){
      if(e.code == BarcodeScanner.CameraAccessDenied){
        germanError = 'Erlaube uns deine Kamera zu benutzen';

      }else{
        germanError = "Etwas ist schief gelaufen: $e";
      }
    }on FormatException{
      germanError = "Du hast den Scannvorgang abgebrochen";
    }catch (e){
      germanError = "Etwas ist schief gelaufen: $e";
    }
    return;
  }

}