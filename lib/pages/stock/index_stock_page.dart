import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/apis/api_service.dart';
import 'package:kekasir/components/custom_field_component.dart';
import 'package:kekasir/components/custom_text_component.dart';
import 'package:kekasir/helpers/currency_helper.dart';
import 'package:kekasir/helpers/lottie_helper.dart';
import 'package:kekasir/models/product.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/variable.dart';

class IndexStockPage extends StatefulWidget {
  const IndexStockPage({super.key});

  @override
  State<IndexStockPage> createState() => _IndexStockPageState();
}

class _IndexStockPageState extends State<IndexStockPage> {
  ApiService apiService = ApiService();
  List<Product> products = [];
  TextEditingController keyword = TextEditingController();
  bool isLoading = true;

  @override
  void initState(){
    super.initState();
    if (mounted) {
      fetchProducts(keyword.text);

      keyword.addListener(() {
        // Jika teks berubah, panggil fetchProducts
        fetchProducts(keyword.text);
      });

    }
  }

  Future<void> fetchProducts(String keyword) async {
    final data = await ApiService().fetchProducts(keyword);
    if(mounted){
      setState(() {
        products = data;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: defaultPadding,
        children: [
          PageTitle(text: "Mutasi Stok", back: true),
          Gap(15),
          SearchTextField(placeholder: "Cari berdasarkan nama produk...", controller: keyword),
          Gap(15),
          buildListProduct(),
        ],
      ),
    );
  }

  Widget buildListProduct() {
    return isLoading ? Column(
        children: [
          Gap(100),
          CustomLoader.showCustomLoader(),
        ],
      ) : ListView.builder(
      padding: EdgeInsets.all(0),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: products.length,
      itemBuilder: (context, index){
        final product = products[index];
        return InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/stock-detail', arguments: product.id);
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(7),
            decoration: BoxDecoration(
              border: Border.all(color: secondaryColor),
              borderRadius: BorderRadius.circular(10)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(product.image, width: 80, height: 80,)
                        ),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.black.withValues(alpha: 0.5)
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Tersisa", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                              Text("${product.availableStock}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 20)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Gap(10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 150,child: LabelSemiBoldMD(text: product.name)),
                        SizedBox(width: 170,child: ShortDesc(text: product.shortDescription)),
                        SizedBox(width: 150,child: LabelSemiBold(text: formatRupiah(product.price)))
                      ],
                    )
                  ],
                ),
                
                Icon(Icons.keyboard_arrow_right)
              ],
            ),
          ),
        );
      }
    );
  }
}