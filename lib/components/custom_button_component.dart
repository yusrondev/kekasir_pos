import 'package:flutter/material.dart';
import 'package:kekasir/utils/colors.dart';

class ButtonPrimary extends StatelessWidget {

  final VoidCallback? onPressed;

  final String? text;

  const ButtonPrimary({
    super.key,
    this.text, 
    this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed, // Gunakan fungsi yang diberikan dari luar
      style: OutlinedButton.styleFrom(
        backgroundColor: primaryColor, // Warna background
        side: BorderSide(color: primaryColor, width: 1), // Warna & ketebalan garis
        foregroundColor: Colors.white, // Warna teks & ikon
        padding: EdgeInsets.symmetric(vertical: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Atur border radius di sini
        ),
      ),
      child: Text(text ?? "", style: TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontFamily: 'Lexend',
        fontWeight: FontWeight.w600
      )),
    );
  }
}

class ButtonPrimaryOutline extends StatelessWidget {

  final String? text;

  final VoidCallback? onPressed;

  const ButtonPrimaryOutline({super.key, this.onPressed, this.text});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: primaryColor, width: 1), // Warna & ketebalan garis
        foregroundColor: primaryColor, // Warna teks & ikon
        padding: EdgeInsets.symmetric(vertical: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Atur border radius di sini
        ),
      ),
      onPressed: onPressed,
      child: Text(text ?? "", style: TextStyle(
          color: Color(0xff3554C1),
          fontSize: 15,
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w600
        )
      ),
    );
  }
}

class ButtonSecondary extends StatelessWidget {

  final VoidCallback? onPressed;

  final String? text;

  const ButtonSecondary({
    super.key,
    this.text, 
    this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed, // Gunakan fungsi yang diberikan dari luar
      style: OutlinedButton.styleFrom(
        backgroundColor: Color(0xffced6e0), // Warna background
        side: BorderSide(color: Color(0xffced6e0), width: 1), // Warna & ketebalan garis
        foregroundColor: Color(0xff2f3542), // Warna teks & ikon
        padding: EdgeInsets.symmetric(vertical: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Atur border radius di sini
        ),
      ),
      child: Text(text ?? "", style: TextStyle(
        color: Color(0xff2f3542),
        fontSize: 15,
        fontFamily: 'Lexend',
        fontWeight: FontWeight.w600
      )),
    );
  }
}


class ButtonSecondaryOutline extends StatelessWidget {

  final String? text;

  const ButtonSecondaryOutline({
    super.key,
    this.text
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xffced6e0)),
        borderRadius: BorderRadius.circular(10)
      ),
      child: Center(
        child: Text(text ?? "", style: TextStyle(
          color: Color(0xff747d8c),
          fontSize: 17,
          fontFamily: 'Lexend'
        ),),
      ),
    );
  }
}

class ButtonDangerOutline extends StatelessWidget {

  final String? text;

  final VoidCallback? onPressed;

  const ButtonDangerOutline({super.key, this.onPressed, this.text});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: red, width: 1), // Warna & ketebalan garis
        foregroundColor: red, // Warna teks & ikon
        padding: EdgeInsets.symmetric(vertical: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Atur border radius di sini
        ),
      ),
      onPressed: onPressed,
      child: Text(text ?? "", style: TextStyle(
          color: red,
          fontSize: 15,
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w600
        )
      ),
    );
  }
}