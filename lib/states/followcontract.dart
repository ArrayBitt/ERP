import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FollowContractPage extends StatefulWidget {
  final String contractNo;
  final String username;

  const FollowContractPage({
    Key? key,
    required this.contractNo,
    required this.username,
  }) : super(key: key);

  @override
  _FollowContractPageState createState() => _FollowContractPageState();
}

class _FollowContractPageState extends State<FollowContractPage> {
  List<dynamic> followData = [];
  bool isLoading = true;

  Color iconColor = Colors.teal.shade600;
  TextStyle textStyle = GoogleFonts.mitr(fontSize: 14, color: Colors.black87);

  @override
  void initState() {
    super.initState();
    fetchFollowData();
  }

  // ================== API ==================
  Future<void> fetchFollowData() async {
    try {
      // 🔐 JWT
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';

      if (token.isEmpty) {
        throw Exception('ไม่พบ jwt_token');
      }

      // 🔗 ใช้ username จาก widget
      final url = Uri.parse(
        'https://erp.somjai.app/api/followups/find/data/after/dept'
        '?username=${widget.username}&limit=50&offet=0',
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded is List) {
          setState(() {
            followData = decoded;
            isLoading = false;
          });
        } else {
          throw Exception('JSON ไม่ใช่ List');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('fetchFollowData error: $e');
      setState(() {
        followData = [];
        isLoading = false;
      });
    }
  }

  // ================== CARD ==================
  Widget buildFollowCardModern(dynamic item) {
    final employee = item['employee_record'];
    final tracking = item['trackingtype'];
    final contract = item['contracts'];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // วันที่ + เวลา
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 18, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  item['created_at']?.substring(0, 10) ?? '-',
                  style: textStyle,
                ),
                const Spacer(),
                Icon(Icons.access_time, size: 18, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  item['created_at'] != null
                      ? item['created_at'].substring(11, 16)
                      : '-',
                  style: textStyle,
                ),
              ],
            ),

            const Divider(height: 16),

            // รายละเอียด
            Text(item['follow_result'] ?? '-', style: textStyle),

            const SizedBox(height: 8),

            // ผู้ติดตาม
            Text(
              'ผู้ติดตาม: ${employee?['empfname'] ?? ''} ${employee?['emplname'] ?? ''}',
              style: textStyle,
            ),

            // ประเภท
            Text('ประเภท: ${tracking?['meaning'] ?? '-'}', style: textStyle),

            const SizedBox(height: 8),

            // นัด + ยอดค้าง
            Row(
              children: [
                Text('กำหนดชำระ: ${item['due_date'] ?? '-'}', style: textStyle),
                const Spacer(),
                Text('ค้าง: ${item['overdue_amt'] ?? 0}', style: textStyle),
              ],
            ),

            const Divider(height: 16),

            // สัญญา + ผู้บันทึก
            Row(
              children: [
                Text(
                  'สัญญา: ${contract?['contractno'] ?? '-'}',
                  style: textStyle,
                ),
                const Spacer(),
                Text(employee?['empno'] ?? '-', style: textStyle),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================== BUILD ==================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '📋 การติดตามสัญญา',
          style: GoogleFonts.mitr(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : followData.isEmpty
              ? Center(
                child: Text(
                  'ไม่พบข้อมูลการติดตาม',
                  style: GoogleFonts.mitr(fontSize: 18),
                ),
              )
              : ListView.builder(
                itemCount: followData.length,
                itemBuilder: (context, index) {
                  return buildFollowCardModern(followData[index]);
                },
              ),
    );
  }
}
