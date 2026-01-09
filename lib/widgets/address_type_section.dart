import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddressTypeSection extends StatelessWidget {
  final String? selectedAddressType;
  final bool isOtherAddress;
  final TextEditingController otherAddressController;
  final Function(String?) onChanged;

  const AddressTypeSection({
    super.key,
    required this.selectedAddressType,
    required this.isOtherAddress,
    required this.otherAddressController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final yellow = Colors.amber.shade700;
    final grey = Colors.grey.shade300;
    List<String> addressTypes = [
      'ที่อยู่ปัจจุบัน',
      'ที่อยู่ตามทะเบียนราฎ',
      'ที่ทำงาน',
      'ที่อยู่พ่อ/แม่',
      'ที่อยู่ใหม่จากการสืบทราบ',
      'อื่นๆ',
    ];

    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: isOtherAddress ? 'อื่นๆ' : selectedAddressType,
          items:
              addressTypes
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: 'ที่อยู่ติดตาม',
            labelStyle: GoogleFonts.prompt(color: yellow),
            prefixIcon: Icon(Icons.add_reaction_sharp, color: yellow),
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
        if (isOtherAddress) SizedBox(height: 12),
        if (isOtherAddress)
          TextFormField(
            controller: otherAddressController,
            decoration: InputDecoration(
              labelText: 'กรุณาระบุที่อยู่ติดตาม',
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
