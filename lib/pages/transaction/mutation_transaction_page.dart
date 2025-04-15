import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:kekasir/apis/api_service_transaction.dart';
import 'package:kekasir/apis/api_service_type_price.dart';
import 'package:kekasir/components/custom_button_component.dart';
import 'package:kekasir/components/custom_field_component.dart';
import 'package:kekasir/components/custom_other_component.dart';
import 'package:kekasir/components/custom_text_component.dart';
import 'package:kekasir/helpers/lottie_helper.dart';
import 'package:kekasir/models/label_price.dart';
import 'package:kekasir/models/transaction.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/ui_helper.dart';
import 'package:logger/web.dart';

class MutationTransactionPage extends StatefulWidget {
  const MutationTransactionPage({super.key});

  @override
  State<MutationTransactionPage> createState() =>
      _MutationTransactionPageState();
}

class _MutationTransactionPageState extends State<MutationTransactionPage> {
  ApiServiceTransaction apiServiceTransaction = ApiServiceTransaction();
  ApiServiceTypePrice apiServiceTypePrice = ApiServiceTypePrice();

  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  List<Transaction> transactions = [];
  List<LabelPrice> labelPrices = [];
  String? _selectedName = "";
  String? _selectedId = "";

  Timer? _debounce;
  String? grandTotal;

  bool loading = true;
  bool selectedPriceType = false;
  bool flagShowSaveBtn = false;

