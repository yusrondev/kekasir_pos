import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/apis/auth_service.dart';
import 'package:kekasir/components/custom_other_component.dart';
import 'package:kekasir/components/custom_text_component.dart';
import 'package:kekasir/helpers/dialog_helper.dart';
import 'package:kekasir/pages/auth/login_page.dart';
import 'package:kekasir/utils/variable.dart';

class IndexProfilePage extends StatefulWidget {
  const IndexProfilePage({super.key});

  @override
  State<IndexProfilePage> createState() => _IndexProfilePageState();
}

class _IndexProfilePageState extends State<IndexProfilePage> {

  AuthService authService = AuthService();
  final String? version = dotenv.env['APP_VERSION'];

  void logout() async {
    await AuthService().logout();
    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: ListView(
        padding: defaultPadding,  
        children: [
          PageTitle(text: "", back: true,),

          Gap(18),
          
          Row(
            children: [
              Icon(Icons.account_circle, size: 20,),
              Gap(8),
              LabelSemiBold(text: "Profil Saya"),
            ],
          ),

          Line(),

          Row(
            children: [
              Icon(Icons.star, size: 20,),
              Gap(8),
              LabelSemiBold(text: "Informasi Paket"),
            ],
          ),

          Line(),

          Row(
            children: [
              Icon(Icons.notifications, size: 20,),
              Gap(8),
              LabelSemiBold(text: "Notifikasi"),
            ],
          ),

          Line(),
          
          Row(
            children: [
              Icon(Icons.help, size: 20,),
              Gap(8),
              LabelSemiBold(text: "Bantuan"),
            ],
          ),

          Line(),

          InkWell(
            onTap: () {
              DialogHelper.showLogoutConfirmation(context: context, onConfirm: () => logout());
            },
            child: Row(
              children: [
                Icon(Icons.logout, size: 20,),
                Gap(8),
                LabelSemiBold(text: "Keluar"),
              ],
            ),
          ),

          Line(),
          
        ]
      ),
    );
  }
}