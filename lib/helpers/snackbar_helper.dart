import 'package:flutter/material.dart';
import 'package:kekasir/utils/colors.dart';

void showErrorSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Color(0xfffdcb6e),
      showCloseIcon: true,
      closeIconColor: Colors.black,
      behavior: SnackBarBehavior.floating, // Membuat snackbar mengambang
      elevation: 0,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.8, // Untuk menampilkan di atas
        left: 16,
        right: 16,
      ),
      duration: Duration(seconds: 1), // Durasi muncul
      content: Text(
        message,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: Colors.black,
        ),
      ),
      animation: CurvedAnimation(
        parent: ModalRoute.of(context)!.animation!,
        curve: Curves.easeOut, // Animasi lebih halus
      ),
    ),
  );
}

void showSuccessSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: bgSuccess,
      showCloseIcon: true,
      closeIconColor: successColor,
      behavior: SnackBarBehavior.floating, // Membuat snackbar mengambang
      elevation: 0,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.8, // Untuk menampilkan di atas
        left: 16,
        right: 16,
      ),
      duration: Duration(seconds: 1), // Durasi muncul
      content: Text(
        message,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: successColor,
        ),
      ),
      animation: CurvedAnimation(
        parent: ModalRoute.of(context)!.animation!,
        curve: Curves.easeOut, // Animasi lebih halus saat keluar
      ),
    ),
  );
}
