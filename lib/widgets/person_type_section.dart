import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PersonTypeSection extends StatelessWidget {
  final String? selectedPersonType;
  final bool isOtherPerson;
  final TextEditingController otherPersonController;
  final Function(String?) onChanged;

  const PersonTypeSection({
    super.key,
    required this.selectedPersonType,
    required this.isOtherPerson,
    required this.otherPersonController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final yellow = Colors.amber.shade700;
    final grey = Colors.grey.shade300;
    List<String> personTypes = [
      'ผู้เช่าซื้อ',
      'ผู้ค้ำประกัน',
      'คนใช้รถ',
      'ผู้ซื้อร่วม',
      'อื่นๆ',
    ];

    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: isOtherPerson ? 'อื่นๆ' : selectedPersonType,
          items:
              personTypes
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: 'ประเภทบุคคล',
            labelStyle: GoogleFonts.prompt(color: yellow),
            prefixIcon: Icon(Icons.person, color: yellow),
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
        if (isOtherPerson)
          TextFormField(
            controller: otherPersonController,
            decoration: InputDecoration(
              labelText: 'กรุณาระบุประเภทบุคคล',
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