  @override
  void initState() {
    super.initState();

    // Format tanggal hari ini
    String today = DateFormat('dd-MM-yyyy').format(DateTime.now());

    // Set default value jika kosong
    _startDateController.text = today;
    _endDateController.text = today;

    fetchMutation(_startDateController.text, _endDateController.text, _codeController.text, _selectedId);

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
        fetchMutation(_startDateController.text, _endDateController.text, _codeController.text, _selectedId);
      });
    });

    fetchLabelPrice(0);
  }

  Future<void> fetchLabelPrice(productId) async {
    final data = await apiServiceTypePrice.fetchLabelPrice(productId);

    if (mounted) { // Cek apakah widget masih ada sebelum setState
      setState(() {
        labelPrices = data;
      });

      Logger().d(labelPrices);
    }
  }

  void _validateDates() {
    DateTime? startDate = _getDateFromText(_startDateController.text);
    DateTime? endDate = _getDateFromText(_endDateController.text);

    if (startDate != null) {

      if (endDate != null && endDate.isBefore(startDate)) {
        _endDateController.text = _startDateController.text; // Reset ke start date
      }
      
      fetchMutation(_startDateController.text, _endDateController.text, _codeController.text, _selectedId);
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

  Future<void> fetchMutation(String startDate, String endDate, String code, [String? selectedId]) async {
    final data = await ApiServiceTransaction().fetchMutation(startDate, endDate, code, selectedId);
    try {
      if (mounted) {
        setState(() {
          transactions = data.transactionList;
          grandTotal = data.grandTotal;
          loading = false;
        });

        Logger().d(grandTotal);

      }
    } catch (e) {
      showErrorBottomSheet(context, e.toString());
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return "";
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  void showDialogListPriceType() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4), // Atur tingkat 
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              clipBehavior: Clip.hardEdge,
              backgroundColor: Colors.white,
              content: Container(
                width: 100,
                constraints: BoxConstraints(
                  minHeight: 100, // Tinggi minimum
                  maxHeight: 350
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LabelSemiBold(text: "Pilih Tipe Harga"),
                    Gap(2),
                    Text("Sesuaikan filter menggunakan tipe harga, klik lagi tipe harga untuk batal memilih", textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                    LineXM(),
                    Container(
                      constraints: BoxConstraints(
                        minHeight: 40, // Tinggi minimum
                        maxHeight: 190
                      ),
                      child: Scrollbar(
                        thumbVisibility: true, // Agar scrollbar selalu terlihat
                        thickness: 3, // Ketebalan scrollbar
                        radius: Radius.circular(10), // Membuat scrollbar lebih halus
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.all(0),
                          itemCount: labelPrices.length,
                          itemBuilder: (context, index){
                            final labelPrice = labelPrices[index];
                            bool isSelected = _selectedName == labelPrice.name; 
                                    
                            return GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  if (_selectedName == labelPrice.name) {
                                    _selectedName = "";
                                    _selectedId = "";
                                  }else{
                                    flagShowSaveBtn = true;
                                    _selectedName = labelPrice.name;
                                    _selectedId = labelPrice.id.toString();
                                  }
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 5),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isSelected == true ? bgSuccess : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: isSelected == true ? successColor : secondaryColor)
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(_capitalize(labelPrice.name.toString()), style: TextStyle(
                                      color: isSelected == true ? successColor : Colors.black,
                                      fontWeight: FontWeight.w600
                                    )),
                                    if(isSelected) ... [
                                      Icon(Icons.check_circle, size: 15, color: successColor,)
                                    ] else ... [
                                      Icon(Icons.keyboard_arrow_right_rounded, size: 15, color: primaryColor,)
                                    ]
                                  ],
                                ),
                              ),
                            );
                          }
                        ),
                      ),
                    ),
                    Gap(10),
                    if(flagShowSaveBtn == true)
                      Row(
                        children: [
                          Expanded(
                            child: ButtonPrimary(text: _selectedName.toString() == "" ? "Simpan" : "Ubah ke ${_selectedName.toString()}", onPressed: () {
                              if(_selectedName.toString() != ""){
                                setState(() {
                                  selectedPriceType = true;
                                  flagShowSaveBtn = false;
                                });
                              }
                              fetchMutation(_startDateController.text, _endDateController.text, _codeController.text, _selectedId);
                              Navigator.pop(context);
                              alertLottie(context, _selectedName.toString() == "" ? "Beralih ke semua tipe harga" : "Beralih ke harga ${_selectedName.toString()}");
                            })
                          )
                        ],
                      ),
                    if(_selectedName.toString() != "" && selectedPriceType == true)
                      Row(
                        children: [
                          Expanded(
                            child: ButtonPrimaryOutline(text: "Beralih ke harga normal", onPressed: () {
                              setState(() {
                                _selectedId = "";
                                _selectedName = "";
                                selectedPriceType = false;
                              });
                              fetchMutation(_startDateController.text, _endDateController.text, _codeController.text, _selectedId);
                              Navigator.pop(context);
                              alertLottie(context, "Beralih ke harga normal");
                            }
                          )
                        )
                      ])
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar:true,
      backgroundColor: Colors.white,
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
          await fetchMutation(_startDateController.text, _endDateController.text, _codeController.text, _selectedId);
        },
        color: primaryColor,
        backgroundColor: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 45, left: 14, right: 14), 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PageTitle(text: "Mutasi Transaksi", back: true),
                  PriceTag(text: 'Total : $grandTotal',)
                ],
              ),
            ),
            Gap(15),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(bottom: 45, left: 14, right: 14), 
                children: [
                  Row(
                    children: [
                      Expanded(child: SearchTextField(placeholder: "Cari berdasarkan kode", controller: _codeController,)),
                      if(labelPrices.isNotEmpty) ... [
                        Gap(5),
                        GestureDetector(
                          onTap: () => showDialogListPriceType(),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: ligthSky,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: secondaryColor)
                            ),
                            child: Row(
                              children: [
                                Text(_selectedName.toString().isNotEmpty ? toBeginningOfSentenceCase(_selectedName.toString()) : "Tipe Harga", style: TextStyle(fontSize: 14),),
                                Icon(Icons.arrow_drop_down_rounded, size: 20),
                              ],
                            ),
                          ),
                        )
                      ]
                    ],
                  ),
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