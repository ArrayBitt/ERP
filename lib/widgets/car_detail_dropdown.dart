import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CarDetailDropdown extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<String> carTypes;
  final String? selectedCarType;
  final String? selectedCarDetail;
  final bool isOtherDetail;
  final TextEditingController otherDetailController;
  final ValueChanged<String?> onCarTypeChanged;
  final ValueChanged<String?> onCarDetailChanged;
  final String? Function(String?)? validator;

  const CarDetailDropdown({
    Key? key,
    required this.label,
    required this.icon,
    required this.carTypes,
    required this.selectedCarType,
    required this.selectedCarDetail,
    required this.isOtherDetail,
    required this.otherDetailController,
    required this.onCarTypeChanged,
    required this.onCarDetailChanged,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: selectedCarType,
          items:
              carTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
          onChanged: onCarTypeChanged,
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
        if (isOtherDetail) ...[
          SizedBox(height: 12),
          TextFormField(
            controller: otherDetailController,
            decoration: InputDecoration(
              labelText: 'กรุณาระบุรายละเอียด',
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
            onChanged: onCarDetailChanged,
            validator: validator,
          ),
        ],
      ],
    );
  }
}
