import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';

class CustomLoader {
  // Fungsi untuk mengembalikan widget Lottie
  static Widget showCustomLoader({double width = 50, double height = 50}) {
    return Lottie.asset(
      'assets/animations/loading.json',  // Ganti dengan path animasi Lottie kamu
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

class Wind {
  // Fungsi untuk mengembalikan widget Lottie
  static Widget showWind() {
    return Lottie.asset(
      'assets/animations/wind.json',  // Ganti dengan path animasi Lottie kamu
      width: 100,
      height: 100,
      frameRate: const FrameRate(90)
    );
  }
}

class TumbleWeed {
  // Fungsi untuk mengembalikan widget Lottie
  static Widget showTumbleWeed() {
    return Lottie.asset(
      'assets/animations/tumbleweed.json',  // Ganti dengan path animasi Lottie kamu
      width: 150,
      height: 150,
      frameRate: const FrameRate(90)
    );
  }
}
