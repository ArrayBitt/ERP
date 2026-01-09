import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CarInfoSection extends StatelessWidget {
  final String? selectedCarType;
  final String? selectedCarDetail;
  final bool isOtherCarDetail;
  final TextEditingController otherCarDetailController;
  final Function(String?) onCarTypeChanged;
  final Function(String?) onCarDetailChanged;

  const CarInfoSection({
    super.key,
    required this.selectedCarType,
    required this.selectedCarDetail,
    required this.isOtherCarDetail,
    required this.otherCarDetailController,
    required this.onCarTypeChanged,
    required this.onCarDetailChanged,
  });

  @override
  Widget build(BuildContext context) {
    final yellow = Colors.amber.shade700;
    final datacarTypes = ['พบรถ', 'ไม่พบรถ'];
    final foundCarDetails = [
      'สภาพดี',
      'รถพังเสียหาย',
      'รถดัดแปลง',
      'จอดทิ้งไว้ไม่ได้ใช้งาน',
      'อื่นๆ',
    ];
    final notFoundCarDetails = [
      'รถใช้งานนอกสถานที่',
      'รถใช้ในพื้นที่ แต่ไม่พบ',
      'จำนำหรือขาย',
      'ไม่ให้ข้อมูล',
      'อื่นๆ',
    ];

    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: selectedCarType,
          items:
              datacarTypes
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
          onChanged: onCarTypeChanged,
          decoration: InputDecoration(
            labelText: 'ข้อมูลรถ',
            labelStyle: GoogleFonts.prompt(color: yellow),
            prefixIcon: Icon(Icons.car_crash, color: yellow),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: yellow, width: 1.5),
            ),
          ),
        ),
        if (selectedCarType == 'พบรถ' || selectedCarType == 'ไม่พบรถ')
          SizedBox(height: 12),
        if (selectedCarType == 'พบรถ' || selectedCarType == 'ไม่พบรถ')
          DropdownButtonFormField<String>(
            value: selectedCarDetail,
            items:
                (selectedCarType == 'พบรถ'
                        ? foundCarDetails
                        : notFoundCarDetails)
                    .map(
                      (detail) =>
                          DropdownMenuItem(value: detail, child: Text(detail)),
                    )
                    .toList(),
            onChanged: onCarDetailChanged,
            decoration: InputDecoration(
              labelText:
                  selectedCarType == 'พบรถ'
                      ? 'รายละเอียดรถที่พบ'
                      : 'สาเหตุที่ไม่พบรถ',
              prefixIcon: Icon(Icons.info_outline, color: yellow),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        if (isOtherCarDetail) SizedBox(height: 12),
        if (isOtherCarDetail)
          TextFormField(
            controller: otherCarDetailController,
            decoration: InputDecoration(
              labelText: 'กรุณาระบุรายละเอียด',
              prefixIcon: Icon(Icons.edit, color: yellow),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
      ],
    );
  }
}
