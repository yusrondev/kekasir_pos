import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/apis/api_service.dart';
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
  ApiService apiService = ApiService();
  List<Product> products = [];
  List<String> productNames = [];
  TextEditingController keyword = TextEditingController();
  String? selectedProduct;
  final dropDownKey = GlobalKey<DropdownSearchState>();

  @override
  void initState() {
    super.initState();
    fetchProducts(keyword.text);
  }

  Future<void> fetchProducts(String keyword) async {
    final data = await apiService.fetchProducts(keyword);
    if (mounted) {
      setState(() {
        products = data;

        // Ambil hanya nama produk
        productNames = products.map((product) => product.name).toList();
      });

      Logger().d(productNames); // Akan mencetak: ['Crafting', 'testing']
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: DefaultTabController(
        length: 2,
        child: Padding(
          padding: defaultPadding,
          child: Column(
            children: [
              PageTitle(text: "Laporan $selectedProduct", back: true,),
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
                      height: MediaQuery.of(context).size.height - 200, // Sesuaikan tinggi agar cukup ruang
                      child: TabBarView(
                        children: [
                          Column(
                            children: [
                              DropdownSearch<String>(
                                onChanged: (value) {
                                  setState(() {
                                    selectedProduct = value;
                                  });
                                },
                                key: dropDownKey,
                                selectedItem: "Menu",
                                items: (filter, infiniteScrollProps) => productNames,
                                decoratorProps: DropDownDecoratorProps(
                                  decoration: InputDecoration(
                                    border: InputBorder.none
                                  ),
                                ),
                                popupProps: PopupProps.menu(
                                  
                                  showSearchBox: true,
                                    fit: FlexFit.loose, constraints: BoxConstraints()),
                              ),
                            ],
                          ),
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
