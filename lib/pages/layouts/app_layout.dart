import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:kekasir/components/custom_button_component.dart';
import 'package:kekasir/pages/home_page.dart';
import 'package:kekasir/pages/product/index_product_page.dart';
import 'package:kekasir/pages/discount/index_discount_page.dart';
import 'package:kekasir/pages/transaction/index_transaction_page.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:logger/logger.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLayout extends StatefulWidget {
  const AppLayout({super.key});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> with TickerProviderStateMixin {
  late InternetConnectionChecker _connectionChecker;
  bool isDialogOpen = false;
  int _selectedIndex = 0;
  String checkOwner = '';
   @override
  void initState() {
    super.initState();
    _connectionChecker = InternetConnectionChecker.createInstance();
    _checkInternetConnection(); // Cek internet saat aplikasi dimulai

    _getLocalVar();  
  }

  List<Map<String, dynamic>> menu = [];

  Future<void> _getLocalVar() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      checkOwner = prefs.getString("is_owner") ?? "0";
      Logger().d(checkOwner);
      menu = [
        {
          "icon": "assets/icons/ic_home_inactive.png",
          "icon_active": "assets/icons/ic_home_active.png",
          "page_name": "Beranda",
          "fragment": HomePage(checkOwner : checkOwner)
        },
        {
          "icon": "assets/icons/ic_transaction_inactive.png",
          "icon_active": "assets/icons/ic_transaction_active.png",
          "page_name": "Transaksi",
          "fragment": IndexTransactionPage()
        },
        if (checkOwner == "1") ... [
          {
            "icon": "assets/icons/ic_product_inactive.png",
            "icon_active": "assets/icons/ic_product_active.png",
            "page_name": "Produk",
            "fragment": IndexProductPage()
          },
          {
            "icon": "assets/icons/ic_discount_inactive.png",
            "icon_active": "assets/icons/ic_discount_active.png",
            "page_name": "Diskon",
            "fragment": IndexDiscountPage()
          },
        ] // hanya tampilkan Produk kalau owner
      ];

      _selectedIndex = 0;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _checkInternetConnection() {
    _connectionChecker.onStatusChange.listen((status) {
      if (status == InternetConnectionStatus.disconnected) {
        _showNoInternetDialog();
      } else {
        if (isDialogOpen) {
          Navigator.of(context).pop();
          isDialogOpen = false;
        }
      }
    });
  }

  void _showNoInternetDialog() {
    if (!isDialogOpen) {
      isDialogOpen = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        // ignore: deprecated_member_use
        barrierColor: Colors.black.withOpacity(0.7), // Atur tingkat 
        // ignore: deprecated_member_use
        builder: (context) => WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            clipBehavior: Clip.hardEdge,
            backgroundColor: Colors.white,
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8, // 80% dari layar
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Lottie.asset(
                      'assets/animations/disconnect.json',
                      width: 50,
                      frameRate: const FrameRate(90),
                    ),
                  ),
                  Gap(5),
                  Center(
                    child: Text(
                      "Tidak Ada Koneksi Internet!",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Gap(5),
                  Center(child: Text("Pastikan Perangkat terhubung ke jaringan", textAlign: TextAlign.center, style: TextStyle(fontSize: 12))),
                  Gap(10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Sedang menunggu jaringan", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primaryColor)),
                      Gap(5),
                      Lottie.asset(
                        'assets/animations/loading.json',
                        width: 20,
                        frameRate: const FrameRate(90),
                      ),
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

  Future<bool> _onWillPop() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        clipBehavior: Clip.hardEdge,
        backgroundColor: Colors.white,
        title: Text('Konfirmasi Keluar', style: TextStyle(fontFamily: 'Lexend'),),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
            Gap(20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: ButtonPrimaryOutline(
                      text: "Batal",
                    ),
                  )
                ),
                Gap(5),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(true);
                    },
                    child: ButtonPrimary(
                      text: "Yakin",
                    ),
                  )
                ),
              ],
            ),
          ],
        )
      ),
    ) ??
    false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        extendBodyBehindAppBar:true,
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
        body: menu.isEmpty
        ? Center(child: CircularProgressIndicator())
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: menu[_selectedIndex]['fragment'],
          ),
        bottomNavigationBar: menu.isEmpty
        ? SizedBox.shrink()
        :  Container(
          padding: EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: checkOwner == "1" ? MainAxisAlignment.spaceAround : MainAxisAlignment.spaceEvenly,
            children: menu.asMap().entries.map((entry) {
              int index = entry.key;
              var item = entry.value;

              return GestureDetector(
                onTap: () => _onItemTapped(index),
                child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1000),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        _selectedIndex == index ? item['icon_active'] : item['icon'],
                        width: checkOwner == "1" ? 24 : 25,
                        height: checkOwner == "1" ? 24 : 25,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['page_name'],
                        style: TextStyle(
                          color: _selectedIndex == index ? primaryColor : Color(0xff9CA9EE),
                          fontSize: 12,
                          fontWeight: _selectedIndex == index ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          )
        ),
      ),
    );
  }
}