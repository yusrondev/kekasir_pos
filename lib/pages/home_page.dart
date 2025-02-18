import 'package:flutter/material.dart';
import 'package:kekasir/apis/auth_service.dart';
import 'package:kekasir/pages/auth/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthService authService = AuthService();

  void logout() async {
    await AuthService().logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: InkWell(
          onTap: () {
            logout();
          },
          child: Text(
            "Ini adalah home"
          ),
        ),
      ),
    );
  }
}