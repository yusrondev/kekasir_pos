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
        color: Color(0xffff4757)
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
