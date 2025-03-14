import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:kekasir/utils/colors.dart';

// TextField biasa
class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? placeholder;
  final String? shortDescription;
  final int? maxLength;
  final int? maxLine;
  final bool border;

  const CustomTextField({
    super.key,
    this.label,
    this.maxLength,
    this.shortDescription,
    this.controller,
    this.placeholder,
    this.maxLine,
    this.border = false
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
          color: Colors.white,
          border: Border.all(
            color: border == true ? secondaryColor : Colors.transparent,
          ),
        ),
        child: TextField(
          cursorColor: primaryColor,
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
  final bool? border;

  const CustomTextFieldNumber({
    super.key,
    this.label,
    this.maxLength,
    this.shortDescription,
    this.controller,
    this.placeholder,
    this.maxLine,
    this.border = false
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
          color: Colors.white,
          border: Border.all(
            color: border == true ? secondaryColor : Colors.transparent,
          ),
        ),
        child: TextField(
          cursorColor: primaryColor,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(14),
          ], 
          maxLength: maxLength,
          maxLines: maxLine,
          controller: controller,
          decoration: InputDecoration(
            counterText: "",
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            hintText: placeholder ?? "Masukkan nominal",
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
  final bool border;

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
    this.border = false
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
          color: Colors.white,
          border: Border.all(
            color: border == true ? secondaryColor : Colors.transparent,
          ),
        ),
        child: TextField(
          cursorColor: primaryColor,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(8),
          ], 
          maxLength: maxLength,
          maxLines: maxLine,
          controller: controller,
          decoration: InputDecoration(
            counterText: "",
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            hintText: placeholder ?? "Masukkan nominal",
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
  final bool border;

  const PasswordTextField({
    super.key,
    this.controller,
    this.placeholder, 
    this.label, 
    this.shortDescription, 
    this.maxLength, 
    this.maxLine,
    this.border = false
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
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
          color: Colors.white,
          border: Border.all(
            color: widget.border == true ? secondaryColor : Colors.transparent,
          ),
        ),
        child: TextField(
          cursorColor: primaryColor,
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
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: secondaryColor)
      ),
      child: TextField(
        cursorColor: primaryColor,
        controller: controller,
        style: TextStyle(
          fontSize: 15
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: placeholder ?? 'Cari sesuatu...',
          contentPadding: EdgeInsets.symmetric(vertical: 15),
          prefixIcon: Icon(Icons.search, size: 23, color: Color(0xffB1B9C3)),
          hintStyle: TextStyle(
            color: Color(0xffB1B9C3), 
            fontSize: 15
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
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: secondaryColor)
          ),
          child: DropdownButtonFormField<String>(
            dropdownColor: Colors.white,
            value: selectedValue,
            borderRadius: BorderRadius.circular(10),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            hint: Text(hint ?? "Pilih opsi", style: TextStyle(fontWeight: FontWeight.normal),),
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: TextStyle(fontWeight: FontWeight.normal),),
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

class DatePickerField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final DateTime? minDate; // Tambahkan batas minimal tanggal

  const DatePickerField({
    super.key,
    required this.label,
    required this.controller,
    this.enabled = true,
    this.minDate, // Tambahkan parameter ini
  });

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = _getDateFromText(widget.controller.text) ?? DateTime.now();

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: widget.minDate ?? DateTime(2000), // Terapkan batasan minDate
      lastDate: DateTime(2100),
      locale: Locale('id')
    );

    if (picked != null) {
      setState(() {
        widget.controller.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  // Fungsi untuk mengonversi teks ke DateTime
  DateTime? _getDateFromText(String dateText) {
    try {
      return DateFormat('dd-MM-yyyy').parse(dateText);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: widget.enabled ? Colors.white : Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: secondaryColor)
          ),
          child: TextFormField(
            controller: widget.controller,
            decoration: InputDecoration(
              suffixIcon: Icon(Icons.calendar_today, size: 20, color: darkColor),
              hintText: "tanggal-bulan-tahun",
              hintStyle: TextStyle(fontSize: 13, color: darkColor),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            readOnly: true,
            onTap: widget.enabled ? () => _selectDate(context) : null,
          ),
        ),
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