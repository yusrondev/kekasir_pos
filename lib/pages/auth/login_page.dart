import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/apis/auth_service.dart';
import 'package:kekasir/components/custom_button_component.dart';
import 'package:kekasir/helpers/lottie_helper.dart';
import 'package:kekasir/pages/layouts/app_layout.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/ui_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}


void showErrorSnackbarCustom(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Color(0xfffdcb6e),
      showCloseIcon: true,
      closeIconColor: Colors.black,
      behavior: SnackBarBehavior.floating, // Membuat snackbar mengambang
      elevation: 0,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.73, // Untuk menampilkan di atas
        left: 16,
        right: 16,
      ),
      duration: Duration(seconds: 2), // Durasi muncul
      content: Text(
        message,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: Colors.black,
        ),
      ),
      animation: CurvedAnimation(
        parent: ModalRoute.of(context)!.animation!,
        curve: Curves.easeOut, // Animasi lebih halus
      ),
    ),
  );
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();
  bool isLoading = false;
  bool _obscureText = true;

  void login() async {
    if (emailController.text == "") {
      showErrorSnackbarCustom(context, 'Pastikan email sudah terisi!');
      return;
    }

    if (passwordController.text == "") {
      showErrorSnackbarCustom(context, 'Pastikan password sudah terisi!');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String? error = await authService.login(
        emailController.text,
        passwordController.text,
      );

      if (error == null) {
        if (mounted) { // Pastikan widget masih terpasang
          setState(() {
            isLoading = false;
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AppLayout()),
          );
        }
      } else {
        if (mounted) { // Pastikan widget masih terpasang
          setState(() {
            isLoading = false;
          });
          showErrorSnackbarCustom(context, error);
        }
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showErrorBottomSheet(context, e.toString());
    }
  }

  void openWhatsApp() async {
    final Uri url = Uri.parse(
        'https://wa.me/6281232705237?text=Halo%20*Kekasir*%20saya%20butuh%20bantuan!');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // ignore: use_build_context_synchronously
      showErrorSnackbarCustom(context, 'Tidak dapat membuka Whatsapp');
    }
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
    // ignore: deprecated_member_use
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
        backgroundColor: Colors.white,
        body: isLoading ? Center(
            child:CustomLoader.showCustomLoader(),
          ) : Column(
          children: [
            Gap(70),
            Image.asset(
              'assets/images/logo-blue.png',
              width: 30,
            ),
            Gap(20),
            Column(
              children: [
                Text("Selamat Datang!", style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20
                  )
                ),
                Gap(2),
                Text("Senang bertemu kembali 👋", style: TextStyle(
                    fontSize: 13,
                    color: Color(0xff57606f)
                  )
                ),
                Text("Masuk ke akun Anda di bawah ini", style: TextStyle(
                    fontSize: 13,
                    color: Color(0xff57606f)
                  )
                )
              ],
            ),
            Gap(10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Email", style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14
                  )),
                  Gap(7),
                  Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    border: Border.all(color: secondaryColor)
                  ),
                  child: TextField(
                    cursorColor: primaryColor,
                    controller: emailController,
                    decoration: InputDecoration(
                      counterText: "",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      hintText: "Misalnya kekasir@gmail.com...",
                      hintStyle: TextStyle(
                        color: Color(0xffB1B9C3), 
                        fontSize: 14
                        )
                      ),
                    )
                  ),
      
                  Gap(10),
      
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Password", style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14
                      )),
                      Gap(7),
                      Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        border: Border.all(color: secondaryColor)
                      ),
                      child: TextField(
                        controller: passwordController,
                        cursorColor: primaryColor,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          counterText: "",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                          hintText: "******",
                          suffixIcon: IconButton(
                            icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, size: 20, color: Color(0xff747d8c)),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                          hintStyle: TextStyle(
                            color: Color(0xffB1B9C3), 
                            fontSize: 14
                            )
                          ),
                        )
                      ),
                      Gap(10),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: isLoading != true ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () { 
                  login(); 
                },
                child: SizedBox(
                  width: double.infinity,
                  child: ButtonPrimary(
                    text: "Masuk",
                  ),
                )
              ),
              Gap(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Butuh bantuan?", style: TextStyle(
                    fontSize: 13,
                    color: Color(0xff57606f)
                  )),
                  Gap(5),
                  GestureDetector(
                    onTap: () => openWhatsApp(),
                    child: Text("Hubungi Kekasir", style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: primaryColor
                    )),
                  ),
                ],
              ),
              Gap(20),
            ],
          ),
        ) : SizedBox.shrink(),
      ),
    );
  }
}
