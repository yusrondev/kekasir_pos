import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:kekasir/apis/auth_service.dart';
import 'package:kekasir/components/custom_button_component.dart';
import 'package:kekasir/components/custom_other_component.dart';
import 'package:kekasir/components/custom_text_component.dart';
import 'package:kekasir/helpers/lottie_helper.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/ui_helper.dart';
import 'package:kekasir/utils/variable.dart';
import 'package:logger/web.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPackagePage extends StatefulWidget {
  const DetailPackagePage({super.key});

  @override
  State<DetailPackagePage> createState() => _DetailPackagePageState();
}

class _DetailPackagePageState extends State<DetailPackagePage> {
  AuthService authService = AuthService();

  String expiredDateStr = "";
  int periodInMonths = 3;

  Map<String, dynamic>? dataMe;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    me();
  }

  Future<void> me() async {
    try {
      final data = await authService.fetchUser();

      if (data == null) {
        Navigator.pop(context);
        throw Exception("Gagal mengambil data pengguna.");
      }

      if (data.isEmpty) {
        Navigator.pop(context);
        throw Exception("Gagal mengambil data pengguna.");
      }

      if (mounted) {
        setState(() {
          dataMe = data;
          isLoading = false;
          expiredDateStr = data['store']['expired_date'] ?? "";
          periodInMonths = data['package']['period'] ?? "";
        });

        Logger().d(expiredDateStr);
        Logger().d(periodInMonths);
      }
    } catch (e) {
      if (mounted) {
        Logger().d(e.toString());
        showErrorBottomSheet(context, e.toString());
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void openWhatsApp() async {
    final Uri url = Uri.parse(
      'https://wa.me/6281232705237?text=Halo%20*Kekasir*%20saya%20butuh%20bantuan%20mengenai%20paket!',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // ignore: use_build_context_synchronously
      alertLottie(context, 'Tidak dapat membuka Whatsapp');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0), // Ukuran AppBar jadi 0
        child: AppBar(
          backgroundColor: primaryColor, // Warna status bar
          elevation: 0, // Hilangkan bayangan
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: primaryColor, // Warna status bar
            statusBarIconBrightness: Brightness.light, // Ikon status bar terang
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: buildProgressLayout(),
      bottomNavigationBar: buildFooter(),
    );
  }

  Widget buildFooter() {
    if (isLoading == false && dataMe != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => openWhatsApp(),
                    child: ButtonPrimary(text: "Hubungi Kekasir"),
                  ),
                ),
              ],
            ),
            Gap(10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    "Berlangganan paket Kekasir langsung via WhatsApp resmi kami.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Color(0xff57606f)),
                  ),
                ),
              ],
            ),
            Gap(10),
          ],
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget buildProgressLayout() {
    if (isLoading || dataMe == null) {
      return Center(child: CustomLoader.showCustomLoader());
    }

    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    bool isUnlimited = dataMe!['store']['expired_date'] == null;
    int rawPeriod = dataMe!['package']['period'];
    String packageDuration = "";

    double progress = 1.0;
    int remainingDays = 0;

    if (!isUnlimited) {
      DateTime expiredDate = DateTime.parse(dataMe!['store']['expired_date']);
      DateTime startDate;

      if (rawPeriod == 0) {
        periodInMonths = 0;
        startDate = expiredDate.subtract(Duration(days: 7));
        packageDuration = "7 Hari";
      } else {
        periodInMonths = rawPeriod;
        startDate = DateTime(
          expiredDate.year,
          expiredDate.month - periodInMonths,
          expiredDate.day,
        );
        packageDuration = "$periodInMonths Bulan";
      }

      final int totalDays = expiredDate.difference(startDate).inDays;
      remainingDays = expiredDate.difference(today).inDays;
      progress = (totalDays - remainingDays) / totalDays;
    } else {
      packageDuration = "Unlimited";
      progress = 1.0;
    }

    String lastUpdate = DateFormat(
      "d MMMM yyyy",
      'id_ID',
    ).format(DateTime.parse(dataMe!['store']['updated_at']));

    String formattedPrice = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(double.parse(dataMe!['package']['price']));

    Color parseHexColor(String? hexColor) {
      if (hexColor == null || hexColor.isEmpty) {
        return Colors.black;
      }

      hexColor = hexColor.replaceAll("#", "");
      if (hexColor.length == 6) {
        hexColor = "FF$hexColor"; // tambahkan opacity (FF) kalau 6 digit
      }

      try {
        return Color(int.parse("0x$hexColor"));
      } catch (e) {
        return Colors.black;
      }
    }

    return ListView(
      padding: defaultPadding,
      children: [
        PageTitle(text: "Informasi Paket", back: true),
        Gap(18),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: !isUnlimited ? dataMe!['package']['image'] : "https://img.freepik.com/premium-photo/queen-gold-crown_863013-113893.jpg?w=360",
                    width: 60,
                    height: 60,
                    fit: BoxFit.fitWidth,
                    placeholder:
                        (context, url) => Image.asset(
                          'assets/images/empty.png',
                          width: 60,
                          height: 60,
                          fit: BoxFit.fitWidth,
                        ),
                    errorWidget:
                        (context, url, error) => Image.asset(
                          'assets/images/empty.png',
                          width: 60,
                          height: 60,
                          fit: BoxFit.fitWidth,
                        ),
                  ),
                ),
                Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        !isUnlimited ? dataMe!['package']['name'] : "Unlimited",
                        style: TextStyle(
                          fontSize: 16,
                          color: parseHexColor(dataMe!['package']['color']),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Gap(2),
                      Text(
                        !isUnlimited ? dataMe!['package']['description'] : "Nikmati semua fitur sepuasnya, sebanyak yang kamu mau!",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        if (!isUnlimited) ...[
          Gap(15),
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 10,
                borderRadius: BorderRadius.circular(5),
                backgroundColor: Colors.grey[300],
                color: remainingDays <= 3 ? Color(0xffe74c3c) : primaryColor,
              ),
              if (progress == 0.0)
                Positioned(
                  left: 2,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: primaryColor, // warna titik
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          Gap(5),
          Text(
            dataMe!['package']['name'] == "Trial"
                ? "Masa aktif akun tersisa $remainingDays hari"
                : remainingDays == 0 ? "Masa aktif sudah habis" : "Langganan berakhir dalam $remainingDays hari",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color:
                  remainingDays <= 3
                      ? Color(0xffe74c3c)
                      : primaryColor,
            ),
          ),
          Gap(15),
        ] else ...[
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "Paket Anda Unlimited 🎉",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ),
        ],
        Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xffE7E7E7)),
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Terakhir Diperbarui"),
                  Text(
                    lastUpdate,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              LineXM(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Durasi Paket"),
                  Text(
                    packageDuration,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              LineXM(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Biaya Bulanan"),
                  Text(
                    !isUnlimited ? formattedPrice : "Rp 0",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              LineXM(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Maksimal Pegawai"),
                  Text(
                    !isUnlimited ? dataMe!['package']['quota_employee'].toString() : "Tidak Terbatas",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              LineXM(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Maksimal Produk"),
                  Text(
                    "Tidak Terbatas",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              LineXM(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Maksimal Transaksi"),
                  Text(
                    "Tidak Terbatas",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
