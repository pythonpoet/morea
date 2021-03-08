import 'package:cloud_functions/cloud_functions.dart';


HttpsCallable getcallable(String functionName) {
  return CloudFunctions(region: "europe-west1").getHttpsCallable(functionName: functionName);
}

Future<HttpsCallableResult> callFunction(HttpsCallable callable,
    {Map<String, dynamic> param}) async {
  return await callable.call(param);
}
