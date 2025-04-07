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

  late WebViewController controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // Initialize WebView controller dengan blank page
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
            Logger().e('WebView Error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse('about:blank'));

    fetchUser();
  }

  @override
  void dispose() {
    // Tidak perlu dispose controller secara manual di versi terbaru
    super.dispose();
  }

  Future<void> fetchUser() async {
    try {
      final data = await authService.fetchUser();
      if (mounted) {
        setState(() {
          dataMe = data;
          _loadReportUrl(); // Load URL setelah data tersedia
        });
      }
      Logger().d(dataMe);
    } catch (e) {
      Logger().e('Failed to fetch user: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _loadReportUrl() {
    if (dataMe?['id'] != null) {
      final url = 'https://kekasir-core.dewadev.id/report/product/${dataMe!['id']}';
      controller.loadRequest(Uri.parse(url));
    } else {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Widget _buildWebView() {
    if (_hasError) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 50),
          const SizedBox(height: 16),
          const Text(
            'Gagal memuat laporan',
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadReportUrl,
            child: const Text('Coba Lagi'),
          ),
        ],
      );
    }

    return Stack(
      children: [
        WebViewWidget(controller: controller),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
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
              child: _buildWebView(),
            ),
          ],
        ),
      ),
    );
  }
}