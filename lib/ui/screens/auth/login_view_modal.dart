import 'package:flutter/cupertino.dart';

class LoginViewModal extends ChangeNotifier {
  int count = 0;

  increment() {
    count ++ ;
    notifyListeners();
  }

}
