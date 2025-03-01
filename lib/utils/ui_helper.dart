import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

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
              Gap(10),
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
