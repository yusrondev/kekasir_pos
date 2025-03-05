import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/components/custom_button_component.dart';
import 'package:kekasir/pages/home_page.dart';
import 'package:kekasir/pages/product/index_product_page.dart';
import 'package:kekasir/pages/promo/index_promo_page.dart';
import 'package:kekasir/pages/transaction/index_transaction_page.dart';
import 'package:kekasir/utils/colors.dart';

class AppLayout extends StatefulWidget {
  const AppLayout({super.key});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> menu = [
    {
      "icon": "assets/icons/ic_home_inactive.png",
      "icon_active": "assets/icons/ic_home_active.png",
      "page_name": "Beranda",
      "fragment": const HomePage()
    },
    {
      "icon": "assets/icons/ic_transaction_inactive.png",
      "icon_active": "assets/icons/ic_transaction_active.png",
      "page_name": "Transaksi",
      "fragment": IndexTransactionPage()
    },
    {
      "icon": "assets/icons/ic_product_inactive.png",
      "icon_active": "assets/icons/ic_product_active.png",
      "page_name": "Produk",
      "fragment": IndexProductPage()
    },
    {
      "icon": "assets/icons/ic_discount_inactive.png",
      "icon_active": "assets/icons/ic_discount_active.png",
      "page_name": "Promo",
      "fragment": IndexPromoPage()
    },
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Konfirmasi Keluar'),
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
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: menu[_selectedIndex]['fragment'],
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: menu.map((item) {
              int index = menu.indexOf(item);
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
                        width: 24,
                        height: 24,
                      ),
                      const Gap(2),
                      Text(
                        item['page_name'],
                        style: TextStyle(
                          color: _selectedIndex == index ? primaryColor : secondaryColor,
                          fontSize: 12,
                          fontWeight: _selectedIndex == index ? FontWeight.w600 : FontWeight.normal
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}