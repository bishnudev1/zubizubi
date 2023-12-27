import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showToast(String message) {
  Fluttertoast.showToast(
    msg: message.toString(),
    toastLength: Toast.LENGTH_SHORT, // Duration for the toast
    gravity: ToastGravity.BOTTOM, // Toast gravity
    backgroundColor: Colors.limeAccent, // Background color of the toast
    textColor: Colors.white, // Text color of the toast message
    fontSize: 16.0, // Font size of the toast message
  );
}