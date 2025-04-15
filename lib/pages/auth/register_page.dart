import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:kekasir/apis/auth_service.dart';
import 'package:kekasir/components/custom_button_component.dart';
import 'package:kekasir/components/custom_field_component.dart';
import 'package:kekasir/helpers/lottie_helper.dart';
import 'package:kekasir/pages/layouts/app_layout.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/ui_helper.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late InternetConnectionChecker _connectionChecker;

  final TextEditingController storeNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
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

  bool isValidEmail(String email) {
    final RegExp regex = RegExp(r'^[a-zA-Z0-9._%+-]+@kekasir\.com$');
    return regex.hasMatch(email);
  }

  void register() async {
    if (!isValidEmail(emailController.text)) {
      setState(() {
        isLoading = false;
      });
      alertLottie(context, "Format email tidak valid! \n Harus menggunakan domain @kekasir.com", "error");
      return;
    }

    if (storeNameController.text == "") {
      alertLottie(context, 'Pastikan nama toko sudah terisi!', 'error');
      return;
    }

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
      String? error = await authService.register(
        storeNameController.text,
        phoneController.text,
        addressController.text,
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
          alertLottie(context, error, 'error');
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
      alertLottie(context, 'Tidak dapat membuka Whatsapp');
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return  Scaffold(
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
        ) : ListView(
            padding: EdgeInsets.symmetric(vertical: 10),
            children: [
            Column(
              children: [
                Gap(70),
                Image.asset(
                  'assets/images/logo-blue.png',
                  width: 25,
                ),
                Gap(20),
                Column(
                  children: [
                    Text("Yuk, Buat Akun Baru!", style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 17
                      )
                    ),
                    Gap(2),
                    Text("Hanya butuh beberapa detik untuk jadi bagian dari Kekasir 👏", style: TextStyle(
                        fontSize: 12,
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
                      Text("Nama Toko *", style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14
                      )),
                      Gap(7),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          border: Border.all(
                            color: secondaryColor,
                          ),
                        ),
                        child: TextField(
                          cursorColor: primaryColor,
                          maxLength: 50,
                          maxLines: 1,
                          controller: storeNameController,
                          decoration: InputDecoration(
                            counterText: "",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            hintText: "Masukkan nama toko",
                            hintStyle: TextStyle(
                              color: Color(0xffB1B9C3), 
                              fontSize: 14
                            )
                          ),
                        )
                      ),
                      Gap(10),
                      CustomTextField(
                        border: true,
                        controller: addressController,
                        label: "Alamat",
                        placeholder: "Misalnya Jl Pahlawan (tidak wajib)...",
                        maxLength : 100,
                      ),
                      Text("No Telepon ", style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14
                      )),
                      Gap(7),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          border: Border.all(
                            color: secondaryColor,
                          ),
                        ),
                        child: TextField(
                          cursorColor: primaryColor,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(14),
                          ], 
                          maxLength: 14,
                          maxLines: 1,
                          controller: phoneController,
                          decoration: InputDecoration(
                            counterText: "",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            hintText: "Masukkan nomor telepon",
                            hintStyle: TextStyle(
                              color: Color(0xffB1B9C3), 
                              fontSize: 14
                              )
                            ),
                          )
                      ),
                  
                      Gap(10),
                      Text("Email *", style: TextStyle(
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
                          Text("Password *", style: TextStyle(
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
          ] 
        ),
      bottomNavigationBar: isLoading != true ? Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () { 
                register(); 
              },
              child: SizedBox(
                width: double.infinity,
                child: ButtonPrimary(
                  text: "Daftar",
                ),
              )
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
