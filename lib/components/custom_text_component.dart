import 'package:flutter/material.dart';
import 'package:kekasir/utils/colors.dart';

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

class LabelSemiBoldMD extends StatelessWidget {
  final String? text;
  const LabelSemiBoldMD({super.key, this.text});

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
  final int maxline;
  const ShortDesc({
    super.key, 
    this.text,
    this.maxline = 1
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? "",
      maxLines: maxline,
      style: TextStyle(
        fontSize: 13,
        color: Color(0xff747d8c),
        overflow: TextOverflow.ellipsis
      ),
    );
  }
}

class PriceTag extends StatelessWidget {
  final String? text;
  const PriceTag({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: bgSuccess,
        borderRadius: BorderRadius.circular(5)
      ),
      child: Text(
        text ?? "",
        maxLines: 1,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          overflow: TextOverflow.ellipsis,
          color: successColor
        ),
      ),
    );
  }
}

class StockTag extends StatelessWidget {
  final String? text;
  const StockTag({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: lightColor,
        borderRadius: BorderRadius.circular(5)
      ),
      child: Text(
        text ?? "",
        maxLines: 1,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          overflow: TextOverflow.ellipsis,
          color: primaryColor
        ),
      ),
    );
  }
}