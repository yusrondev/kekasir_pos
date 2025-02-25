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
          backgroundColor: Colors.white,
          title: Text("Konfirmasi"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Apakah Anda yakin ingin menghapus item $content?"),
              Gap(10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: InkWell(
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
                    child: InkWell(
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
          backgroundColor: Colors.white,
          title: Text("Konfirmasi"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Apakah Anda yakin ingin menyimpan data ini?"),
              Gap(10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: InkWell(
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
                    child: InkWell(
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
          backgroundColor: Colors.white,
          title: Text("Konfirmasi"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Apakah Anda yakin ingin keluar?"),
              Gap(10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: InkWell(
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
                    child: InkWell(
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
          backgroundColor: Colors.white,
          title: Text("Konfirmasi"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Apakah Anda yakin ingin menyelesaikan pembayaran ini?"),
              Gap(10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: InkWell(
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
                    child: InkWell(
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
          backgroundColor: Colors.white,
          title: Text("Konfirmasi"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Apakah Anda yakin ingin menghapus semua data keranjang?"),
              Gap(10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: InkWell(
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
                    child: InkWell(
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
}