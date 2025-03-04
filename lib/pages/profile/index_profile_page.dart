import 'package:flutter/material.dart';
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

  Future<void> me() async {
    try {
      final data = await authService.fetchUser();
      
      if (data == null) {
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
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.asset('assets/images/empty.png', width: 70,)
            ),
            Gap(10),
            LabelSemiBold(
              text: dataMe?['name'],
            ),
            Label(
              text: dataMe?['email'],
            ),
            Gap(10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(15)
              ),
              child: Text(
                textAlign: TextAlign.center,
                "Edit Profile",
                style: TextStyle(
                  color: Colors.white
                ),
              )
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
                        'assets/icons/help-assistance.png',
                        width: 20,
                      ),
                      Gap(10),
                      Text("Bantuan", style: TextStyle(fontWeight: FontWeight.w600),),
                    ],
                  ),
                  Icon(Icons.keyboard_arrow_right_outlined, size: 15)
                ],
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
                  Icon(Icons.keyboard_arrow_right_outlined, size: 15)
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
                    Text("Keluar", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xffE74C3C))),
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