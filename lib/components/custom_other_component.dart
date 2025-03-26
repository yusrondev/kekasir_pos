import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/utils/colors.dart';

class LineSM extends StatelessWidget {
  const LineSM({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Gap(7),
        Container(
          height: 1,
          width: double.infinity,
          color: Color(0xffdfe4ea),
        ),
        Gap(7),
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
        Gap(7),
        Container(
          height: 2,
          width: double.infinity,
          color: Color(0xffdfe4ea),
        ),
        Gap(7),
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
          color: widget.availableStock > 5 ?bgSuccess : widget.availableStock.toString() == "0" ? Color(0xffe74c3c) : dangerColor,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(5),
            topRight: Radius.circular(5),
          )
        ),
        child: Text(
          widget.availableStock.toString() == "0" ? "Produk habis" : 'Tersisa ${widget.availableStock.toString()} pcs',
          style: TextStyle(
            color: widget.availableStock > 5 ? successColor : Colors.white,
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
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: widget.availableStock > 5 ?bgSuccess : widget.availableStock.toString() == "0" ? Color(0xffe74c3c) : dangerColor,
          borderRadius: BorderRadius.circular(5)
        ),
        child: Text(
          widget.availableStock.toString() == "0" ? "Produk habis" : 'Tersisa ${widget.availableStock.toString()} pcs',
          style: TextStyle(
            color: widget.availableStock > 5 ? successColor : Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600
          ),
        ),
      ),
    );
  }
}