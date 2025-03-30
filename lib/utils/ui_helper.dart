import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';

void showErrorBottomSheet(BuildContext context, String message) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Container(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error, color: Colors.red, size: 40),
              SizedBox(height: 10),
              Text(
                "Terjadi Kesalahan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Gap(5),
              Text(
                "Server sedang bermasalah 🙏",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              Gap(30)
            ],
          ),
        ),
      );
    },
  );
}

void showErrorBottomSheetCustom(BuildContext context, String message) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Container(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error, color: Colors.red, size: 40),
              SizedBox(height: 10),
              Text(
                "Terjadi Kesalahan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Gap(5),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              Gap(30)
            ],
          ),
        ),
      );
    },
  );
}

void alertLottie(BuildContext context, String message, [String? icon]) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.4), // Atur tingkat transparansi
    builder: (BuildContext context) {
      if (icon == "" || icon == null) {
        icon = "success";
      }

      // Tutup otomatis setelah 2 detik
      Future.delayed(Duration(milliseconds: 2500), () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });

      return AlertDialog(
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Lottie.asset(
                "assets/animations/$icon.json",
                width: 60,
                frameRate: const FrameRate(90),
                repeat: false
              ),
            ),
            Gap(5),
            Center(child: Text(message, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600),))
          ],
        ),
      );
    },
  );
}

