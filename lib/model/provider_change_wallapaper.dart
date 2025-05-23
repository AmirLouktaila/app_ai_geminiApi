import 'package:flutter/material.dart';

class ProviderChangeWallapaper extends ChangeNotifier {
  String url_wallapaper =
      'https://www.transparenttextures.com/patterns/escheresque-dark.png';

  void changeWallapaper(String url) async {
    url_wallapaper = url;
    notifyListeners();
  }
}
