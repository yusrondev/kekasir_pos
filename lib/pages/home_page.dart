import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/apis/api_service_transaction.dart';
import 'package:kekasir/components/custom_other_component.dart';
import 'package:kekasir/components/custom_text_component.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/ui_helper.dart';
import 'package:logger/web.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = secondaryColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    double dashWidth = 3, dashSpace = 3;
    Path path = Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(10)));

    Path dashPath = Path();
    PathMetrics pathMetrics = path.computeMetrics();
    for (PathMetric pathMetric in pathMetrics) {
      double distance = 0;
      while (distance < pathMetric.length) {
        Path extractPath = pathMetric.extractPath(distance, distance + dashWidth);
        dashPath.addPath(extractPath, Offset.zero);
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _HomePageState extends State<HomePage> {
  ApiServiceTransaction apiServiceTransaction = ApiServiceTransaction();

  String thisMonthRevenue = "";
  String lastMonthRevenue = "";
  String totalPurchases = "";
  String grossProfit = "";
  String netProfit = "";
  String hpp = "";

  Timer? _debounceHit;

  TutorialCoachMark? tutorialCoachMark;
  final GlobalKey _buttonKey = GlobalKey();
  final GlobalKey _otherIncomeHint = GlobalKey();
  final GlobalKey _revenueKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    loadRevenueFromStorage(); // Ambil data dari storage dulu
    _debounceHit = Timer(Duration(milliseconds: 500), () {
      getRevenue(); // Update data dari API setelah 1 detik
    });

    // Cek apakah user sudah melihat tutorial sebelumnya
    checkTutorialStatus();
  }

  Future<void> checkTutorialStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool hasSeenTutorial = prefs.getBool('has_seen_tutorial_home') ?? false;

    if (!hasSeenTutorial) {
      Future.delayed(Duration(milliseconds: 500), () {
        showTutorial();
      });
    }
  }

  @override
  void dispose() {
    _debounceHit?.cancel(); // Pastikan Timer dibatalkan saat widget dihancurkan
    super.dispose();
  }

   void showTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: [
        TargetFocus(
          identify: "Revenue",
          keyTarget: _revenueKey,
          shape: ShapeLightFocus.RRect,
          contents: [
            TargetContent(
              align: ContentAlign.right,
              child: Text(
                "Ini adalah total pendapatan Anda dalam bulan ini",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
        TargetFocus(
          identify: "Button",
          keyTarget: _buttonKey,
          shape: ShapeLightFocus.Circle,
          contents: [
            TargetContent(
              align: ContentAlign.left,
              child: Text(
                "Tekan tombol ini untuk mendapatkan informasi akun",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
        TargetFocus(
          identify: "OtherIncome",
          keyTarget: _otherIncomeHint,
          alignSkip: Alignment.topRight,
          shape: ShapeLightFocus.RRect,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              child: Text(
                "Klik bagian ini untuk melihat detail dari semua ringkasan pendapatan Anda",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ],
      onFinish: () async {
        // Tandai bahwa user sudah melihat tutorial
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('has_seen_tutorial_home', true);
      },
      onSkip: () {
        // Inisialisasi SharedPreferences
        SharedPreferences.getInstance().then((prefs) {
          prefs.setBool('has_seen_tutorial_home', true);
        });

        return true; // Harus mengembalikan bool agar sesuai dengan tipe data yang diharapkan
      },

    )..show(context: context);
  }

  /// Ambil data revenue dari SharedPreferences
  Future<void> loadRevenueFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      thisMonthRevenue = prefs.getString('this_month_revenue') ?? "";
      lastMonthRevenue = prefs.getString('last_month_revenue') ?? "";
      totalPurchases = prefs.getString('total_purchases') ?? "";
      grossProfit = prefs.getString('gross_profit') ?? "";
      netProfit = prefs.getString('net_profit') ?? "";
      hpp = prefs.getString('hpp') ?? "";
    });
  }

  /// Simpan data revenue ke SharedPreferences
  Future<void> saveRevenueToStorage(String thisMonth, String lastMonth, String totalPurchases, String grossProfit, String netProfit, String hpp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('this_month_revenue', thisMonth);
    await prefs.setString('last_month_revenue', lastMonth);
    await prefs.setString('total_purchases', totalPurchases);
    await prefs.setString('gross_profit', grossProfit);
    await prefs.setString('net_profit', netProfit);
    await prefs.setString('hpp', hpp);
  }

  /// Ambil data revenue dari API
  Future<void> getRevenue() async {
    try {
      final data = await ApiServiceTransaction().getRevenue();
      if (mounted) {
        setState(() {
          thisMonthRevenue = data!['data']['this_month'];
          lastMonthRevenue = data['data']['last_month'];
          totalPurchases = data['data']['total_purchases'];
          grossProfit = data['data']['gross_profit'];
          netProfit = data['data']['net_profit'];
          hpp = data['data']['hpp'];
        });

        Logger().d(data);

        // Simpan data revenue ke storage setelah diambil dari API
        saveRevenueToStorage(thisMonthRevenue, lastMonthRevenue, totalPurchases, grossProfit, netProfit, hpp);
      }
    } catch (e) {
      Logger().d(e.toString());
      // ignore: use_build_context_synchronously
      showErrorBottomSheet(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: primaryColor,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await getRevenue(); // Update data saat refresh
        },
        color: primaryColor,
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.all(0),
          children: [
            Stack(
              children: [
                buildBackground(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    children: [Gap(44), buildLogo(), Gap(15), buildBalance()],
                  ),
                ),
              ],
            ),
            Gap(10),
            buildOtherIncome(),
            Gap(10),
            buildSectionFeatures(),
          ],
        ),
      ),
    );
  }

  Widget buildBackground() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xff344BBC),
            Color(0xff344BBC),
            Color(0xff273A99),
            Color(0xff273A99),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
    );
  }

  Widget buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset('assets/images/kekasir.png', width: 70),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/profile');
          },
          child: Image.asset('assets/icons/menu.png', width: 23, key: _buttonKey,),
        ),
      ],
    );
  }

  Widget buildBalance() {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                key: _revenueKey,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Pendapatan bulan ini", style: TextStyle(fontSize: 13)),
                  thisMonthRevenue.isEmpty
                      ? Container(
                        margin: EdgeInsets.only(top: 10),
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: primaryColor,
                        ),
                      )
                      : Text(
                        thisMonthRevenue,
                        key: ValueKey(thisMonthRevenue), // Perubahan revenue akan memicu animasi
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                ],
              ),
              GestureDetector(
                onTap:
                    () => Navigator.pushNamed(context, '/transaction/mutation'),
                child: Image.asset('assets/images/money.png', height: 28),
              ),
            ],
          ),
          Gap(10),
          Container(
            padding: EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Color(0xFFF3F5FB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bulan Kemarin',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                lastMonthRevenue.isEmpty
                    ? SizedBox(
                      width: 10,
                      height: 10,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primaryColor,
                      ),
                    )
                    : Text(
                      lastMonthRevenue,
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionFeatures() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        padding: EdgeInsets.only(top: 12, bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: secondaryColor)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/stock');
              },
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset('assets/sections/stock.png', width: 50),
                  ),
                  Gap(5),
                  Text(
                    "Mutasi Stok",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/transaction/mutation');
              },
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      'assets/sections/transaction.png',
                      width: 50,
                    ),
                  ),
                  Gap(5),
                  Text(
                    "Mutasi Transaksi",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/report');              
              },
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset('assets/sections/report.png', width: 50),
                  ),
                  Gap(5),
                  Text(
                    "Laporan",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOtherIncome() {
    return Padding(
      key: _otherIncomeHint,
      padding: EdgeInsets.symmetric(horizontal: 14),
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setModalState) {
                  return FractionallySizedBox(
                    heightFactor: 0.8,
                    child: Container(
                      padding: EdgeInsets.all(14),
                      width: double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              height: 5,
                              width: 50,
                              decoration: BoxDecoration(
                                color: Color(0xffced6e0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          Gap(15),
                          LabelSemiBold(text: "📌 Pendapatan bulan ini"),
                          Text(
                            thisMonthRevenue,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: primaryColor
                            ),
                          ),
                          LineXM(),
                          LabelSemiBold(text: "📌 Pendapatan bulan lalu"),
                          Text(
                            lastMonthRevenue,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: primaryColor
                            ),
                          ),
                          LineXM(),
                          LabelSemiBold(text: "📈 Total laba (Keuntungan)"),
                          Text(
                            grossProfit,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: primaryColor
                            ),
                          ),
                          LineXM(),
                          LabelSemiBold(text: "💰 Total biaya modal barang yang sudah terjual (HPP)"),
                          Text(
                            hpp,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: primaryColor
                            ),
                          ),
                          LineXM(),
                          LabelSemiBold(text: "💰 Total biaya pembelian barang (semua stok masuk)"),
                          Text(
                            totalPurchases,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: primaryColor
                            ),
                          ),
                          Gap(20),
                          // Container(
                          //   padding: EdgeInsets.all(10),
                          //   decoration: BoxDecoration(
                          //     border: Border.all(color: Color(0xfff6e58d)),
                          //     color: Color(0xfff6e58d).withValues(alpha: 0.5),
                          //     borderRadius: BorderRadius.circular(10)
                          //   ),
                          //   child: Text("", style: TextStyle(
                          //     fontWeight: FontWeight.w600
                          //   )),
                          // )
                        ],
                      ),
                    ),
                  );
                }
              );
            },
          );
        },
        child: CustomPaint(
          size: Size(double.infinity, 80), // Sesuaikan dengan ukuran yang diinginkan
          painter: DashedBorderPainter(),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total Keuntungan", style: TextStyle(fontSize: 13)),
                    Text(grossProfit.toString(), style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: primaryColor
                    ))
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Total Belanja", style: TextStyle(fontSize: 13)),
                    Text(totalPurchases.toString(), style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: primaryColor
                    ))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
