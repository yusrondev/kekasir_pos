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

  final String? text;

  const ButtonSecondary({
    super.key,
    this.text
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Color(0xffced6e0),
        borderRadius: BorderRadius.circular(10)
      ),
      child: Center(
        child: Text(text ?? "", style: TextStyle(
          color: Color(0xff2f3542),
          fontSize: 17,
          fontFamily: 'Lexend'
        ),),
      ),
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
        side: BorderSide(color: dangerColor, width: 1), // Warna & ketebalan garis
        foregroundColor: dangerColor, // Warna teks & ikon
        padding: EdgeInsets.symmetric(vertical: 13)
      ),
      onPressed: onPressed,
      child: Text(text ?? "", style: TextStyle(
          color: dangerColor,
          fontSize: 15,
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w600
        )
      ),
    );
  }
}