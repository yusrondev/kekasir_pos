import 'package:flutter/material.dart';

class DialogHelper {
  static void showDeleteConfirmation({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Konfirmasi"),
          content: Text("Apakah Anda yakin ingin menghapus item ini?"),
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
}