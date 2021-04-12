import 'package:cloud_functions/cloud_functions.dart';


HttpsCallable getcallable(String functionName) {
  return FirebaseFunctions.instanceFor(region: "europe-west1").httpsCallable(functionName);
}

Future<HttpsCallableResult> callFunction(HttpsCallable callable,
    {Map<String, dynamic> param}) async {
  return await callable.call(param);
}
