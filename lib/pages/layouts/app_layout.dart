import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/pages/home_page.dart';
import 'package:kekasir/pages/product/index_product_page.dart';
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
      "fragment": Center(
        child: Text("Ini Halaman Transaksi"),
      )
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
      "fragment": Center(
        child: Text("Ini Halaman Promo"),
      )
    },
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: menu[_selectedIndex]['fragment'],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: menu.map((item) {
            int index = menu.indexOf(item);
            return GestureDetector(
              onTap: () => _onItemTapped(index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    _selectedIndex == index ? item['icon_active'] : item['icon'],
                    width: 24,
                    height: 24,
                  ),
                  const Gap(5),
                  Text(
                    item['page_name'],
                    style: TextStyle(
                      color: _selectedIndex == index ? primaryColor : secondaryColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}