import 'package:flutter/material.dart';

class Label extends StatelessWidget {
  final String? text;
  const Label({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? "",
      maxLines: 1,
      style: TextStyle(
        fontSize: 14,
        overflow: TextOverflow.ellipsis
      ),
    );
  }
}

class LabelSemiBold extends StatelessWidget {
  final String? text;
  const LabelSemiBold({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? "",
      maxLines: 1,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        overflow: TextOverflow.ellipsis
      ),
    );
  }
}

class PageTitle extends StatelessWidget {
  final String? text;
  final bool back;
  const PageTitle({
    super.key, 
    this.text, 
    this.back = false
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if(back == true) ... [
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back_ios, size: 18)
          ),
        ],
        Text(
          text ?? "",
          maxLines: 1,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600
          ),
        ),
      ],
    );
  }
}

class ProductName extends StatelessWidget {
  final String? text;
  const ProductName({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? "",
      maxLines: 1,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        overflow: TextOverflow.ellipsis
      ),
    );
  }
}

class ShortDesc extends StatelessWidget {
  final String? text;
  const ShortDesc({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? "",
      maxLines: 1,
      style: TextStyle(
        fontSize: 13,
        color: Color(0xff747d8c),
        overflow: TextOverflow.ellipsis
      ),
    );
  }
}