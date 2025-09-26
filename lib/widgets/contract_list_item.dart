import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

String safeString(dynamic value) {
  if (value == null) return '-';
  if (value is String) return value;
  if (value is int || value is double) return value.toString();
  return '-';
}


class ContractListItem extends StatelessWidget {
  final dynamic contract;
  final Function(String) onPhoneCall;
  final VoidCallback onShowDetail;

  const ContractListItem({
    Key? key,
    required this.contract,
    required this.onPhoneCall,
    required this.onShowDetail,
  }) : super(key: key); // ✅ ต้องมี super.key ด้วย

  String formatToDDMMYYYYThai(String? input) {
    if (input == null || input.length != 8) return 'ไม่ระบุ';
    try {
      String day = input.substring(6, 8);
      String month = input.substring(4, 6);
      String year = input.substring(0, 4);
      return '$day-$month-$year';
    } catch (e) {
      return 'ไม่ระบุ';
    }
  }

  Widget buildInfoBox(String label, dynamic value, {bool highlight = false}) {
    String displayValue = value == null ? '-' : value.toString();

    return Container(
      width: 150,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: highlight ? Colors.red.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.prompt(fontSize: 12, color: Colors.grey[600]),
          ),
          SizedBox(height: 4),
          Text(
            displayValue,
            style: GoogleFonts.prompt(
              fontSize: 14,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              color: highlight ? Colors.redAccent : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: GoogleFonts.prompt(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[700],
                ),
                children: [
                  TextSpan(
                    text: 'เลขที่สัญญา: ${contract['contractno'] ?? ''} ',
                  ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 2),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 5),
           Wrap(
              spacing: 5,
              runSpacing: 5,
              children: [
                buildInfoBox('id', safeString(contract['contractid'])),
                buildInfoBox('iduser', safeString(contract['employees_record_id'])),
                buildInfoBox('ชื่อลูกค้า', safeString(contract['arname'])),
                buildInfoBox(
                  'วันที่ทำสัญญา',
                  formatToDDMMYYYYThai(safeString(contract['contractdate'])),
                ),
                buildInfoBox('เบอร์โทร', safeString(contract['mobileno'])),
                buildInfoBox('หมายเหตุ', safeString(contract['followremark'])),
                buildInfoBox('ที่อยู่', safeString(contract['addressis'])),
                buildInfoBox(
                  'วันที่จ่ายงาน',
                  formatToDDMMYYYYThai(safeString(contract['tranferdate'])),
                ),
                buildInfoBox('เวลาจ่ายงาน', safeString(contract['estm_date'])),
                buildInfoBox('ค่าติดตาม', safeString(contract['follow400'])),
                buildInfoBox('ยี่ห่อรถ', safeString(contract['brandname'])),
                buildInfoBox(
                  'ยอดค้างชำระ',
                  safeString(contract['hpprice']),
                  highlight: true,
                ),
              ],
            ),

            SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 400;
                final buttonWidth =
                    isNarrow ? (constraints.maxWidth / 2) - 20 : 150.0;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (contract['mobileno'] != null &&
                        contract['mobileno'].toString().trim().isNotEmpty)
                      SizedBox(
                        width: buttonWidth,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[400],
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: Icon(Icons.phone, size: 20),
                          label: Text(
                            'โทรออก',
                            style: GoogleFonts.prompt(fontSize: 14),
                          ),
                          onPressed: () {
                            final rawPhone = contract['mobileno'].toString();
                            final cleanedPhone = rawPhone.replaceAll(
                              RegExp(r'[^0-9+]'),
                              '',
                            );
                            if (cleanedPhone.isNotEmpty) {
                              onPhoneCall(cleanedPhone);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('ไม่พบเบอร์ในระบบ')),
                              );
                            }
                          },
                        ),
                      ),
                    if (contract['mobileno'] != null &&
                        contract['mobileno'].toString().trim().isNotEmpty)
                      SizedBox(width: 16),
                    SizedBox(
                      width: buttonWidth,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal[400],
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: Icon(Icons.description, size: 20),
                        label: Text(
                          'รายละเอียด',
                          style: GoogleFonts.prompt(fontSize: 14),
                        ),
                        onPressed: onShowDetail,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
