import 'package:flutter/material.dart';
import 'package:kekasir/utils/colors.dart';

class LabelSM extends StatelessWidget {
  final String? text;
  const LabelSM({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? "",
      maxLines: 1,
      style: TextStyle(
        fontSize: 12,
        overflow: TextOverflow.ellipsis
      ),
    );
  }
}

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
  final bool primary;
  const LabelSemiBold({super.key, this.text, this.primary = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? "",
      maxLines: 1,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        overflow: TextOverflow.ellipsis,
        color: primary == true ? primaryColor : Colors.black
      ),
    );
  }
}

class LabelSemiBoldMD extends StatelessWidget {
  final String? text;
  final bool primary;
  const LabelSemiBoldMD({super.key, this.text, this.primary = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? "",
      maxLines: 1,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        overflow: TextOverflow.ellipsis,
        color: primary == true ? primaryColor : Colors.black
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
          GestureDetector(
            onTap: () {
              Navigator.pop(context, true);
            },
            child: Container(
              margin: EdgeInsets.only(right: 15),
              width: 30,
              height: 30,
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100)
              ),
              child: Container(
                margin: EdgeInsets.only(left: 5),
                child: Icon(Icons.arrow_back_ios, size: 15)
              ),
            )
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
        fontSize: 12,
        color: Color(0xff898F9F),
        overflow: TextOverflow.ellipsis
      ),
    );
  }
}

class ShortDescSM extends StatelessWidget {
  final String? text;
  final int maxline;
  const ShortDescSM({
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
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xff898F9F),
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
      margin: EdgeInsets.symmetric(vertical: 3),
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: bgSuccess,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: successColor, width: 0.5)
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
      margin: EdgeInsets.symmetric(vertical: 3),
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: lightColor,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: primaryColor, width: 0.5)
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

class DangerTag extends StatelessWidget {
  final String? text;
  const DangerTag({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 3),
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: bgDanger,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: dangerColor, width: 0.5)
      ),
      child: Text(
        text ?? "",
        maxLines: 1,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          overflow: TextOverflow.ellipsis,
          color: dangerColor
        ),
      ),
    );
  }
}