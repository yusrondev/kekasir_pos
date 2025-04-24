import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/apis/api_service_employee.dart';
import 'package:kekasir/components/custom_text_component.dart';
import 'package:kekasir/helpers/dialog_expired.dart';
import 'package:kekasir/helpers/dialog_helper.dart';
import 'package:kekasir/helpers/lottie_helper.dart';
import 'package:kekasir/models/employee.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/ui_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

class IndexEmployeePage extends StatefulWidget {
  const IndexEmployeePage({super.key});

  @override
  State<IndexEmployeePage> createState() => _IndexEmployeePageState();
}

class _IndexEmployeePageState extends State<IndexEmployeePage> {
  ApiServiceEmployee apiServiceEmployee = ApiServiceEmployee();
  List<Employee> employees = [];

  final GlobalKey one = GlobalKey();

  bool isLoad = true;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      fetchEmployee();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkShowcaseStatus();
      });
    }
  }

  void _checkShowcaseStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasShownShowcase = prefs.getBool('hasShownHomeShowcaseEmployee') ?? false;

    if (!hasShownShowcase && mounted) {
      final showcase = ShowCaseWidget.of(context);
      showcase.startShowCase([one]);
      prefs.setBool('hasShownHomeShowcaseEmployee', true);
    }
  }

  Future<void> fetchEmployee() async {
    try {
      final data = await ApiServiceEmployee().fetchEmployee();
      if(mounted){
        setState(() {
          employees = data;
          isLoad = false;
        });
      }
    } catch (e) {
      if (mounted) {
        if (e.toString().contains('expired')) {
          showNoExpiredDialog(context); // <- context hanya tersedia di layer UI
        } else {
          showErrorBottomSheet(context, e.toString());
        }
      }
    }
  }

  Future<void> delete(String id) async {
    try {
      await ApiServiceEmployee().delete(id);
      if (mounted) {
        setState(() {
          alertLottie(context, "Berhasil menghapus pegawai!");
          fetchEmployee();
        });
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
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          fetchEmployee();
        },
        color: primaryColor,
        backgroundColor: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 45, left: 14, right: 14), 
              child: Column(
                children: [
                  PageTitle(text: "Manajemen Pegawai", back: true,),
                  Gap(10),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(bottom: 45, left: 14, right: 14), 
                children: [
                  Gap(10),
                  buildListEmployee(),
                ],
              ),
            )
          ],
        )
      ),
      floatingActionButton: Showcase(
        key: one, 
        description: "Klik tombol ini untuk menambahkan pegawai baru", 
        tooltipPosition: TooltipPosition.top,
        overlayOpacity: 0.5,
        targetBorderRadius: BorderRadius.circular(15),
        child: FloatingActionButton(
          onPressed: (){
            Navigator.pushNamed(context, '/create-employee').then((value){
              if (value == true) {
                fetchEmployee();
              }
            });
          },
          mini: true,
          backgroundColor: primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
        )
      )
    );
  }
  
  Widget buildListEmployee() {
    if (isLoad == true) {
      return Column(
        children: [
          Gap(100),
          CustomLoader.showCustomLoader(),
        ],
      );
    }

    if (isLoad == false && employees.isEmpty) {
      return Column(
        children: [
          Gap(100),
          TumbleWeed.showTumbleWeed(),
          LabelSemiBold(text: "Data pegawai tidak ditemukan ..."),
        ],
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(0),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: employees.length,
      itemBuilder: (context, index){
        final employee = employees[index];

        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/edit-employee', arguments: employee).then((value){
              fetchEmployee();
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 7,horizontal: 7),
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: secondaryColor)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LabelSemiBold(text : employee.name.toString()),
                      LabelSM(text : employee.email.toString()),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    DialogHelper.customDialog(context: context, onConfirm: (){delete(employee.id.toString());}, title : "Hapus Pegawai", content: "Apakah Anda yakin ingin menghapus pegawai ${employee.name}?", actionButton: true);
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 7),
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: red,
                      border: Border.all(color: red, width: 1),
                      borderRadius: BorderRadius.circular(100)
                    ),
                    child: Icon(Icons.close, size: 15,color: Colors.white,)
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 7),
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: secondaryColor, width: 1),
                    borderRadius: BorderRadius.circular(100)
                  ),
                  child: Icon(Icons.arrow_forward_rounded, size: 15,)
                ),
              ]
            ),
          ),
        );
      }
    );
  }
}