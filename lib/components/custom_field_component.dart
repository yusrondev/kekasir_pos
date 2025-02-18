import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

// TextField biasa
class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? placeholder;
  final String? shortDescription;
  final int? maxLength;
  final int? maxLine;

  const CustomTextField({
    super.key,
    this.label,
    this.maxLength,
    this.shortDescription,
    this.controller,
    this.placeholder,
    this.maxLine,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(label != null) ... [
          Text(label ?? "", style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14
          )),
        ],
        if(shortDescription != null) ... [
          Text(shortDescription ?? "", style: TextStyle(
            fontSize: 12,
            color: Color(0xff747d8c)
          ),),
        ],
        Gap(5),
        Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white
        ),
        child: TextField(
          cursorColor: Color(0xffB1B9C3),
          maxLength: maxLength,
          maxLines: maxLine,
          controller: controller,
          decoration: InputDecoration(
            counterText: "",
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            hintText: placeholder ?? "Masukkan teks",
            hintStyle: TextStyle(
              color: Color(0xffB1B9C3), 
              fontSize: 14
              )
            ),
          )
        ),
        Gap(10),
      ],
    );
  }
}

class CustomTextFieldNumber extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? placeholder;
  final String? shortDescription;
  final int? maxLength;
  final int? maxLine;

  const CustomTextFieldNumber({
    super.key,
    this.label,
    this.maxLength,
    this.shortDescription,
    this.controller,
    this.placeholder,
    this.maxLine,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(label != null) ... [
          Text(label ?? "", style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14
          )),
        ],
        if(shortDescription != null) ... [
          Text(shortDescription ?? "", style: TextStyle(
            fontSize: 12,
            color: Color(0xff747d8c)
          ),),
        ],
        Gap(5),
        Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white
        ),
        child: TextField(
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(14),
          ], 
          cursorColor: Color(0xffB1B9C3),
          maxLength: maxLength,
          maxLines: maxLine,
          controller: controller,
          decoration: InputDecoration(
            counterText: "",
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            hintText: placeholder ?? "Masukkan teks",
            hintStyle: TextStyle(
              color: Color(0xffB1B9C3), 
              fontSize: 14
              )
            ),
          )
        ),
        Gap(10),
      ],
    );
  }
}

class PriceField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? placeholder;
  final String? shortDescription;
  final int? maxLength;
  final int? maxLine;
  final Function(String)? onChanged;

  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  PriceField({
    super.key,
    this.label,
    this.maxLength,
    this.shortDescription,
    this.controller,
    this.placeholder,
    this.maxLine,
    this.onChanged,
  });

  String _formatCurrency(String value) {
    if (value.isEmpty) return '';
    final number = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return _currencyFormat.format(number);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(label != null) ... [
          Text(label ?? "", style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14
          )),
        ],
        if(shortDescription != null) ... [
          Text(shortDescription ?? "", style: TextStyle(
            fontSize: 12,
            color: Color(0xff747d8c)
          ),),
        ],
        Gap(5),
        Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white
        ),
        child: TextField(
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(8),
          ], 
          cursorColor: Color(0xffB1B9C3),
          maxLength: maxLength,
          maxLines: maxLine,
          controller: controller,
          decoration: InputDecoration(
            counterText: "",
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            hintText: placeholder ?? "Masukkan teks",
            hintStyle: TextStyle(
              color: Color(0xffB1B9C3), 
              fontSize: 14
              )
            ),
            onChanged: (value) {
              final formatted = _formatCurrency(value);
              controller!.value = TextEditingValue(
                text: formatted,
                selection: TextSelection.collapsed(offset: formatted.length),
              );
            },
          )
        ),
        Gap(10),
      ],
    );
  }
}

// TextField untuk password (dengan ikon visibility)
class PasswordTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? placeholder;
  final String? shortDescription;
  final int? maxLength;
  final int? maxLine;

  const PasswordTextField({
    super.key,
    this.controller,
    this.placeholder, 
    this.label, 
    this.shortDescription, 
    this.maxLength, 
    this.maxLine,
  });

  @override
  _PasswordTextFieldState createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(widget.label != null) ... [
          Text(widget.label ?? "", style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14
          )),
        ],
        if(widget.shortDescription != null) ... [
          Text(widget.shortDescription ?? "", style: TextStyle(
            fontSize: 12,
            color: Color(0xff747d8c)
          )),
        ],
        Gap(5),
        Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white
        ),
        child: TextField(
          cursorColor: Color(0xffB1B9C3),
          obscureText: _obscureText,
          maxLength: widget.maxLength,
          controller: widget.controller,
          decoration: InputDecoration(
            counterText: "",
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            hintText: widget.placeholder ?? "Masukkan teks",
            suffixIcon: IconButton(
              icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, size: 20, color: Color(0xff747d8c)),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
            hintStyle: TextStyle(
              color: Color(0xffB1B9C3), 
              fontSize: 14
              )
            ),
          )
        ),
        Gap(10),
      ],
    );
  }
}

// TextField untuk pencarian dengan ikon search
class SearchTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? placeholder;

  const SearchTextField({
    super.key,
    this.controller,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10)
      ),
      child: TextField(
        cursorColor: Color(0xffB1B9C3),
        controller: controller,
        style: TextStyle(
          fontSize: 14
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: placeholder ?? 'Cari sesuatu...',
          contentPadding: EdgeInsets.symmetric(vertical: 15),
          prefixIcon: Icon(Icons.search, size: 20, color: Color(0xffB1B9C3)),
          hintStyle: TextStyle(
            color: Color(0xffB1B9C3), 
            fontSize: 14
            )
          ),
        ),
    );
  }
}

class CustomDropdownField extends StatelessWidget {
  final String? label;
  final List<String> items;
  final String? selectedValue;
  final ValueChanged<String?>? onChanged;
  final String? hint;
  final String? shortDescription;

  const CustomDropdownField({
    super.key,
    this.label,
    required this.items,
    this.selectedValue,
    this.onChanged,
    this.hint, 
    this.shortDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, 
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15
            )),
        ],
        if(shortDescription != null) ... [
          Text(shortDescription ?? "", style: TextStyle(
            fontSize: 12,
            color: Color(0xff747d8c)
          )),
        ],
        Gap(5),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10)
          ),
          child: DropdownButtonFormField<String>(
            value: selectedValue,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            hint: Text(hint ?? "Pilih opsi"),
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
        Gap(10),
      ],
    );
  }
}

class ThousandsFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat("#,###", "id_ID");

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.replaceAll('.', '').replaceAll(',', '');

    if (text.isEmpty) return newValue;

    String formattedText = _formatter.format(int.parse(text));

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}