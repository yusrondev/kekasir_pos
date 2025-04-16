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
          expiredDateStr = data['store']['expired_date'];
          periodInMonths = data['package']['period'];
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
                    onTap: () {},
                    child: ButtonPrimary(
                      text: "Hubungi Kekasir",
                    ),
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
                    "Nikmati kemudahan berlangganan paket Kekasir langsung via WhatsApp resmi kami.", 
                    textAlign: TextAlign.center,
                    style: TextStyle(
                    fontSize: 12,
                    color: Color(0xff57606f)
                  )),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget buildProgressLayout() {
    if (isLoading || expiredDateStr.isEmpty || dataMe == null) {
      return Center(child: CustomLoader.showCustomLoader());
    }
    DateTime expiredDate = DateTime.parse(expiredDateStr);
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day); // Hanya tanggal

    final DateTime startDate = DateTime(
      expiredDate.year,
      expiredDate.month - periodInMonths,
      expiredDate.day,
    );

    String lastUpdate = DateFormat("d MMMM yyyy HH:mm", 'id_ID').format(
      DateTime.parse(dataMe!['store']['updated_at'])
    );

    String formattedPrice = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(double.parse(dataMe!['package']['price']));

    final int totalDays = expiredDate.difference(startDate).inDays;
    final int remainingDays = expiredDate.difference(today).inDays;
    final double progress = (totalDays - remainingDays) / totalDays;

    return ListView(
      padding: defaultPadding,
      children: [
        PageTitle(text: "Informasi Paket", back: true,),
        Gap(18),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: dataMe!['package']['image'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.fitWidth,
                    placeholder: (context, url) => Image.asset(
                      'assets/images/empty.png',
                      width: 60,
                      height: 60,
                      fit: BoxFit.fitWidth,
                    ),
                    errorWidget: (context, url, error) => Image.asset(
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
                        dataMe!['package']['name'],
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Gap(5),
                      Text(
                        dataMe!['package']['description'],
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Gap(15),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
              backgroundColor: Colors.grey[300],
              color: remainingDays <= 3 ? Color(0xffe74c3c) : remainingDays <= 8 ? Color(0xfff39c12) : primaryColor,
            ),
            Gap(5),
            Text(
              "Langganan berakhir dalam $remainingDays hari",
              style: TextStyle(
                fontSize: 13, 
                fontWeight: FontWeight.w600,
                color: remainingDays <= 3 ? Color(0xffe74c3c) : remainingDays <= 8 ? Color(0xfff39c12) : primaryColor,
              ),
            ),
          ],
        ),
        Gap(15),
        Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xffE7E7E7)),
            color: Colors.white,
            borderRadius: BorderRadius.circular(10)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Terakhir Diperbarui"),
                  Text(lastUpdate, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))
                ],
              ),
              LineXM(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Durasi Paket"),
                  Text("${dataMe!['package']['period'].toString()} Bulan", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))
                ],
              ),
              LineXM(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Biaya Bulanan"),
                  Text(formattedPrice, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))
                ],
              ),
              LineXM(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Maksimal Pegawai"),
                  Text(dataMe!['package']['quota_employee'].toString(), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))
                ],
              ),
              LineXM(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Maksimal Produk"),
                  Text("Tidak Terbatas", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))
                ],
              ),
              LineXM(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Maksimal Transaksi"),
                  Text("Tidak Terbatas", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
