import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/apis/auth_service.dart';
import 'package:kekasir/components/custom_button_component.dart';
import 'package:kekasir/components/custom_other_component.dart';
import 'package:kekasir/components/custom_text_component.dart';
import 'package:kekasir/helpers/dialog_helper.dart';
import 'package:kekasir/helpers/lottie_helper.dart';
import 'package:kekasir/pages/landing_page.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/ui_helper.dart';
import 'package:kekasir/utils/variable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class IndexProfilePage extends StatefulWidget {
  const IndexProfilePage({super.key});

  @override
  State<IndexProfilePage> createState() => _IndexProfilePageState();
}

class _IndexProfilePageState extends State<IndexProfilePage> {

  Map<String, dynamic>? dataMe;

  TextEditingController passwordController = TextEditingController();

  AuthService authService = AuthService();
  final String? version = dotenv.env['APP_VERSION'];

  bool isLoading = true;
  String checkOwner = '';

  @override
  void initState() {
    super.initState();
    me();
  }

  void logout() async {
    await AuthService().logout();
    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (context) => LandingPage()),
    );
  }

  void openWhatsApp() async {
    final Uri url = Uri.parse(
        'https://wa.me/6281232705237?text=Halo%20*Kekasir*%20saya%20butuh%20bantuan!');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      alertLottie(context, 'Tidak dapat membuka Whatsapp', 'error');
    }
  }

  Future<void> me() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      checkOwner = prefs.getString("is_owner") ?? "0";
    });
    try {
      final data = await authService.fetchUser();
      
      if (data == null) {
        Navigator.pop(context);
        throw Exception("Gagal mengambil data pengguna.");
      }

      if (data.isEmpty) {
        Navigator.pop(context);
        throw Exception("Gagal mengambil data pengguna.");
      }

      if (mounted) {
        setState(() {
          dataMe = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        showErrorBottomSheet(context, e.toString());
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Kekasir $version",
              style: TextStyle(
                fontSize: 12
              ),
            )
          ],
        ),
      ),
      body: buildMainInformation()
    );
  }

  Widget buildMainInformation() {
    if (isLoading == true) {
      return Center(
        child: CustomLoader.showCustomLoader(),
      );
    }

    return ListView(
      padding: defaultPadding,  
      children: [
        PageTitle(text: "", back: true,),

        Gap(18),

        Column(
          children: [
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: Color(0xfff1f2f6),
                borderRadius: BorderRadius.circular(100)
              ),
              child: Center(
                child: Text(
                  dataMe?['name'].substring(0, 1).toUpperCase() ?? "",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xff57606f),
                    fontSize: 35
                  ),
                ),
              ),
            ),
            Gap(10),
            LabelSemiBold(
              text: dataMe?['name'],
            ),
            Label(
              text: dataMe?['email'],
            ),
            Gap(10),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/profile/edit', arguments: dataMe).then((value){
                  if (value == true) {
                    me();
                  }
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: primaryColor),
                  borderRadius: BorderRadius.circular(15)
                ),
                child: Text(
                  textAlign: TextAlign.center,
                  "Ubah Profil",
                  style: TextStyle(
                    color: primaryColor
                  ),
                )
              ),
            )
          ],
        ),

        Gap(30),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Text("Utama", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12)),
        ),

        Gap(5),

        Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xffE7E7E7)),
            color: Color(0xffF3F3F3),
            borderRadius: BorderRadius.circular(20)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/detail-package'),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/icons/sparkles.png',
                          width: 20,
                        ),
                        Gap(10),
                        Text("Informasi Paket", style: TextStyle(fontWeight: FontWeight.w600),),
                      ],
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_right_outlined, size: 15)
                ],
              ),
              LineXM(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/icons/notification.png',
                        width: 20,
                      ),
                      Gap(10),
                      Text("Notifikasi Sistem", style: TextStyle(fontWeight: FontWeight.w600),),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Belum tersedia', style: TextStyle(fontSize: 12, color: softBlack)),
                      Icon(Icons.keyboard_arrow_right_outlined, size: 15, color: softBlack),
                    ],
                  )
                ],
              ),
              LineXM(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/icons/help-assistance.png',
                        width: 20,
                      ),
                      Gap(10),
                      Text("Bantuan", style: TextStyle(fontWeight: FontWeight.w600),),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Belum tersedia', style: TextStyle(fontSize: 12, color: softBlack)),
                      Icon(Icons.keyboard_arrow_right_outlined, size: 15, color: softBlack),
                    ],
                  )
                ],
              ),
              LineXM(),
              GestureDetector(
                onTap: () => openWhatsApp(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/customer-service.png',
                          width: 20,
                        ),
                        Gap(10),
                        Text("Hubungi Kekasir", style: TextStyle(fontWeight: FontWeight.w600),),
                      ],
                    ),
                    Icon(Icons.keyboard_arrow_right_outlined, size: 15)
                  ],
                ),
              ),
            ],
          ),
        ),

        if(checkOwner == "1") ... [
          Gap(20),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Text("Pengolahan Data", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12)),
          ),
          Gap(5),
          GestureDetector(
            onTap: () {
              DialogHelper.customDialog(context: context, onConfirm: (){showInputDialog();}, content: "Semua data yang sudah Anda tambahkan akan dihapus secara permanen, termasuk produk, transaksi, stok, laporan, dan mutasi. \n\nApakah Anda yakin dengan tindakan ini?", title: "Peringatan Penting!", actionButton: true);
            },
            child: Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xffE7E7E7)),
                color: Color(0xffF3F3F3),
                borderRadius: BorderRadius.circular(20)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.restart_alt_rounded, color: Color(0xffE74C3C), size: 20),
                          Gap(10),
                          Text("Atur Ulang", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xffE74C3C))),
                        ],
                      ),
                      Icon(Icons.keyboard_arrow_right_outlined, size: 15, color: Color(0xffE74C3C)),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],

        Gap(20),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Text("Preferensi", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12)),
        ),

        Gap(5),

        Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xffE7E7E7)),
            color: Color(0xffF3F3F3),
            borderRadius: BorderRadius.circular(20)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/icons/settings.png',
                        width: 20,
                      ),
                      Gap(10),
                      Text("Pengaturan", style: TextStyle(fontWeight: FontWeight.w600),),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Belum tersedia', style: TextStyle(fontSize: 12, color: softBlack)),
                      Icon(Icons.keyboard_arrow_right_outlined, size: 15, color: softBlack),
                    ],
                  )
                ],
              ),
              LineXM(),
              GestureDetector(
                onTap: () {
                  DialogHelper.showLogoutConfirmation(context: context, onConfirm: () => logout());
                },
                child: Row(
                  children: [
                    Image.asset(
                      'assets/icons/logout.png',
                      width: 17,
                    ),
                    Gap(10),
                    Expanded(child: Text("Logout", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xffE74C3C)))),
                    Icon(Icons.keyboard_arrow_right_outlined, size: 15, color: Color(0xffE74C3C)),
                  ],
                ),
              ),
            ],
          ),
        ),
        
      ]
    );
  }

  Future<void> processResetData() async{

    try {
      String? error = await authService.resetData(
        passwordController.text
      );

      if (error == null) {
        if (mounted) { // Pastikan widget masih terpasang
          setState(() {
            isLoading = false;
            passwordController.text = "";
          });

          await removeRevenue();
          
          Navigator.pop(context);
          // berhasil
          alertLottie(context, "Data berhasil direset!");
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

  Future<void> removeRevenue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('this_month_revenue');
    await prefs.remove('last_month_revenue');
    await prefs.remove('total_purchases');
    await prefs.remove('total_purchases_last_month');
    await prefs.remove('gross_profit');
    await prefs.remove('gross_profit_last_month');
    await prefs.remove('hpp');
  }
  
  void showInputDialog() {
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
              Text("Masukkan Password", style: TextStyle(fontWeight: FontWeight.w600)),
              Text("Demi keamanan mohon konfirmasi password Anda."),
              Gap(10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: secondaryColor),
                ),
                child: TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: InputBorder.none,
                    hintText: "******"
                  ),
                ),
              ),
              Gap(10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      onTap: (){
                        if (passwordController.text.isEmpty) {
                          alertLottie(context, "Password tidak boleh kosong!", "error");
                          return;
                        }

                        processResetData();
                      },
                      child: ButtonPrimary(
                        text: "Proses",
                      ),
                    )
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}