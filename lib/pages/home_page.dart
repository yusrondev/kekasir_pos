import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/apis/api_service_transaction.dart';
import 'package:kekasir/components/custom_other_component.dart';
import 'package:kekasir/components/custom_text_component.dart';
import 'package:kekasir/helpers/dialog_expired.dart';
import 'package:kekasir/helpers/lottie_helper.dart';
import 'package:kekasir/models/transaction.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/ui_helper.dart';
import 'package:logger/web.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  final String checkOwner;
  const HomePage({super.key, required this.checkOwner});

  @override
  State<HomePage> createState() => _HomePageState();
}

class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = primaryColor
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
  String totalPurchasesLastMonth = "";
  String grossProfit = "";
  String grossProfitLastMonth = "";
  String hpp = "";
  bool loadingLastUpdateTransaction = true;
  bool isDialogOpen = false;
  
  List<Transaction> transactions = [];

  Timer? _debounceHit;

  final GlobalKey revenueHint = GlobalKey();
  final GlobalKey lastMonthHint = GlobalKey();
  final GlobalKey detailIncomeHint = GlobalKey();
  final GlobalKey stockMutationHint = GlobalKey();
  final GlobalKey transactionMutationHint = GlobalKey();
  final GlobalKey reportHint = GlobalKey();
  final GlobalKey profileHint = GlobalKey();

  int currentStep = 0;
  List<GlobalKey> showcaseKeys = [];

  @override
  void initState() {
    super.initState();
    loadRevenueFromStorage(); // Ambil data dari storage dulu
    _debounceHit = Timer(Duration(milliseconds: 500), () {
      getRevenue(); // Update data dari API setelah 1 detik
      fetchLastUpdateTransaction();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkShowcaseStatus();
    });
  }

  void _checkShowcaseStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasShownShowcase = prefs.getBool('hasShownHomeShowcase') ?? false;

    if (!hasShownShowcase && mounted) {
      final showcase = ShowCaseWidget.of(context);
      showcase.startShowCase([revenueHint, lastMonthHint, detailIncomeHint, stockMutationHint, transactionMutationHint, reportHint, profileHint]);
      prefs.setBool('hasShownHomeShowcase', true);
    }
  }

  Future<void> fetchLastUpdateTransaction() async {
    final data = await ApiServiceTransaction().fetchLastUpdateTransaction();
    try {
      if (mounted) {
        setState(() {
          transactions = data.transactionList;
          loadingLastUpdateTransaction = false;
        });
      }
    } catch (e) {
      showErrorBottomSheet(context, e.toString());
    }

    Logger().d(transactions);
  }

  @override
  void dispose() {
    _debounceHit?.cancel(); // Pastikan Timer dibatalkan saat widget dihancurkan
    super.dispose();
  }

  /// Ambil data revenue dari SharedPreferences
  Future<void> loadRevenueFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        thisMonthRevenue = prefs.getString('this_month_revenue') ?? "";
        lastMonthRevenue = prefs.getString('last_month_revenue') ?? "";
        totalPurchases = prefs.getString('total_purchases') ?? "";
        totalPurchasesLastMonth = prefs.getString('total_purchases_last_month') ?? "";
        grossProfit = prefs.getString('gross_profit') ?? "";
        grossProfitLastMonth = prefs.getString('gross_profit_last_month') ?? "";
        hpp = prefs.getString('hpp') ?? "";
      });
    }
  }

  /// Simpan data revenue ke SharedPreferences
  Future<void> saveRevenueToStorage(String thisMonth, String lastMonth, String totalPurchases, String grossProfit, String hpp, String grossProfitLastMonth, String totalPurchasesLastMonth) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('this_month_revenue', thisMonth);
    await prefs.setString('last_month_revenue', lastMonth);
    await prefs.setString('total_purchases', totalPurchases);
    await prefs.setString('total_purchases_last_month', totalPurchasesLastMonth);
    await prefs.setString('gross_profit', grossProfit);
    await prefs.setString('gross_profit_last_month', grossProfitLastMonth);
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
          totalPurchasesLastMonth = data['data']['total_purchases_last_month'];
          grossProfit = data['data']['gross_profit'];
          grossProfitLastMonth = data['data']['gross_profit_last_month'];
          hpp = data['data']['hpp'];
        });

        Logger().d(data);

        // Simpan data revenue ke storage setelah diambil dari API
        saveRevenueToStorage(thisMonthRevenue, lastMonthRevenue, totalPurchases, grossProfit, hpp, grossProfitLastMonth, totalPurchasesLastMonth);
      }
    } catch (e) {
      if (mounted) {
        // ignore: use_build_context_synchronously
        Logger().d(e.toString());
        if (e.toString().contains('expired')) {
          showNoExpiredDialog(context); // <- context hanya tersedia di layer UI
        } else {
          showErrorBottomSheet(context, e.toString());
        }
      }
    }
  }

  void openWhatsApp() async {
    final Uri url = Uri.parse(
        'https://wa.me/6281232705237?text=Halo%20*Kekasir*%20saya%20ingin%20mengaktifkan%20layanan');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      alertLottie(context, 'Tidak dapat membuka Whatsapp', 'error');
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
          await fetchLastUpdateTransaction();
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
            if(widget.checkOwner == "1") ... [
              buildOtherIncome(),
              Gap(10),
            ],
            buildSectionFeatures(),
            Gap(10),
            buildTransactionHistory(),
            Gap(20),
          ],
        ),
      ),
    );
  }

  Widget buildBackground() {
    return Container(
      height: 140,
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
            Navigator.pushNamed(context, '/profile').then((value) {
              if (value == true) {
                getRevenue();
                fetchLastUpdateTransaction();
              }
            });
          },
          child: Showcase(
            key: profileHint,
            description: "Klik bagian ini untuk melihat informasi akun Anda", 
            overlayOpacity: 0.5,
            floatingActionWidget: FloatingActionWidget(
              left: 0,
              right: 0,
              bottom: 16,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '7 / 7', // Replace with actual current/total count
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Lexend',
                          decoration: TextDecoration.none
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                      ),
                      onPressed: () {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ShowCaseWidget.of(context).dismiss();
                        });
                      },
                      child: const Text(
                        'Selesai',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            child: Image.asset('assets/icons/menu.png', width: 23)
          ),
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
        border: Border.all(color: secondaryColor)
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Pendapatan Bulan Ini", style: TextStyle(fontSize: 14)),
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
                      : Showcase(
                        key: revenueHint,
                        description: "Pendapatan dari produk yang terjual bulan ini",
                        overlayOpacity: 0.5,
                        floatingActionWidget: FloatingActionWidget(
                          left: 0,
                          right: 0,
                          bottom: 16,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xffEE5366),
                                  ),
                                  onPressed: () {
                                    // Tambahkan pengecekan null dan post frame callback
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      ShowCaseWidget.of(context).dismiss();
                                    });
                                  },
                                  child: const Text(
                                    'Lewati',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Lexend',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '1 / 7', // Replace with actual current/total count
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Lexend',
                                      decoration: TextDecoration.none
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                  ),
                                  onPressed: () {
                                    ShowCaseWidget.of(context).next();
                                  },
                                  child: const Text(
                                    'Selanjutnya',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Lexend',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        targetPadding: EdgeInsets.all(2),
                        child: Text(
                          thisMonthRevenue,
                          key: ValueKey(thisMonthRevenue), // Perubahan revenue akan memicu animasi
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
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
          Showcase(
            key: lastMonthHint,
            description: "Total pendapatan bulan kemarin.",
            overlayOpacity: 0.5,
            floatingActionWidget: FloatingActionWidget(
              left: 0,
              right: 0,
              bottom: 16,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffEE5366),
                      ),
                      onPressed: () {
                        // Tambahkan pengecekan null dan post frame callback
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ShowCaseWidget.of(context).dismiss();
                        });
                      },
                      child: const Text(
                        'Lewati',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Lexend',
                          fontSize: 13,
                          fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '2 / 7', // Replace with actual current/total count
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Lexend',
                          decoration: TextDecoration.none
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                      ),
                      onPressed: () {
                        ShowCaseWidget.of(context).next();
                      },
                      child: const Text(
                        'Selanjutnya',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Lexend',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            child: Container(
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
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
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
          borderRadius: BorderRadius.circular(15),
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
                  Showcase(
                    key: stockMutationHint,
                    description: "Klik bagian ini untuk menampilkan mutasi stok produk",
                    overlayOpacity: 0.5,
                    floatingActionWidget: FloatingActionWidget(
                      left: 0,
                      right: 0,
                      bottom: 16,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xffEE5366),
                              ),
                              onPressed: () {
                                // Tambahkan pengecekan null dan post frame callback
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  ShowCaseWidget.of(context).dismiss();
                                });
                              },
                              child: const Text(
                                'Lewati',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Lexend',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '4 / 7', // Replace with actual current/total count
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Lexend',
                                  decoration: TextDecoration.none
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                              ),
                              onPressed: () {
                                ShowCaseWidget.of(context).next();
                              },
                              child: const Text(
                                'Selanjutnya',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Lexend',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    targetPadding: EdgeInsets.all(5),
                    targetBorderRadius: BorderRadius.circular(15),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset('assets/sections/stock.png', width: 50),
                    ),
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
                  Showcase(
                    key: transactionMutationHint,
                    description: "Klik bagian ini untuk menampilkan mutasi transaksi",
                    overlayOpacity: 0.5,
                    floatingActionWidget: FloatingActionWidget(
                      left: 0,
                      right: 0,
                      bottom: 16,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xffEE5366),
                              ),
                              onPressed: () {
                                // Tambahkan pengecekan null dan post frame callback
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  ShowCaseWidget.of(context).dismiss();
                                });
                              },
                              child: const Text(
                                'Lewati',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Lexend',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '5 / 7', // Replace with actual current/total count
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Lexend',
                                  decoration: TextDecoration.none
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                              ),
                              onPressed: () {
                                ShowCaseWidget.of(context).next();
                              },
                              child: const Text(
                                'Selanjutnya',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Lexend',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    targetPadding: EdgeInsets.all(5),
                    targetBorderRadius: BorderRadius.circular(15),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        'assets/sections/transaction.png',
                        width: 50,
                      ),
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
            if(widget.checkOwner == "1") ... [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/report');              
                },
                child: Column(
                  children: [
                    Showcase(
                      key: reportHint,
                      description: "Klik bagian ini untuk menampilkan laporan stok dan penjualan produk",
                      overlayOpacity: 0.5,
                      floatingActionWidget: FloatingActionWidget(
                        left: 0,
                        right: 0,
                        bottom: 16,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xffEE5366),
                                ),
                                onPressed: () {
                                  // Tambahkan pengecekan null dan post frame callback
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    ShowCaseWidget.of(context).dismiss();
                                  });
                                },
                                child: const Text(
                                  'Lewati',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Lexend',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '6 / 7', // Replace with actual current/total count
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Lexend',
                                    decoration: TextDecoration.none
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                ),
                                onPressed: () {
                                  ShowCaseWidget.of(context).next();
                                },
                                child: const Text(
                                  'Selanjutnya',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Lexend',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      targetPadding: EdgeInsets.all(5),
                      targetBorderRadius: BorderRadius.circular(15),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset('assets/sections/report.png', width: 50),
                      ),
                    ),
                    Gap(5),
                    Text(
                      "Laporan",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget buildOtherIncome() {
    return Padding(
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
                    // heightFactor: 0.58,
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
                          LabelSemiBold(text: "📌 Pendapatan bulan kemarin"),
                          Text(
                            lastMonthRevenue,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: primaryColor
                            ),
                          ),
                          LineXM(),
                          LabelSemiBold(text: "📈 Total laba bulan ini"),
                          Text(
                            grossProfit,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: primaryColor
                            ),
                          ),
                          LineXM(),
                          LabelSemiBold(text: "📈 Total laba bulan kemarin"),
                          Text(
                            grossProfitLastMonth,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: primaryColor
                            ),
                          ),
                          LineXM(),
                          LabelSemiBold(text: "💰 Total belanja bulan ini"),
                          Text(
                            totalPurchases,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: primaryColor
                            ),
                          ),
                          LineXM(),
                          LabelSemiBold(text: "💰 Total belanja bulan kemarin"),
                          Text(
                            totalPurchasesLastMonth,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: primaryColor
                            ),
                          ),
                          Gap(20),
                          // LabelSemiBold(text: "💰 Total biaya modal barang yang sudah terjual (HPP)"),
                          // Text(
                          //   hpp,
                          //   style: TextStyle(
                          //     fontSize: 20,
                          //     fontWeight: FontWeight.w600,
                          //     color: primaryColor
                          //   ),
                          // ),
                          // LineXM(),
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
        child: Showcase(
          key: detailIncomeHint,
          description: "Klik di sini untuk menampilkan ringkasan pendapatan Anda",
          overlayOpacity: 0.5,
          floatingActionWidget: FloatingActionWidget(
            left: 0,
            right: 0,
            bottom: 16,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffEE5366),
                    ),
                    onPressed: () {
                      // Tambahkan pengecekan null dan post frame callback
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ShowCaseWidget.of(context).dismiss();
                      });
                    },
                    child: const Text(
                      'Lewati',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Lexend',
                        fontSize: 13,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '3 / 7',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Lexend',
                        decoration: TextDecoration.none
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                    ),
                    onPressed: () {
                      ShowCaseWidget.of(context).next();
                    },
                    child: const Text(
                      'Selanjutnya',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          targetBorderRadius: BorderRadius.circular(15),
          child: Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: secondaryColor)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Ringkasan Pendapatan", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    Icon(Icons.more_horiz, size: 20,),
                  ],
                ),
                Gap(7),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          // color: Color(0xFFF3F5FB),
                          border: Border.all(color: secondaryColor, width: 0.9)
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Total Keuntungan", style: TextStyle(fontSize: 13, color: Colors.black)),
                            Gap(2),
                            Text(grossProfit.toString(), style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: primaryColor
                            )),
                          ],
                        ),
                      ),
                    ),
                    Gap(10),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          // color: Color(0xFFF3F5FB),
                          border: Border.all(color: secondaryColor, width: 0.9)
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Total Belanja", style: TextStyle(fontSize: 13, color: Colors.black)),
                            Gap(2),
                            Text(totalPurchases.toString(), style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: primaryColor
                            )),
                          ],
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        )
      ),
    );
  }

  Widget buildTransactionHistory() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: secondaryColor)
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Transaksi Hari Ini", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ShortDesc(text: "Menampilkan 3 transaksi terakhir",),
                  ],
                ),
                if(transactions.length >= 3) ... [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/transaction/mutation');
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Lihat Semua", style: TextStyle(
                          color: primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600
                        )),
                        Gap(3),
                        Icon(Icons.arrow_forward_rounded, size: 10, color: primaryColor)
                      ],
                    ),
                  )
                ]
              ],
            ),
            Gap(10),
            loadingLastUpdateTransaction == true ? CustomLoader.showCustomLoader() : 
            transactions.isNotEmpty ?
              ListView.builder(
                padding: EdgeInsets.all(0),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                itemBuilder: (context, index){
                  
                  final transaction = transactions[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/transaction/detail',
                        arguments: transaction.id
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 10),
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: secondaryColor),
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LabelSemiBold(text: transaction.code),
                              Gap(3),
                              Label(text: transaction.createdAt,)
                            ],
                          ),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  PriceTag(text: '+ ${transaction.grandTotal}'),
                                  Row(
                                    children: [
                                      StockTag(text: transaction.paymentMethod),
                                      if(transaction.labelPrice != null) ... [
                                        Gap(5),
                                        WarningTag(text: transaction.labelPrice),
                                      ]
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                }
              )
            : 
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Belum ada transaksi untuk hari ini ...", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xff898F9F),)),
              )
          ],
        ),
      )
    );
  }
}
