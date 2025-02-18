import 'package:flutter/material.dart';

class ButtonPrimary extends StatelessWidget {

  final String? text;

  const ButtonPrimary({
    super.key,
    this.text
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Color(0xff3554C1),
        borderRadius: BorderRadius.circular(10)
      ),
      child: Center(
        child: Text(text ?? "", style: TextStyle(
          color: Colors.white,
          fontSize: 17
        ),),
      ),
    );
  }
}

class ButtonPrimaryOutline extends StatelessWidget {

  final String? text;

  const ButtonPrimaryOutline({
    super.key,
    this.text
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xff3554C1)),
        borderRadius: BorderRadius.circular(10)
      ),
      child: Center(
        child: Text(text ?? "", style: TextStyle(
          color: Color(0xff3554C1),
          fontSize: 17
        ),),
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
          fontSize: 17
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
          fontSize: 17
        ),),
      ),
    );
  }
}