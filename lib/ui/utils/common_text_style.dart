import 'dart:ui';

import 'package:flutter/material.dart';

TextStyle semiBoldStyle(
  double fontSize,
  Color fontColor,
  FontWeight fontWeight,
) {
  return TextStyle(
    fontFamily: 'OpenSansSemiBold',
    fontWeight: fontWeight,
    fontSize: fontSize,
    color: fontColor,
  );
}

TextStyle semiBoldStyleCom() {
  return TextStyle(
    fontFamily: 'OpenSansSemiBold',
    fontWeight: FontWeight.w700,
    fontSize: 20.0,
    color: Colors.black,
  );
}
