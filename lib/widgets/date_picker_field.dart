import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DatePickerField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback onTap;

  const DatePickerField({
    Key? key,
    required this.label,
    required this.controller,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        style: GoogleFonts.prompt(),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color:
                controller.text.isEmpty
                    ? const Color.fromARGB(255, 15, 15, 15)
                    : Colors.orange,
          ),
          prefixIcon: Icon(
            Icons.calendar_today,
            color: controller.text.isEmpty ? Colors.orange : Colors.orange,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300, width: 2.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.orange, width: 2.0),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'กรุณาเลือก $label';
          }
          return null;
        },
      ),
    );
  }
}
