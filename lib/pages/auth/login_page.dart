import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/apis/auth_service.dart';
import 'package:kekasir/components/custom_button_component.dart';
import 'package:kekasir/helpers/lottie_helper.dart';
import 'package:kekasir/pages/layouts/app_layout.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();
  bool isLoading = false;
  bool _obscureText = true;

  void login() async {
    if (emailController.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pastikan email sudah terisi!')));
      return;
    }

    if (passwordController.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pastikan password sudah terisi!')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    bool success = await authService.login(
      emailController.text,
      passwordController.text,
    );

    if (success) {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal Masuk!')),
        );
      }
    }
  }

  void openWhatsApp() async {
    final Uri url = Uri.parse(
        'https://wa.me/6281232705237?text=Halo%20*Kekasir*%20saya%20butuh%20bantuan!');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Tidak bisa membuka WhatsApp';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              Text("Hallo!", style: TextStyle(
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
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 13),
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
              child: ButtonPrimary(
                text: "Masuk",
              ),
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
    );
  }
}
