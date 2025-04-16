import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/components/custom_button_component.dart';
import 'package:kekasir/utils/colors.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {

  double _scale = 1.0;

  void _onTapDown(_) {
    setState(() {
      _scale = 0.95; // Zoom in sedikit
    });
  }

  void _onTapUp(_) {
    setState(() {
      _scale = 1.0; // Balik ke normal (zoom out)
    });
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
        body: Stack(
          children: [
            // Layer gradasi
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xff344BBC),
                    Color(0xff344BBC),
                    Color(0xff273A99),
                    Color(0xff273A99),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomLeft,
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Image.asset('assets/images/wave.png', fit: BoxFit.cover),
            ),
            // Konten utama
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Column(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Image.asset(
                              'assets/images/kekasir.png',
                              width: 95,
                            ),
                          ),
                          Gap(25),
                          Text(
                            "Selamat Datang di Sistem Kasir Modern",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          Gap(5),
                          Text(
                            "Kelola toko lebih efisien langsung dari genggaman Anda. Catat transaksi, produk, pantau stok hanya dengan satu aplikasi, solusi cepat dan mudah untuk manajemen kasir",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          )
                        ],
                      ),
                    ),
                    // Bottom content
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => Navigator.pushNamed(context, '/register'),
                                onTapDown: _onTapDown,
                                onTapUp: _onTapUp,
                                onTapCancel: () => setState(() => _scale = 1.0),
                                child: AnimatedScale(
                                  scale: _scale,
                                  duration: Duration(milliseconds: 120),
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: primaryColor
                                    ),
                                    child: Center(
                                      child: RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          text: 'Daftar Sekarang',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontFamily: 'Lexend',
                                          ),
                                          children: const <TextSpan>[
                                            TextSpan(
                                              text: ' (Gratis)',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Gap(25),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/login'),
                          child: RichText(
                            text: TextSpan(
                              text: 'Sudah punya akun? ',
                              style: TextStyle(
                                fontSize: 12,
                                color: darkColor,
                                fontFamily: 'Lexend'
                              ),
                              children: const <TextSpan>[
                                TextSpan(
                                  text: 'Masuk',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: kekasirColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Gap(20), // biar gak terlalu nempel bawah
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

  }
}