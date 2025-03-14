import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';

class CustomLoader {
  // Fungsi untuk mengembalikan widget Lottie
  static Widget showCustomLoader({double width = 150, double height = 150}) {
    return Lottie.asset(
      'assets/animations/loader.json',  // Ganti dengan path animasi Lottie kamu
      width: width,
      height: height,
      frameRate: const FrameRate(90)
    );
  }
}

class EmptyProduct {
  // Fungsi untuk mengembalikan widget Lottie
  static Widget showEmptyProduct() {
    return Lottie.asset(
      'assets/animations/empty.json',  // Ganti dengan path animasi Lottie kamu
      width: 150,
      height: 150,
      frameRate: const FrameRate(90)
    );
  }
}
