import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:kekasir/apis/auth_service.dart';
import 'package:kekasir/components/custom_button_component.dart';
import 'package:kekasir/helpers/lottie_helper.dart';
import 'package:kekasir/pages/layouts/app_layout.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/ui_helper.dart';
import 'package:lottie/lottie.dart';
import 'package:showcaseview/showcaseview.dart';
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
  late InternetConnectionChecker _connectionChecker;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();
  bool isLoading = false;
  bool _obscureText = true;
  bool isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _connectionChecker = InternetConnectionChecker.createInstance();
    _checkInternetConnection(); // Cek internet saat aplikasi dimulai
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

  void login() async {
    if (emailController.text == "") {
      alertLottie(context, 'Pastikan email sudah terisi!', 'error');
      return;
    }

    if (passwordController.text == "") {
      alertLottie(context, 'Pastikan password sudah terisi!', 'error');
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
            MaterialPageRoute(
              builder: (context) => ShowCaseWidget(
                builder: (context) => AppLayout()
              ),
            ),
          );
        }
      } else {
        if (mounted) { // Pastikan widget masih terpasang
          setState(() {
            isLoading = false;
          });
          alertLottie(context, error, 'error');
        }
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showErrorBottomSheet(context, e.toString());
    }
  }

  void showPrivacyPolicy() {
    showDialog(
      context: context,
      barrierColor: Colors.black54, // Agar tetap fokus ke dialog
      useSafeArea: false, // Menghindari batas layar
      builder: (context) {
        return AlertDialog(
          clipBehavior: Clip.hardEdge,
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text('Kebijakan Privasi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600), textAlign: TextAlign.start,)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, size: 20,))
                ],
              ),
              Gap(5),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(child: Text('Kami menghargai privasi Anda. Aplikasi ini dikembangkan untuk membantu pengguna mencatat dan mengelola transaksi penjualan.', textAlign: TextAlign.start, style: TextStyle(fontSize: 13),)),
                ],
              ),

              Gap(20),
              Text('Data yang Dikumpulkan', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600), textAlign: TextAlign.start,),
              Gap(5),
              Text('Aplikasi ini dapat menyimpan informasi berikut:', style: TextStyle(fontSize: 13), textAlign: TextAlign.start,),
              Gap(5),
              Text('• Email', style: TextStyle(fontSize: 13), textAlign: TextAlign.start,),
              Text('• Nama pengguna', style: TextStyle(fontSize: 13), textAlign: TextAlign.start,),
              Text('• Nomor Telepon', style: TextStyle(fontSize: 13), textAlign: TextAlign.start,),

              Gap(20),
              Text('Akses Izin', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600), textAlign: TextAlign.start,),
              Gap(5),
              Text('Aplikasi ini dapat meminta izin:', style: TextStyle(fontSize: 13), textAlign: TextAlign.start,),
              Gap(5),
              Text('• Bluetooth', style: TextStyle(fontSize: 13), textAlign: TextAlign.start,),
              Text('• Lokasi', style: TextStyle(fontSize: 13), textAlign: TextAlign.start,),
              Text('• Kamera', style: TextStyle(fontSize: 13), textAlign: TextAlign.start,),
              Gap(5),
              Text('Akses Bluetooth dan Lokasi digunakan hanya untuk Koneksi dengan Printer.', style: TextStyle(fontSize: 13), textAlign: TextAlign.start,),
              Gap(2),
              Text('Akses Kamera digunakan hanya untuk memindai barcode dan foto produk.', style: TextStyle(fontSize: 13), textAlign: TextAlign.start,),

              Gap(20),
              Text('Perubahan Kebijakan', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600), textAlign: TextAlign.start,),
              Gap(5),
              Text('Kami dapat memperbarui kebijakan ini sewaktu-waktu. Pengguna disarankan untuk memeriksa halaman ini secara berkala.', style: TextStyle(fontSize: 13), textAlign: TextAlign.start,),

              Gap(20),
              Text('Kontak', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600), textAlign: TextAlign.start,),
              Gap(5),
              Text('Jika ada pertanyaan tentang kebijakan ini, silakan hubungi kami melalui email:', style: TextStyle(fontSize: 13), textAlign: TextAlign.start,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(child: Text('kekasir.dev@gmail.com', textAlign: TextAlign.start, style: TextStyle(fontSize: 13),)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void openWhatsApp() async {
    final Uri url = Uri.parse(
        'https://wa.me/6288989690882?text=Halo%20*Kekasir*%20saya%20butuh%20bantuan!');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // ignore: use_build_context_synchronously
      alertLottie(context, 'Tidak dapat membuka Whatsapp');
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return Scaffold(
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
          Gap(60),
          Image.asset(
            'assets/images/logo-blue.png',
            width: 25,
          ),
          Gap(10),
          Column(
            children: [
              Text("Selamat Datang", style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 17
                )
              ),
              Gap(2),
              Text("Senang bertemu kembali 👋", style: TextStyle(
                  fontSize: 12,
                  color: Color(0xff57606f)
                )
              ),
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
                    hintText: "Misalnya jhon@kekasir.com...",
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
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/icons/done.png', width: 20),
                    Gap(5),
                    Expanded(
                      child: GestureDetector(
                        onTap: showPrivacyPolicy,
                        child: RichText(
                          text: TextSpan(
                            text: 'Saya telah menyetujui',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontFamily: 'Lexend',
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: " Kebijakan Privasi",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: login,
                    child: ButtonPrimary(
                      text: "Masuk",
                    ),
                  ),
                ),
              ],
            ),
            Gap(20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Butuh bantuan?", style: TextStyle(
                  fontSize: 12,
                  color: Color(0xff57606f)
                )),
                Gap(5),
                GestureDetector(
                  onTap: () => openWhatsApp(),
                  child: Text("Hubungi Kekasir", style: TextStyle(
                    fontSize: 12,
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
