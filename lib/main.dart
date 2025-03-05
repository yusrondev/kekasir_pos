import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kekasir/apis/auth_service.dart';
import 'package:kekasir/models/product.dart';
import 'package:kekasir/pages/auth/login_page.dart';
import 'package:kekasir/pages/layouts/app_layout.dart';
import 'package:kekasir/pages/product/form_product_page.dart';
import 'package:kekasir/pages/profile/edit_profile_page.dart';
import 'package:kekasir/pages/profile/index_profile_page.dart';
import 'package:kekasir/pages/discount/form_discount_page.dart';
import 'package:kekasir/pages/stock/detail_stock_page.dart';
import 'package:kekasir/pages/stock/index_stock_page.dart';
import 'package:kekasir/pages/transaction/checkout_transaction_page.dart';
import 'package:kekasir/pages/transaction/detail_mutation_transaction_page.dart';
import 'package:kekasir/pages/transaction/index_transaction_page.dart';
import 'package:kekasir/pages/transaction/mutation_transaction_page.dart';
import 'package:kekasir/pages/transaction/nota_transaction_page.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:intl/date_symbol_data_local.dart'; // Tambahkan ini

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized(); // Pastikan Flutter terinisialisasi
  await initializeDateFormatting('id_ID', null); // Inisialisasi data lokal

  WidgetsFlutterBinding.ensureInitialized(); // untuk disable rotasi
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(MainApp());
  });
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
        '/profile' : (context) => IndexProfilePage(),
        '/profile/edit' : (context) => EditProfilePage(),
        '/stock' : (context) => IndexStockPage(),
        '/stock-detail' : (context) => DetailStockPage(),
        '/transaction' : (context) => IndexTransactionPage(),
        '/transaction/mutation' : (context) => MutationTransactionPage(),
        '/transaction/detail' : (context) {
          final id = ModalRoute.of(context)!.settings.arguments;
          return DetailMutationTransactionPage(id : id);
        },
        '/checkout' : (context) => CheckoutTransactionPage(),
        '/nota' : (context) => NotaTransactionPage(),
        '/form-discount' : (context) { 
          final product = ModalRoute.of(context)!.settings.arguments as Product;
          return FormDiscountPage(product : product);
        },
      },
    );
  }
}
