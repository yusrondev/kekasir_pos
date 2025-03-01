import 'package:flutter/material.dart';

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
