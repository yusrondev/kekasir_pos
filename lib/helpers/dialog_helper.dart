import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/components/custom_button_component.dart';

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
          clipBehavior: Clip.hardEdge,
          backgroundColor: Colors.white,
          title: Text("Konfirmasi", style: TextStyle(fontFamily: 'Lexend'),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Apakah Anda yakin ingin menghapus $content?"),
              Gap(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: ButtonPrimaryOutline(
                        text: "Batal",
                      ),
                    )
                  ),
                  Gap(5),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        onConfirm();
                      },
                      child: ButtonPrimary(
                        text: "Yakin",
                      ),
                    )
                  ),
                ],
              )
            ],
          ),
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
          clipBehavior: Clip.hardEdge,
          backgroundColor: Colors.white,
          title: Text("Konfirmasi", style: TextStyle(fontFamily: 'Lexend'),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Apakah Anda yakin ingin menyimpan data ini?"),
              Gap(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ButtonPrimaryOutline(
                      text: "Batal",
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                  ),
                  Gap(5),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        onConfirm();
                      },
                      child: ButtonPrimary(
                        text: "Yakin",
                      ),
                    )
                  ),
                ],
              )
            ],
          ),
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
          clipBehavior: Clip.hardEdge,
          backgroundColor: Colors.white,
          title: Text("Konfirmasi", style: TextStyle(fontFamily: 'Lexend'),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Apakah Anda yakin ingin keluar?"),
              Gap(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: ButtonPrimaryOutline(
                        text: "Batal",
                      ),
                    )
                  ),
                  Gap(5),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        onConfirm();
                      },
                      child: ButtonPrimary(
                        text: "Yakin",
                      ),
                    )
                  ),
                ],
              )
            ],
          ),
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
          clipBehavior: Clip.hardEdge,
          backgroundColor: Colors.white,
          title: Text("Konfirmasi", style: TextStyle(fontFamily: 'Lexend'),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Apakah Anda yakin ingin menyelesaikan pembayaran ini?"),
              Gap(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: ButtonPrimaryOutline(
                        text: "Batal",
                      ),
                    )
                  ),
                  Gap(5),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        onConfirm();
                      },
                      child: ButtonPrimary(
                        text: "Yakin",
                      ),
                    )
                  ),
                ],
              )
            ],
          ),
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
          clipBehavior: Clip.hardEdge,
          backgroundColor: Colors.white,
          title: Text("Konfirmasi", style: TextStyle(fontFamily: 'Lexend'),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Apakah Anda yakin ingin menghapus semua data keranjang?"),
              Gap(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: ButtonPrimaryOutline(
                        text: "Batal",
                      ),
                    )
                  ),
                  Gap(5),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        onConfirm();
                      },
                      child: ButtonPrimary(
                        text: "Yakin",
                      ),
                    )
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  static void customDialog({
    required BuildContext context,
    required VoidCallback onConfirm,
    String? title = "",
    String? content,
    bool? actionButton
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          clipBehavior: Clip.hardEdge,
          backgroundColor: Colors.white,
          title: Text(title != "" ? '$title' : "Gagal"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$content'),
              if(actionButton == true) ... [
                Gap(15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: ButtonPrimaryOutline(
                          text: "Batal",
                        ),
                      )
                    ),
                    Gap(5),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          onConfirm();
                        },
                        child: ButtonPrimary(
                          text: "Yakin",
                        ),
                      )
                    ),
                  ],
                )
              ]
            ],
          ),
        );
      },
    );
  }

  static void customDialogRingkasan({
    required BuildContext context,
    required VoidCallback onConfirm,
    String? title = "",
    Widget? content,
    bool? actionButton
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          clipBehavior: Clip.hardEdge,
          backgroundColor: Colors.white,
          title: Text(title != "" ? '$title' : "Gagal"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              content as Widget,
              if(actionButton == true) ... [
                Gap(15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: ButtonPrimaryOutline(
                          text: "Batal",
                        ),
                      )
                    ),
                    Gap(5),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          onConfirm();
                        },
                        child: ButtonPrimary(
                          text: "Yakin",
                        ),
                      )
                    ),
                  ],
                )
              ]
            ],
          ),
        );
      },
    );
  }
}