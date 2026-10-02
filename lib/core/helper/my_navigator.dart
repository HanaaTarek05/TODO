import 'package:flutter/material.dart';

enum NavigatorType {
  push,
  pushReplacement,
  pushAndRemoveUntil,
}

abstract class MyNavigator {
  static void goTo(
    BuildContext context, {
    required Widget toPage,
    NavigatorType type = NavigatorType.push,
  }) {
    var route = MaterialPageRoute(builder: (context) => toPage);
    if (type == NavigatorType.push) {
      Navigator.push(context, route);
    } else if (type == NavigatorType.pushReplacement) {
      Navigator.pushReplacement(context, route);
    } else if (type == NavigatorType.pushAndRemoveUntil) {
      Navigator.pushAndRemoveUntil(context, route, (r) => false);
    }
  }
}
