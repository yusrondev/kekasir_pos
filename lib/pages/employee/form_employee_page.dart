import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/apis/api_service_employee.dart';
import 'package:kekasir/components/custom_button_component.dart';
import 'package:kekasir/components/custom_field_component.dart';
import 'package:kekasir/components/custom_text_component.dart';
import 'package:kekasir/helpers/dialog_helper.dart';
import 'package:kekasir/models/employee.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/ui_helper.dart';
import 'package:kekasir/utils/variable.dart';
import 'package:logger/web.dart';

class FormEmployeePage extends StatefulWidget {
  final Employee? employee;
  const FormEmployeePage({super.key, this.employee});

  @override
  State<FormEmployeePage> createState() => _FormEmployeePageState();
}

class _FormEmployeePageState extends State<FormEmployeePage> {
  ApiServiceEmployee apiServiceEmployee = ApiServiceEmployee();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  bool isLoading = false;
  bool _obscureText = true;
  bool isEdit = false;
  
  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      nameController.text = widget.employee!.name ?? "";
      addressController.text = widget.employee!.address ?? "";
      emailController.text = widget.employee!.email ?? "";
      setState(() {
        isEdit = true;
      });
    }
  }

  bool isValidEmail(String email) {
    final RegExp regex = RegExp(r'^[a-zA-Z0-9._%+-]+@kekasir\.com$');
    return regex.hasMatch(email);
  }

  void register() async {

    if (nameController.text == "") {
      alertLottie(context, 'Pastikan nama pengguna sudah terisi!', 'error');
      return;
    }

    if (nameController.text.length < 3) {
      alertLottie(context, "Nama pengguna minimal 3 karakter", "error");
      return;
    }

    if (emailController.text == "") {
      alertLottie(context, 'Pastikan email sudah terisi!', 'error');
      return;
    }

    if (!isValidEmail(emailController.text)) {
      setState(() {
        isLoading = false;
      });
      alertLottie(context, "Format email tidak valid! \n Harus menggunakan domain @kekasir.com", "error");
      return;
    }

    if (passwordController.text == "" && isEdit == false) {
      alertLottie(context, 'Pastikan password sudah terisi!', 'error');
      return;
    }

    if (passwordController.text.length < 6 && isEdit == false) {
      alertLottie(context, "Jumlah password minimal 6 karakter", "error");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String? error;
      if (widget.employee == null) {
        error = await ApiServiceEmployee().register(
          nameController.text,
          addressController.text,
          emailController.text,
          passwordController.text
        );
      }else{
        error = await ApiServiceEmployee().update(
          widget.employee?.id.toString(),
          nameController.text,
          addressController.text,
          emailController.text,
          passwordController.text
        );
      }

      Logger().d(error);

      if (error == null) {
        if (mounted) { // Pastikan widget masih terpasang
          setState(() {
            isLoading = false;
          });
          Navigator.pop(context, true);
          alertLottie(context, isEdit == true ? "Berhasil meperbarui pegawai!" : "Berhasil menambahkan pegawai!");
        }
      } else {
        if (mounted) { // Pastikan widget masih terpasang
          setState(() {
            isLoading = false;
          });
          // Navigator.pop(context);
          alertLottie(context, error, 'error');
        }
      }
    } catch (e) {
      Navigator.pop(context);
      // ignore: use_build_context_synchronously
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
      body: ListView(
        padding: defaultPadding,
        children: [
          PageTitle(text: widget.employee == null ? "Tambah Pegawai" : "Edit Pegawai", back: true),
          Gap(15),
          buildForm()
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        child: GestureDetector(
          onTap: () {
            DialogHelper.showCreateConfirmation(context: context, onConfirm: () => register());
          },
          child: ButtonPrimary(
            text: "Simpan",
          ),
        ),
      ),
    );
  }

   Widget buildForm(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         CustomTextField(
          controller: nameController,
          label: "Nama Pengguna*",
          placeholder: "Misalnya Jhon...",
          shortDescription: "Minimal 3 karakter",
          maxLine: 1,
          maxLength: 100,
          border: true,
        ),
        Text("Email *", style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14
        )),
        Text("Harus menggunakan domain @kekasir.com", style: TextStyle(
          fontSize: 12,
          color: Color(0xff747d8c)
        )),
        Gap(5),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            border: Border.all(color: secondaryColor)
          ),
          child: TextField(
          cursorColor: primaryColor,
          controller: emailController,
          decoration: InputDecoration(
            counterText: "",
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            hintText: "Misalnya jhon@kekasir.com...",
            hintStyle: TextStyle(
              color: Color(0xffB1B9C3), 
              fontSize: 14
              )
            ),
          )
        ),
        Gap(10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Password *", style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14
            )),
            Text("Minimal 6 karakter", style: TextStyle(
              fontSize: 12,
              color: Color(0xff747d8c)
            )),
            Gap(5),
            Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              border: Border.all(color: secondaryColor)
            ),
            child: TextField(
              controller: passwordController,
              cursorColor: primaryColor,
              obscureText: _obscureText,
              decoration: InputDecoration(
                counterText: "",
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                hintText: "******",
                suffixIcon: IconButton(
                  icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, size: 20, color: Color(0xff747d8c)),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
                hintStyle: TextStyle(
                  color: Color(0xffB1B9C3), 
                  fontSize: 14
                  )
                ),
              )
            ),
            Gap(10),
          ],
        )
      ],
    );
  }
}