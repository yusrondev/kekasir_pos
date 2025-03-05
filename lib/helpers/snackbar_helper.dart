import 'package:flutter/material.dart';
import 'package:kekasir/utils/colors.dart';

void showErrorSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Color(0xffe74c3c),
      showCloseIcon: true,
      content: Text(message, style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13
      ),),
    ),
  );
}

void showSuccessSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: bgSuccess,
      showCloseIcon: true,
      content: Text(message, style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: successColor
      ),),
    ),
  );
}
