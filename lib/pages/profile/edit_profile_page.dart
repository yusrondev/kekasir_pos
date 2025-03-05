import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/apis/auth_service.dart';
import 'package:kekasir/components/custom_button_component.dart';
import 'package:kekasir/components/custom_field_component.dart';
import 'package:kekasir/components/custom_text_component.dart';
import 'package:kekasir/helpers/snackbar_helper.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/variable.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {

  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController oldPasswordController = TextEditingController();

  void showInputDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black54, // Agar tetap fokus ke dialog
      useSafeArea: false, // Menghindari batas layar
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabelSemiBold(
                text: "Masukkan Password Sebelumnya",
              ),
              Gap(10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: secondaryColor),
                ),
                child: TextField(
                  controller: oldPasswordController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: InputBorder.none,
                  ),
                ),
              ),
              Gap(10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: ButtonPrimaryOutline(
                        text: "Batal",
                      ),
                    )
                  ),
                  Gap(5),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => updateUser(),
                      child: ButtonPrimary(
                        text: "Simpan",
                      ),
                    )
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> updateUser() async {
    try {
      final result = await AuthService().updateUser(
        nameController.text,
        emailController.text,
        oldPasswordController.text.isNotEmpty ? oldPasswordController.text : null,
        passwordController.text.isNotEmpty ? passwordController.text : null,
      );

      if (result["success"] == true) {

        if (oldPasswordController.text.isNotEmpty) {
          Navigator.pop(context);
        }
        
        showSuccessSnackbar(context, result["message"]); 
        Navigator.pop(context, true);

      } else {
        // Ambil pesan error
        String errorMessage = result["message"];

        // Cek apakah ada detail error di dalam "errors"
        if (result.containsKey("errors")) {
          Map<String, dynamic> errors = result["errors"];
          List<String> errorList = [];

          // Loop melalui setiap field error
          errors.forEach((key, value) {
            if (value is List) {
              errorList.addAll(value.map((e) => "$e")); // Format field: pesan error
            } else {
              errorList.add("$key: $value");
            }
          });

          // Gabungkan semua error menjadi satu string
          errorMessage = errorList.join("\n");
        }

        showErrorSnackbar(context, errorMessage);
      }
    } catch (e) {
      showErrorSnackbar(context, "Terjadi kesalahan: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {

    final dataMe = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    setState(() {
      emailController.text = dataMe!['email'];
      nameController.text = dataMe['name'];
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: defaultPadding,
        children: [
          PageTitle(text: "Edit Profil", back: true,),
          Gap(15),
          CustomTextField(
            controller: nameController,
            label: "Nama",
            placeholder: "Misalnya kekasir...",
            maxLine: 1,
            border: true,
          ),
          CustomTextField(
            controller: emailController,
            label: "Email",
            placeholder: "Misalnya kekasir@gmail.com...",
            border: true,
            maxLine: 1,
          ),
          PasswordTextField(
            shortDescription: "Isi jika Anda ingin merubah password untuk akun ini",
            controller: passwordController,
            label: "Password",
            placeholder: "******",
            border: true,
          )
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        child: GestureDetector(
          onTap: () {
            if (passwordController.text != "") {
              showInputDialog();
            }else{
              updateUser();
            }
          },
          child: ButtonPrimary(
            text: "Simpan",
          ),
        ),
      ),
    );
  }
}