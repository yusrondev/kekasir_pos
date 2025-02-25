import 'package:flutter/material.dart';

class MutationTransactionPage extends StatefulWidget {
  const MutationTransactionPage({super.key});

  @override
  State<MutationTransactionPage> createState() =>
      _MutationTransactionPageState();
}

class _MutationTransactionPageState extends State<MutationTransactionPage> {
  ScrollController _scrollController = ScrollController();
  Color _appBarColor = Colors.white; // Warna default AppBar

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 20) {
      // Jika scroll lebih dari 50, ubah warna AppBar
      setState(() {
        _appBarColor = Colors.white;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Colors.grey[200],
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.black)),
                  ),
                  children: [
                    tableCell('ID', isHeader: true),
                    tableCell('Nama', isHeader: true),
                    tableCell('Usia', isHeader: true),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController, // Tambahkan controller
              scrollDirection: Axis.vertical,
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(1),
                },
                children: List.generate(
                  20,
                  (index) => TableRow(
                    children: [
                      tableCell('${index + 1}'),
                      tableCell('Nama ${index + 1}'),
                      tableCell('${20 + index}'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget tableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
