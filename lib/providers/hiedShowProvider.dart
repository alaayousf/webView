import 'package:flutter/material.dart';
class HiedShowProvider extends ChangeNotifier{
   bool value;
  HiedShowProvider({required this.value});


  void hiedProgres(bool value) {
    this.value=value;
    notifyListeners();
  }

}