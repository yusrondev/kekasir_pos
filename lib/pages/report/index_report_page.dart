import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/apis/auth_service.dart';
import 'package:kekasir/components/custom_text_component.dart';
import 'package:kekasir/models/product.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/variable.dart';
import 'package:logger/web.dart';
import 'package:webview_flutter/webview_flutter.dart';

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

  WebViewController? controller;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    fetchUser();
  }

  @override
  void dispose() {
    // Kembalikan orientasi ke portrait-only saat keluar dari halaman
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Future<void> fetchUser() async {
    final data = await authService.fetchUser();
    if (mounted) {
      setState(() {
        dataMe = data;
        _initWebView(); // Inisialisasi WebView setelah data tersedia
      });
    }
    Logger().d(dataMe);
  }

   void _initWebView() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(
          'https://kekasir-core.dewadev.id/report/product/${dataMe?['id'] ?? ''}'));
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
      body: DefaultTabController(
        length: 2,
        child: Padding(
          padding: defaultPadding,
          child: Column(
            children: [
              PageTitle(text: "Laporan", back: true,),
              Gap(5),
              const TabBar(
                labelColor: primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: primaryColor,
                
                tabs: [
                  Tab(text: "Produk"),
                  Tab(text: "Transaksi"),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(top: 10),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: TabBarView(
                        children: [
                          controller != null
                          ? WebViewWidget(controller: controller!) // Gunakan 'controller!'
                          : Center(child: CircularProgressIndicator()), // Tampilkan loading jika null
                          Center(child: Icon(Icons.directions_transit, size: 100)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
