import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:kekasir/apis/api_service_transaction.dart';
import 'package:kekasir/components/custom_field_component.dart';
import 'package:kekasir/components/custom_other_component.dart';
import 'package:kekasir/components/custom_text_component.dart';
import 'package:kekasir/helpers/lottie_helper.dart';
import 'package:kekasir/models/transaction.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/ui_helper.dart';
import 'package:kekasir/utils/variable.dart';
import 'package:logger/web.dart';

class MutationTransactionPage extends StatefulWidget {
  const MutationTransactionPage({super.key});

  @override
  State<MutationTransactionPage> createState() =>
      _MutationTransactionPageState();
}

class _MutationTransactionPageState extends State<MutationTransactionPage> {
  ApiServiceTransaction apiServiceTransaction = ApiServiceTransaction();

  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  List<Transaction> transactions = [];

  Timer? _debounce;

  bool loading = true;

  @override
  void initState() {
    super.initState();

    // Format tanggal hari ini
    String today = DateFormat('dd-MM-yyyy').format(DateTime.now());

    // Set default value jika kosong
    _startDateController.text = today;
    _endDateController.text = today;

    fetchMutation(_startDateController.text, _endDateController.text, _codeController.text);

    _startDateController.addListener(_validateDates);
    _endDateController.addListener(_validateDates);

    _codeController.addListener(() {
      setState(() {
        _codeController.value = _codeController.value.copyWith(
          text: _codeController.text.toUpperCase(),
          selection: TextSelection.collapsed(offset: _codeController.text.length),
        );
      });

      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(Duration(milliseconds: 800), () {
        fetchMutation(_startDateController.text, _endDateController.text, _codeController.text);
      });
    });
  }

  void _validateDates() {
    DateTime? startDate = _getDateFromText(_startDateController.text);
    DateTime? endDate = _getDateFromText(_endDateController.text);

    if (startDate != null) {

      if (endDate != null && endDate.isBefore(startDate)) {
        _endDateController.text = _startDateController.text; // Reset ke start date
      }
      
      fetchMutation(_startDateController.text, _endDateController.text, _codeController.text);
    }
  }

  // Fungsi untuk mendapatkan startDate dari teks
  DateTime _getStartDate() {
    return _getDateFromText(_startDateController.text) ?? DateTime.now();
  }

  // Fungsi untuk mengonversi teks ke DateTime
  DateTime? _getDateFromText(String dateText) {
    try {
      return DateFormat('dd-MM-yyyy').parse(dateText);
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> fetchMutation(String startDate, String endDate, String code) async {
    final data = await ApiServiceTransaction().fetchMutation(startDate, endDate, code);
    try {
      if (mounted) {
        setState(() {
          transactions = data;
          loading = false;
        });

        Logger().d(transactions);

      }
    } catch (e) {
      showErrorBottomSheet(context, e.toString());
    }
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
      body: loading == true ? Center(child: CustomLoader.showCustomLoader()) : RefreshIndicator(
        onRefresh: () async {
          await fetchMutation(_startDateController.text, _endDateController.text, _codeController.text);
        },
        color: primaryColor,
        backgroundColor: Colors.white,
        child: ListView(
          padding: defaultPadding,
          children: [
            PageTitle(text: "Mutasi Transaksi", back: true),
            Gap(15),
            SearchTextField(placeholder: "Cari berdasarkan kode", controller: _codeController,),
            Gap(10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: DatePickerField(label: "Dari tanggal", controller: _startDateController),
                ),
                Gap(10),
                Expanded(
                  child: DatePickerField(label: "Sampai tanggal", controller: _endDateController, minDate: _getStartDate())
                ),
              ],
            ),
            Gap(5),
            LineSM(),
            Gap(5),
            buildMutationList(),
          ],
        ),
      ),
    );
  }
  
  Widget buildMutationList() {
    return ListView.builder(
      padding: EdgeInsets.all(0),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index){
        
        final transaction = transactions[index];

        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/transaction/detail',
              arguments: transaction.id
            );
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: darkColor),
              borderRadius: BorderRadius.circular(10)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LabelSemiBold(text: transaction.code),
                    Gap(3),
                    Label(text: transaction.createdAt,)
                  ],
                ),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        PriceTag(text: '+ ${transaction.grandTotal}'),
                        Row(
                          children: [
                            StockTag(text: transaction.paymentMethod),
                            if(transaction.labelPrice != null) ... [
                              Gap(5),
                              WarningTag(text: transaction.labelPrice),
                            ]
                          ],
                        ),
                      ],
                    ),
                    Gap(10),
                    Icon(Icons.arrow_forward_ios_sharp, size: 13, color: darkColor,)
                  ],
                )
              ],
            ),
          ),
        );
      }
    );
  }
}