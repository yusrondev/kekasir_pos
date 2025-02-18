import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/utils/colors.dart';

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
          color: widget.availableStock > 5 ?bgSuccess : bgDanger,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          )
        ),
        child: Text(
          'Tersisa ${widget.availableStock.toString()}',
          style: TextStyle(
            color: widget.availableStock > 5 ? successColor : dangerColor,
            fontSize: 13,
            fontWeight: FontWeight.w600
          ),
        ),
      ),
    );
  }
}