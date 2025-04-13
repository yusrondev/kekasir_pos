import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/utils/colors.dart';

class LineSM extends StatelessWidget {
  const LineSM({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Gap(5),
        Container(
          height: 1,
          width: double.infinity,
          color: Color(0xffdfe4ea),
        ),
        Gap(5),
      ],
    );
  }
}

class Line extends StatelessWidget {
  const Line({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Gap(5),
        Container(
          height: 2,
          width: double.infinity,
          color: Color(0xffdfe4ea),
        ),
        Gap(5),
      ],
    );
  }
}

class LineXM extends StatelessWidget {
  const LineXM({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Gap(10),
        Container(
          height: 1,
          width: double.infinity,
          color: Color(0xffE7E7E7),
        ),
        Gap(10),
      ],
    );
  }
}

class LinePrimary extends StatelessWidget {
  const LinePrimary({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Gap(10),
        Container(
          height: 1,
          width: double.infinity,
          color: primaryColor,
        ),
        Gap(10),
      ],
    );
  }
}

class StockBadge extends StatefulWidget {
  final int availableStock;

  const StockBadge({super.key, required this.availableStock});

  @override
  State<StockBadge> createState() => _StockBadgeState();
}

class _StockBadgeState extends State<StockBadge> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: widget.availableStock > 5 ?bgSuccess : widget.availableStock.toString() == "0" ? Color(0xfff1f2f6) : Color(0xffe74c3c),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(5),
            topRight: Radius.circular(5),
          ),
          border: Border.all(color: widget.availableStock > 5 ?bgSuccess : widget.availableStock.toString() == "0" ? secondaryColor : Color(0xffe74c3c))
        ),
        child: Text(
          widget.availableStock.toString() == "0" ? "Produk habis" : 'Tersisa ${widget.availableStock.toString()} pcs',
          style: TextStyle(
            color: widget.availableStock > 5 ? successColor : widget.availableStock == 0 ? Colors.black : Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600
          ),
        ),
      ),
    );
  }
}

class StockBadgeWithoutRadius extends StatefulWidget {
  final int availableStock;

  const StockBadgeWithoutRadius({super.key, required this.availableStock});

  @override
  State<StockBadgeWithoutRadius> createState() => _StockBadgeStateWithoutRadius();
}

class _StockBadgeStateWithoutRadius extends State<StockBadgeWithoutRadius> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        constraints: BoxConstraints(
          minWidth: 50, // Sesuaikan ukuran minimal
          maxWidth: 100, // Sesuaikan ukuran maksimal
        ),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: widget.availableStock > 5 
              ? bgSuccess 
              : widget.availableStock == 0 
                ? Color(0xfff1f2f6) 
                : Color(0xffe74c3c),
          borderRadius: BorderRadius.circular(5),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: AutoSizeText(
            widget.availableStock == 0 
                ? "Produk habis" 
                : 'Tersisa ${widget.availableStock} pcs',
            maxLines: 1,
            minFontSize: 8, // Ukuran minimal
            wrapWords: false, // Hindari pemisahan kata
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: widget.availableStock > 5 ? successColor : widget.availableStock == 0 ? Colors.black : Colors.white,
              fontSize: 13, // Ukuran default
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
