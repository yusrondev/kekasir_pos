import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/apis/auth_service.dart';
import 'package:kekasir/components/custom_other_component.dart';
import 'package:kekasir/components/custom_text_component.dart';
import 'package:kekasir/helpers/dialog_helper.dart';
import 'package:kekasir/helpers/lottie_helper.dart';
import 'package:kekasir/pages/auth/login_page.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/ui_helper.dart';
import 'package:kekasir/utils/variable.dart';
import 'package:url_launcher/url_launcher.dart';

class IndexProfilePage extends StatefulWidget {
  const IndexProfilePage({super.key});

  @override
  State<IndexProfilePage> createState() => _IndexProfilePageState();
}

class _IndexProfilePageState extends State<IndexProfilePage> {

  Map<String, dynamic>? dataMe;

  AuthService authService = AuthService();
  final String? version = dotenv.env['APP_VERSION'];

  bool isLoading = true;

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
      MaterialPageRoute(builder: (context) => LoginPage()),
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
                  Row(
                    children: [
                      Image.asset(
                        'assets/icons/sparkles.png',
                        width: 20,
                      ),
                      Gap(10),
                      Text("Informasi Paket", style: TextStyle(fontWeight: FontWeight.w600),),
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
}