import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';

import 'package:qrcode_reader/qrcode_reader.dart';

abstract class BaseQrCode{
  Widget generate(String str);
  Future<String>readQrCode();
}
class QrCode implements BaseQrCode{
  Widget generate(String str){
    
    print(str);
    return new QrImage(
      data: str,
      size: 200,
    );
  }
  Future<String> readQrCode()async{
    String   futureString =  await QRCodeReader().scan();
    print(futureString);
    return futureString;
  }

}