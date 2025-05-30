import 'package:flutter/material.dart';
import 'package:kekasir/apis/auth_service.dart';
import 'package:kekasir/components/custom_button_component.dart';
import 'package:kekasir/pages/landing_page.dart';
import 'package:kekasir/utils/ui_helper.dart';
import 'package:lottie/lottie.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';

bool _isDialogOpen = false;
Map<String, dynamic>? dataMe;
AuthService authService = AuthService();

void whatsappApps(BuildContext context) async {

  final dataMe = await authService.fetchUser();

  if (dataMe == null) {
    Navigator.pop(context);
    throw Exception("Gagal mengambil data pengguna.");
  }

 final Uri url = Uri.parse(
    "https://wa.me/6288989690882?text="
    "Halo%20*Kekasir*%0A"
    "Saya%20ingin%20mengaktifkan%20layanan%0A%0A"
    "store_id%20:%20${dataMe['store_id']}%0A"
    "user_id%20:%20${dataMe['id']}%0A"
    "name%20:%20${dataMe['name']}%0A"
    "email%20:%20${dataMe['email']}"
  );

  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    alertLottie(context, 'Tidak dapat membuka Whatsapp', 'error');
  }
}

void logout(BuildContext context) async {
  await AuthService().logout();
  // ignore: use_build_context_synchronously
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => LandingPage()),
    (route) => false, // Hapus semua route sebelumnya
  );
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
                // const Gap(5),
                // GestureDetector(
                //   onTap: () => logout(context),
                //   child: const Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       Expanded(
                //         child: ButtonPrimaryOutline(
                //           text: "Logout",
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                const Gap(5),
                const Center(
                  child: Text(
                    "Notifikasi ini akan tetap ditampilkan sampai akun Anda diaktifkan kembali.",
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
