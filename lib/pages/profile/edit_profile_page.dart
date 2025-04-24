import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/apis/auth_service.dart';
import 'package:kekasir/components/custom_button_component.dart';
import 'package:kekasir/components/custom_field_component.dart';
import 'package:kekasir/components/custom_text_component.dart';
import 'package:kekasir/helpers/dialog_helper.dart';
import 'package:kekasir/helpers/lottie_helper.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/ui_helper.dart';
import 'package:kekasir/utils/variable.dart';
import 'package:logger/web.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {

  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController storeNameController = TextEditingController();

  bool isLoading = false;
  String checkOwner = '';

  @override
  void initState() {
    super.initState();
    getUserInfo();
    // Ambil dataMe dari arguments jika ada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dataMe = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      Logger().d(dataMe);

      if (dataMe != null) {
        storeNameController.text = dataMe['store']['name'];
        emailController.text = dataMe['email'];
        nameController.text = dataMe['name'];
        addressController.text = dataMe['address'] ?? "";
      }
    });
  }

  Future<void> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      checkOwner = prefs.getString("is_owner") ?? "0";
    });
  }

  bool isValidEmail(String email) {
    final RegExp regex = RegExp(r'^[a-zA-Z0-9._%+-]+@kekasir\.com$');
    return regex.hasMatch(email);
  }

  void showInputDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black54, // Agar tetap fokus ke dialog
      useSafeArea: false, // Menghindari batas layar
      builder: (context) {
        return AlertDialog(
          clipBehavior: Clip.hardEdge,
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
    setState(() {
      isLoading = false;
    });

    if (nameController.text == "") {
      alertLottie(context, 'Pastikan nama pengguna sudah terisi!', 'error');
      return;
    }

    if (nameController.text.length < 3) {
      alertLottie(context, "Nama pengguna minimal 3 karakter", "error");
      return;
    }

    if (storeNameController.text == "") {
      alertLottie(context, 'Pastikan nama toko sudah terisi!', 'error');
      return;
    }

    if (storeNameController.text.length < 3) {
      alertLottie(context, "Nama toko minimal 3 karakter", "error");
      return;
    }
    
    if (emailController.text == "") {
      alertLottie(context, 'Pastikan email sudah terisi!', 'error');
      return;
    }

    if (!isValidEmail(emailController.text)) {
      alertLottie(context, "Format email tidak valid! \n Harus menggunakan domain @kekasir.com", "error");
      return;
    }

    try {
      final result = await AuthService().updateUser(
        storeNameController.text,
        nameController.text,
        addressController.text,
        emailController.text,
        oldPasswordController.text.isNotEmpty ? oldPasswordController.text : null,
        passwordController.text.isNotEmpty ? passwordController.text : null,
      );

      if (result["success"] == true) {

        if (oldPasswordController.text.isNotEmpty) {
          Navigator.pop(context);
        }
        Navigator.pop(context, true);
        alertLottie(context, 'Berhasil memperbarui data!');
      } else {
        setState(() {
          isLoading = false;
        });
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

        alertLottie(context, errorMessage, "error");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        alertLottie(context, "Terjadi kesalahan: ${e.toString()}", "error");
      }
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
      body: isLoading ? Center(
          child: CustomLoader.showCustomLoader(),
        ) : ListView(
        padding: defaultPadding,
        children: [
          PageTitle(text: "Edit Profil", back: true,),
          Gap(15),
          CustomTextField(
            controller: nameController,
            label: "Nama Pengguna *",
            placeholder: "Misalnya Jhon...",
            maxLine: 1,
            maxLength: 100,
            border: true,
          ),
          if(checkOwner == "1")
            CustomTextField(
              controller: storeNameController,
              label: "Nama Toko *",
              placeholder: "Misalnya Toko Makmur...",
              maxLine: 1,
              maxLength: 100,
              border: true,
            ),
          if(checkOwner == "1")
            CustomTextField(
              controller: addressController,
              label: "Alamat",
              placeholder: "Misalnya Jalan Pemuda...",
              maxLine: 3,
              maxLength: 255,
              border: true,
            ),
          CustomTextField(
            controller: emailController,
            label: "Email",
            shortDescription: "Harus menggunakan domain @kekasir.com",
            placeholder: "Misalnya kekasir@gmail.com...",
            border: true,
            maxLine: 1,
          ),
          PasswordTextField(
            shortDescription: "Isi jika Anda ingin merubah password untuk akun ini",
            controller: passwordController,
            label: "Ubah Password",
            placeholder: "Password baru...",
            border: true,
          )
        ],
      ),
      bottomNavigationBar: isLoading
      ? null
      : Padding(
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          child: ButtonPrimary(
            onPressed: () {
              if (passwordController.text != "") {
                if (passwordController.text.length < 6) {
                  alertLottie(context, "Jumlah password minimal 6 karakter", "error");
                  return;
                }
                showInputDialog();
              } else {
                DialogHelper.showCreateConfirmation(context: context, onConfirm: () {
                  setState(() {
                    isLoading = true;
                  });
                  updateUser();
                });
              }
            },
            text: "Simpan",
          ),
        ),
    );
  }
}