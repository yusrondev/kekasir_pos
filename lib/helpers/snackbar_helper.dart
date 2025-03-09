import 'package:flutter/material.dart';
import 'package:kekasir/utils/colors.dart';

void showErrorSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Color(0xfff1f2f6),
      showCloseIcon: true,
      closeIconColor: Colors.black,
      content: Text(message, style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: Colors.black
      ),),
    ),
  );
}

void showSuccessSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: bgSuccess,
      showCloseIcon: true,
      closeIconColor: successColor,
      content: Text(message, style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: successColor
      ),),
    ),
  );
}
