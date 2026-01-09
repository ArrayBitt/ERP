import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PropertySection extends StatelessWidget {
  final String? selectedPropertyType;
  final bool isOtherProperty;
  final TextEditingController otherPropertyController;
  final Function(String?) onChanged;

  const PropertySection({
    super.key,
    required this.selectedPropertyType,
    required this.isOtherProperty,
    required this.otherPropertyController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final yellow = Colors.amber.shade700;
    final grey = Colors.grey.shade300;
    final List<String> propertyTypes = ['ไม่มีทรัพย์สิน', 'มีทรัพย์สิน'];

    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: isOtherProperty ? 'มีทรัพย์สิน' : selectedPropertyType,
          items:
              propertyTypes
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: 'ผลทรัพย์สิน',
            labelStyle: GoogleFonts.prompt(color: yellow),
            prefixIcon: Icon(Icons.money_off, color: yellow),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: yellow, width: 1.5),
            ),
          ),
        ),
        if (isOtherProperty) SizedBox(height: 12),
        if (isOtherProperty)
          TextFormField(
            controller: otherPropertyController,
            decoration: InputDecoration(
              labelText: 'กรุณาระบุทรัพย์สิน',
              prefixIcon: Icon(Icons.edit, color: yellow),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: yellow, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}
