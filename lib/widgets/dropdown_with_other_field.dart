import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DropdownWithOtherField extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<String> items;
  final String? selectedValue;
  final bool isOther;
  final TextEditingController otherController;
  final ValueChanged<String?> onChanged;
  final ValueChanged<String>? onOtherChanged;
  final String? Function(String?)? validator;

  const DropdownWithOtherField({
    Key? key,
    required this.label,
    required this.icon,
    required this.items,
    required this.selectedValue,
    required this.isOther,
    required this.otherController,
    required this.onChanged,
    this.onOtherChanged,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: isOther ? 'อื่นๆ' : selectedValue,
          items:
              items.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
          onChanged: (value) => onChanged(value),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.prompt(color: Colors.amber.shade700),
            prefixIcon: Icon(icon, color: Colors.amber.shade700),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.amber.shade700, width: 1.5),
            ),
          ),
        ),
        if (isOther) ...[
          SizedBox(height: 12),
          TextFormField(
            controller: otherController,
            decoration: InputDecoration(
              labelText: 'กรุณาระบุ$label',
              prefixIcon: Icon(Icons.edit, color: Colors.amber.shade700),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Colors.amber.shade700,
                  width: 1.5,
                ),
              ),
            ),
            onChanged: onOtherChanged,
            validator: validator,
          ),
        ],
      ],
    );
  }
}
