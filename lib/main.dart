import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:kekasir/apis/auth_service.dart';
import 'package:kekasir/models/employee.dart';
import 'package:kekasir/models/product.dart';
import 'package:kekasir/pages/auth/login_page.dart';
// import 'package:kekasir/pages/auth/login_page.dart';
import 'package:kekasir/pages/auth/register_page.dart';
import 'package:kekasir/pages/employee/form_employee_page.dart';
import 'package:kekasir/pages/employee/index_employee_page.dart';
import 'package:kekasir/pages/landing_page.dart';
import 'package:kekasir/pages/layouts/app_layout.dart';
import 'package:kekasir/pages/product/form_product_page.dart';
import 'package:kekasir/pages/profile/detail_package_page.dart';
import 'package:kekasir/pages/profile/edit_profile_page.dart';
import 'package:kekasir/pages/profile/index_profile_page.dart';
import 'package:kekasir/pages/discount/form_discount_page.dart';
import 'package:kekasir/pages/report/index_report_page.dart';
import 'package:kekasir/pages/stock/detail_stock_page.dart';
import 'package:kekasir/pages/stock/index_stock_page.dart';
import 'package:kekasir/pages/transaction/checkout_transaction_page.dart';
import 'package:kekasir/pages/transaction/detail_mutation_transaction_page.dart';
import 'package:kekasir/pages/transaction/index_transaction_page.dart';
import 'package:kekasir/pages/transaction/mutation_transaction_page.dart';
import 'package:kekasir/pages/transaction/nota_transaction_page.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logger/web.dart';
import 'package:showcaseview/showcaseview.dart'; // Tambahkan ini

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized(); // Pastikan Flutter terinisialisasi
  await initializeDateFormatting('id_ID', null); // Inisialisasi data lokal

  GoogleFonts.config.allowRuntimeFetching = false;

  // Cek apakah ada update dari Play Store
  try {
    AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
    if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
      await InAppUpdate.performImmediateUpdate();
    }
  } catch (e) {
    Logger().d('Gagal memeriksa update: $e');
  }

  WidgetsFlutterBinding.ensureInitialized(); // untuk disable rotasi
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(MainApp());
  });
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  Future<Widget> checkToken(context) async {
    AuthService authService = AuthService();
    String? token = await authService.getToken();
    return ShowCaseWidget(builder: (context) => token == null ? LandingPage() : AppLayout());
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
         textTheme: TextTheme(
            bodyLarge: TextStyle(fontFamily: 'Lexend', height: 1.2,), 
            bodyMedium: TextStyle(fontFamily: 'Lexend', height: 1.2,),
            titleLarge: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.w600,  height: 1.2,), // SemiBold
            titleMedium: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.w700,  height: 1.2,), // Bold
          ),
      ),
      debugShowCheckedModeBanner: false,
      locale: Locale('id'), // Set bahasa Indonesia
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(0.98)), // Kunci ukuran font
          child: child!,
        );
      },
      home: FutureBuilder(
        future: checkToken(context),
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
        '/stock-detail' : (context) {
          final product = ModalRoute.of(context)!.settings.arguments as Product;
          return DetailStockPage(product : product);
        },
        '/transaction' : (context) => IndexTransactionPage(),
        '/transaction/mutation' : (context) => MutationTransactionPage(),
        '/transaction/detail' : (context) {
          final id = ModalRoute.of(context)!.settings.arguments;
          return DetailMutationTransactionPage(id : id);
        },
        '/checkout' : (context) => CheckoutTransactionPage(),
        '/nota' : (context) {
          final id = ModalRoute.of(context)!.settings.arguments;
          return NotaTransactionPage(id : id);
        },
        '/form-discount' : (context) { 
          final product = ModalRoute.of(context)!.settings.arguments as Product;
          return FormDiscountPage(product : product);
        },
        '/report' : (context) => IndexReportPage(),
        '/login' : (context) => LoginPage(),
        '/register' : (context) => RegisterPage(),
        '/detail-package' : (context) => DetailPackagePage(),
        '/employee' : (context) => IndexEmployeePage(),
        '/create-employee' : (context) => FormEmployeePage(),
        '/edit-employee': (context) {
          final employee = ModalRoute.of(context)!.settings.arguments as Employee;
          return FormEmployeePage(employee: employee);
        },
      },
    );
  }
}
