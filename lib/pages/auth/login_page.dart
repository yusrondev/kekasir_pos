import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/apis/auth_service.dart';
import 'package:kekasir/components/custom_button_component.dart';
import 'package:kekasir/components/custom_field_component.dart';
import 'package:kekasir/helpers/lottie_helper.dart';
import 'package:kekasir/pages/layouts/app_layout.dart';

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
  
  void login() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading ? Center(
          child:CustomLoader.showCustomLoader(),
        ) : ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Column(
              children: [
                
                const Gap(90),
                Image.asset('assets/images/logo-blue.png', width: 45),
                const Gap(65),

                CustomTextField(
                  label: "Email",
                  placeholder: "Misalnya kekasir@gmail.com...",
                  controller: emailController,
                ),

                PasswordTextField(
                  label: "Password",
                  placeholder: "Password Anda...",
                  controller: passwordController,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isLoading != true ? Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: InkWell(
          onTap: () { 
            setState(() {
              isLoading = true;
            });
            login(); 
          },
          child: ButtonPrimary(
            text: "Masuk",
          ),
        ),
      ) : SizedBox.shrink(),
    );
  }
}
