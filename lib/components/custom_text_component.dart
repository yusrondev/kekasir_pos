import 'package:auto_size_text/auto_size_text.dart';
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
    return AutoSizeText(
      text ?? "",
      maxLines: 1,
      minFontSize: 12, // Ukuran font minimum agar tetap terbaca
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.black,
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
              // Navigator.pop(context, true);
              Navigator.pop(context);
            },
            child: Container(
              margin: EdgeInsets.only(right: 15),
              width: 35,
              height: 35,
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Color(0xfff5f6fa),
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
    return AutoSizeText(
      text ?? "",
      maxLines: 2, // Bisa dua baris
      minFontSize: 8,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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

class PriceTag extends StatefulWidget {
  final String? text;
  final bool? haveType;

  const PriceTag({super.key, this.text, this.haveType});

  @override
  State<PriceTag> createState() => _PriceTagState();
}

class _PriceTagState extends State<PriceTag> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.haveType == true
        ? AnimatedBuilder(
            animation: _opacityAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: _buildContainer(),
              );
            },
          )
        : _buildContainer();
  }

  Widget _buildContainer() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: widget.haveType == true ? const Color(0xfff9ca24) : bgSuccess,
        borderRadius: BorderRadius.circular(5),
      ),
      child: AutoSizeText(
        widget.text ?? "",
        maxLines: 1,
        minFontSize: 10, // Ukuran minimum agar tetap terbaca
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13, // Ukuran default
          fontWeight: FontWeight.w600,
          color: widget.haveType == true ? const Color(0xff130f40) : successColor,
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
        // border: Border.all(color: primaryColor, width: 0.5)
      ),
      child: AutoSizeText(
        text ?? "",
        maxLines: 1,
        minFontSize: 10, // Menyesuaikan ukuran minimal agar tetap terbaca
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13, // Ukuran default
          fontWeight: FontWeight.w600,
          color: primaryColor,
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

class WarningTag extends StatelessWidget {
  final String? text;
  const WarningTag({super.key, this.text});

  String _capitalize(String text) {
    if (text.isEmpty) return "";
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 3),
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: Color(0xfffff5e7),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        _capitalize(text!),
        maxLines: 1,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          overflow: TextOverflow.ellipsis,
          color: Color(0xff6f1f00)
        ),
      ),
    );
  }
}