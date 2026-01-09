import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:erp/states/card_cut_page.dart';
import 'package:erp/states/contract_image.dart';
import 'package:erp/states/followContract.dart';
import 'package:erp/states/pay_as400.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ShowContractPage extends StatefulWidget {
  final String contractNo;
  final String contractId;
  final String username;

  const ShowContractPage({
    Key? key,
    required this.contractNo,
    required this.contractId, 
    required this.username,
  }) : super(key: key);

  @override
  _ShowContractPageState createState() => _ShowContractPageState();
}

class _ShowContractPageState extends State<ShowContractPage> {
  Map<String, dynamic>? contractData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  
  }


  Future<void> _openCardCutPDF() async {
    final contractId = widget.contractId;

    if (contractId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ไม่พบเลขที่สัญญา')));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';

    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่พบ token กรุณาเข้าสู่ระบบใหม่')),
      );
      return;
    }

    final url = Uri.parse(
      'https://erp.somjai.app/api/contracts/get/data/to/gen/pdf/$contractId',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/pdf',
        },
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        // ส่ง PDF bytes ไปหน้า CardCutPage
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CardCutPage(pdfBytes: bytes)),
        );
      } else if (response.statusCode == 401) {
        throw 'Unauthorized: Token หมดอายุหรือไม่ถูกต้อง';
      } else {
        throw 'ไม่สามารถโหลด PDF (status: ${response.statusCode})';
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('📄 รายละเอียดสัญญา', style: GoogleFonts.prompt()),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Expanded(
            child:
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTitle('📌 ข้อมูลสัญญา'),
                              Divider(),
                              // ✅ ใช้ widget.contractNo แสดงเลขสัญญาที่ส่งมา
                              _buildDetailTile(
                                Icons.receipt_long,
                                'Contract No',
                                widget.contractNo,
                              ),
                              Divider(),
                              _buildDetailTile(
                                Icons.car_rental,
                                'Chassis No',
                                contractData?['chassisno'],
                              ),
                              Divider(),
                              _buildDetailTile(
                                Icons.person,
                                'Sale No',
                                contractData?['saleno'],
                              ),
                              Divider(),
                              _buildDetailTile(
                                Icons.assignment,
                                'Job Description',
                                contractData?['jobdescription'],
                              ),
                              Divider(),
                              _buildDetailTile(
                                Icons.car_crash,
                                'Return Car',
                                contractData?['returncar'],
                              ),
                              Divider(),
                              _buildDetailTile(
                                Icons.monetization_on,
                                'Return Amount',
                                contractData?['returnamt'],
                              ),
                              Divider(),
                              _buildDetailTile(
                                Icons.payments,
                                'Amount Per Period',
                                contractData?['amtperperiod'],
                              ),
                              Divider(),
                              _buildDetailTile(
                                Icons.timeline,
                                'Total Period',
                                contractData?['totalperiod'],
                              ),
                              Divider(),
                              _buildDetailTile(
                                Icons.percent,
                                'HP Rate',
                                contractData?['hprate'],
                              ),
                              Divider(),
                              _buildDetailTile(
                                Icons.event_available,
                                'First Paid',
                                contractData?['firstpaid'],
                              ),
                              Divider(),
                              _buildDetailTile(
                                Icons.event_busy,
                                'Last Paid',
                                contractData?['lastpaid'],
                              ),
                              Divider(),
                              _buildDetailTile(
                                Icons.warning,
                                'Overdue Days',
                                contractData?['max_nodays'],
                              ),
                              Divider(),
                              _buildDetailTile(
                                Icons.map,
                                'Maplocation',
                                contractData?['maplocations'],
                              ),
                              Divider(),
                            ],
                          ),
                        ),
                      ),
                    ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final contractNo = widget.contractNo;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      ContractImagePage(contractNo: contractNo),
                            ),
                          );
                        },
                        icon: Icon(Icons.image, size: 18),
                        label: Text(
                          'ภาพสัญญา',
                          style: GoogleFonts.prompt(fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal[300],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final contractNo = widget.contractNo;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      PayAS400Page(contractNo: contractNo),
                            ),
                          );
                        },
                        icon: Icon(Icons.payment, size: 18),
                        label: Text(
                          'ชำระเงิน',
                          style: GoogleFonts.prompt(fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[400],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _openCardCutPDF,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[800],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'การ์ดชำระลูกหนี้',
                          style: GoogleFonts.prompt(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final contractNo = widget.contractNo;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => FollowContractPage(
                                    contractNo: contractNo,
                                    username: widget.username,
                                  ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'การติดตาม',
                          style: GoogleFonts.prompt(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.prompt(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.teal[800],
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String label, dynamic value) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(
        label,
        style: GoogleFonts.prompt(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        value?.toString() ?? '-',
        style: GoogleFonts.prompt(fontSize: 15),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
    );
  }
}
