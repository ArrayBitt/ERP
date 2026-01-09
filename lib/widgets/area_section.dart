import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AreaSection extends StatelessWidget {
  final String? selectedAreaType;
  final bool isOtherArea;
  final TextEditingController otherAreaController;
  final Function(String?) onChanged;

  const AreaSection({
    super.key,
    required this.selectedAreaType,
    required this.isOtherArea,
    required this.otherAreaController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final yellow = Colors.amber.shade700;
    final grey = Colors.grey.shade300;
    final List<String> areaTypes = [
      'นัดชำระ',
      'ติดตามต่อ',
      'ส่งต่อสายงานอื่น',
      'รถจำนำ/ขาย',
      'ส่งเรื่องฝ่ายกฎหมาย',
      'อื่นๆ',
    ];

    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: isOtherArea ? 'อื่นๆ' : selectedAreaType,
          items:
              areaTypes
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: 'ผลการลงพื้นที่',
            labelStyle: GoogleFonts.prompt(color: yellow),
            prefixIcon: Icon(Icons.area_chart, color: yellow),
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
        if (isOtherArea) SizedBox(height: 12),
        if (isOtherArea)
          TextFormField(
            controller: otherAreaController,
            decoration: InputDecoration(
              labelText: 'กรุณาระบุผลการลงพื้นที่',
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
