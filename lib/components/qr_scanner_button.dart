import 'package:flutter/material.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class QrScannerButton extends StatefulWidget {
  final TextEditingController controller;
  final Function(String)? onScanned;
  const QrScannerButton({super.key, required this.controller, this.onScanned});

  @override
  State<QrScannerButton> createState() => _QrScannerButtonState();
}

class _QrScannerButtonState extends State<QrScannerButton> {
  @override
  void initState() {
    super.initState();
    // Pantau perubahan text controller untuk update UI
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {}); // Akan memicu rebuild untuk ganti ikon
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _startScan(BuildContext context) async {
    final scannedCode = await SimpleBarcodeScanner.scanBarcode(
      context,
      barcodeAppBar: const BarcodeAppBar(
        appBarTitle: 'Scan Barcode/QR',
        centerTitle: false,
        enableBackButton: true,
        backButtonIcon: Icon(Icons.arrow_back_ios),
      ),
      isShowFlashIcon: true,
      delayMillis: 500,
      cameraFace: CameraFace.back,
    );

    if (scannedCode != null && scannedCode != '-1') {
      widget.controller.text = scannedCode;
      if (widget.onScanned != null) {
        widget.onScanned!(scannedCode); // <== ini yang penting
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = widget.controller.text.isNotEmpty;

    return GestureDetector(
      onTap: () {
        if (hasValue) {
          widget.controller.clear();
        } else {
          _startScan(context);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: hasValue ? Color(0xffe74c3c): primaryColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ligthSky, width: 4)
        ),
        child: Icon(
          hasValue ? Icons.close_rounded : Icons.qr_code_scanner_rounded,
          color: Colors.white,
        ),
      ),
    );
  }
}
