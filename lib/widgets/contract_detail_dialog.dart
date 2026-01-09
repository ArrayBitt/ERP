import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../states/saverush.dart';
import '../states/show_contract.dart';

class ContractDetailDialog extends StatelessWidget {
  final dynamic contract;
  final String username;
  final Map<String, dynamic> balance;
  final int employeesId; // <-- เพิ่มตรงนี้
  final String employeesRecordId; // <-- เพิ่มตรงนี้

  const ContractDetailDialog({
    super.key,
    required this.contract,
    required this.username,
    required this.balance,
    required this.employeesId, // <-- เพิ่มตรงนี้
    required this.employeesRecordId, // <-- เพิ่มตรงนี้
  });

  Widget _buildDetailRow(String title, dynamic value) {
    final display = value?.toString() ?? 'ไม่ระบุ';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: GoogleFonts.prompt(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(display, style: GoogleFonts.prompt(), softWrap: true),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.grey[50],
      insetPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
      title: Center(
        child: Text(
          '📄 รายละเอียดสัญญา',
          style: GoogleFonts.prompt(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.teal[800],
          ),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('id', contract['contractid']),
            _buildDetailRow('id-user', employeesId), // <-- ใช้ employeesId
            _buildDetailRow('เลขที่สัญญา', contract['contractno']),
            _buildDetailRow('รหัสผู้ติดตาม', contract['username']),
            _buildDetailRow('วันที่ทำสัญญา', contract['contractdate']),
            _buildDetailRow('วันที่จ่ายงาน', contract['tranferdate']),
            _buildDetailRow('ยอดชำระ', contract['hpprice']),
            _buildDetailRow('หมายเหตุ', contract['followremark']),
            _buildDetailRow('เบอร์มือถือ', contract['mobileno']),
            _buildDetailRow('ที่อยู่', contract['addressis']),
            const Divider(),
            _buildDetailRow('เบี้ยปรับ', balance['intbalance'] ?? 0),
            _buildDetailRow('ค่าทวงถาม', balance['free'] ?? 0),
            _buildDetailRow('ยอดค้างทั้งหมด', balance['all_balance'] ?? 0),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        ElevatedButton.icon(
          icon: const Icon(Icons.assignment),
          label: const Text('ระบบจัดเก็บเร่งรัด'),
          onPressed: () {
            if (employeesId <= 0 || employeesRecordId.isEmpty) {
              // ❌ ป้องกันไม่ให้ส่งค่าไม่ถูกต้อง
              showDialog(
                context: context,
                builder:
                    (_) => const AlertDialog(
                      title: Text('ข้อมูลพนักงานไม่ถูกต้อง'),
                      content: Text('กรุณา logout แล้วเข้าใหม่'),
                    ),
              );
              return;
            }

            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => SaveRushPage(
                      contractNo: contract['contractno']?.toString() ?? '',
                      hpprice: contract['hpprice']?.toString() ?? '',
                      username: contract['username']?.toString() ?? '',
                      hpIntAmount: contract['hp_intamount']?.toString() ?? '',
                      aMount408: contract['amount408']?.toString() ?? '',
                      aRname: contract['arname']?.toString() ?? '',
                      tranferdate: contract['tranferdate']?.toString() ?? '',
                      estmdate: contract['estm_date']?.toString() ?? '',
                      videoFilenames: [],
                      hp_overdueamt:
                          contract['hp_overdueamt']?.toString() ?? '',
                      seqno: contract['seqno']?.toString() ?? '',
                      follow400: contract['follow400']?.toString() ?? '',
                      contractId: contract['contractid']?.toString() ?? '',
                      followCount: '',
                      employeesId: employeesId,
                      employeesRecordId: employeesRecordId,
                      followup_id: contract['followup_id']?.toString() ?? '',
                      checkrush: contract['checkrush']?.toString() ?? '',
                    ),
              ),
            );
          },
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.info_outline),
          label: const Text('รายละเอียดสัญญา'),
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => ShowContractPage(
                      contractNo: contract['contractno'] ?? '',
                      contractId: contract['contractid'] ?? '',
                      username: username,
                    ),
              ),
            );
          },
        ),
      ],
    );
  }
}
