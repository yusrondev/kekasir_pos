import 'package:flutter/material.dart';
import 'package:kekasir/components/custom_button_component.dart';
import 'package:kekasir/utils/ui_helper.dart';
import 'package:lottie/lottie.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';

bool _isDialogOpen = false;

void whatsappApps(BuildContext context) async {
  final Uri url = Uri.parse(
      'https://wa.me/6281232705237?text=Halo%20*Kekasir*%20saya%20ingin%20mengaktifkan%20layanan');
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    alertLottie(context, 'Tidak dapat membuka Whatsapp', 'error');
  }
}

void showNoExpiredDialog(BuildContext context) {
  if (!_isDialogOpen) {
    _isDialogOpen = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          clipBehavior: Clip.hardEdge,
          backgroundColor: Colors.white,
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Lottie.asset(
                    'assets/animations/error.json',
                    width: 60,
                    frameRate: const FrameRate(90),
                  ),
                ),
                const Gap(5),
                const Center(
                  child: Text(
                    "Masa aktif akun telah berakhir!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const Gap(5),
                const Center(
                  child: Text(
                    "Perpanjang agar tetap bisa mengakses layanan",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                const Gap(10),
                GestureDetector(
                  onTap: () => whatsappApps(context),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ButtonPrimary(
                          text: "Hubungi Kekasir",
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(5),
                const Center(
                  child: Text(
                    "Notifikasi ini akan tetap ditampilkan hingga akun Anda diaktifkan kembali.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((_) => _isDialogOpen = false);
  }
}
