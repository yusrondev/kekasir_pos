import 'package:flutter/material.dart';

class DialogHelper {
  static void showDeleteConfirmation({
    required BuildContext context,
    required VoidCallback onConfirm,
    String? content
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Konfirmasi"),
          content: Text("Apakah Anda yakin ingin menghapus item $content?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Tutup dialog tanpa hapus
              child: Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog dulu
                onConfirm(); // Panggil fungsi yang diberikan
              },
              child: Text("Yakin", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  static void showCreateConfirmation({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Konfirmasi"),
          content: Text("Apakah Anda yakin ingin menyimpan data ini?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Tutup dialog tanpa hapus
              child: Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog dulu
                onConfirm(); // Panggil fungsi yang diberikan
              },
              child: Text("Yakin", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
  
  static void showLogoutConfirmation({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Konfirmasi"),
          content: Text("Apakah Anda yakin ingin keluar?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Tutup dialog tanpa hapus
              child: Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog dulu
                onConfirm(); // Panggil fungsi yang diberikan
              },
              child: Text("Yakin", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
  
  static void showFinishPayment({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Konfirmasi"),
          content: Text("Apakah Anda yakin ingin menyelesaikan pembayaran ini?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Tutup dialog tanpa hapus
              child: Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog dulu
                onConfirm(); // Panggil fungsi yang diberikan
              },
              child: Text("Yakin", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  static void showDeleteAllCartConfirmation({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Konfirmasi"),
          content: Text("Apakah Anda yakin ingin menghapus semua data keranjang?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Tutup dialog tanpa hapus
              child: Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog dulu
                onConfirm(); // Panggil fungsi yang diberikan
              },
              child: Text("Yakin", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}