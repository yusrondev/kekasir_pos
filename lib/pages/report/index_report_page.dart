import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/apis/auth_service.dart';
import 'package:kekasir/components/custom_text_component.dart';
import 'package:kekasir/models/product.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/variable.dart';
import 'package:logger/web.dart';

class IndexReportPage extends StatefulWidget {
  const IndexReportPage({super.key});

  @override
  State<IndexReportPage> createState() => _IndexReportPageState();
}

class _IndexReportPageState extends State<IndexReportPage> {
  AuthService authService = AuthService();
  List<Product> products = [];
  List<String> productNames = [];
  TextEditingController keyword = TextEditingController();
  Map<String, dynamic>? dataMe;
  final dropDownKey = GlobalKey<DropdownSearchState>();

  @override
  void initState() {
    super.initState();
    // Mengizinkan semua orientasi pada halaman ini
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    fetchUser();
  }

  Future<void> fetchUser() async {
    try {
      final data = await authService.fetchUser();
      if (mounted) {
        setState(() {
          dataMe = data;
        });
      }
      Logger().d(dataMe);
    } catch (e) {
      Logger().e('Failed to fetch user: $e');
    }
  }

  @override
  void dispose() {
    // Mengembalikan orientasi ke mode potret setelah keluar dari halaman ini
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: primaryColor,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: defaultPadding,
        child: Column(
          children: [
            PageTitle(text: "Laporan", back: true),
            const Gap(5),
            Expanded(
              child: dataMe == null
                  ? const Center(child: CircularProgressIndicator()) // Tampilkan loading jika dataMe masih null
                  : InAppWebView(
                      initialUrlRequest: URLRequest(
                        url: WebUri("https://kekasir-core.dewadev.id/report/product/${dataMe?['id'] ?? ''}"),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
