import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kekasir/apis/auth_service.dart';
import 'package:kekasir/models/product.dart';
import 'package:kekasir/pages/auth/login_page.dart';
import 'package:kekasir/pages/layouts/app_layout.dart';
import 'package:kekasir/pages/product/form_product_page.dart';
import 'package:kekasir/pages/profile/index_profile_page.dart';
import 'package:kekasir/utils/colors.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  Future<Widget> checkToken() async {
    AuthService authService = AuthService();
    String? token = await authService.getToken();
    return token == null ? LoginPage() : AppLayout();
  }

  @override
  Widget build(BuildContext context) {
    
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: primaryColor, // Warna status bar untuk halaman ini
      statusBarIconBrightness: Brightness.light, // Ikon terang
    ));

    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xffEDF1F9),
        textTheme: GoogleFonts.lexendTextTheme()
      ),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: checkToken(),
        builder: (context, AsyncSnapshot<Widget> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return snapshot.data!;
        },
      ),
      routes: {
        '/create-product' : (context) => FormProductPage(),
        '/edit-product': (context) {
          final product = ModalRoute.of(context)!.settings.arguments as Product;
          return FormProductPage(product: product);
        },
        '/profile' : (context) => IndexProfilePage()
      },
    );
  }
}
