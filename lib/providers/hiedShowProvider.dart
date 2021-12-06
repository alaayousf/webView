import 'dart:developer';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';

class HiedShowProvider extends ChangeNotifier {
  bool value;
  bool connectedState;
  HiedShowProvider(this.value, this.connectedState);

  void hiedProgres(bool value) {
    this.value = value;
    notifyListeners();
  }



  void checonnectivity(bool connectied) {
    connectedState = connectied;
    notifyListeners();
  }

  Future initeConnectivity() async{


    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        connectedState = false;
        notifyListeners();
      } else {
        connectedState = true;
        notifyListeners();
      }
    } on PlatformException catch (e) {
      log('PlatformException');
        notifyListeners();
    }
  }
}
