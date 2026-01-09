import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'authen.dart';

class FollowAllContractPage extends StatefulWidget {
  final String username;
  final int employeesId;
  final String employeesRecordId;

  const FollowAllContractPage({
    super.key,
    required this.username,
    required this.employeesId,
    required this.employeesRecordId,
  });

  @override
  State<FollowAllContractPage> createState() => _FollowAllContractPageState();
}

class _FollowAllContractPageState extends State<FollowAllContractPage> {
  bool _isLoading = false;
  Map<String, dynamic> _dashboard = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // ================= TOKEN =================
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token') ?? '';
  }

  // ================= FETCH DATA =================
  Future<void> _fetchData() async {
    final token = await _getToken();

    if (token.isEmpty) {
      _goToLogin();
      return;
    }

    final url =
        'https://erp.somjai.app/api/followups/count/dashbord/mobileapp?username=${widget.username}';

    setState(() {
      _isLoading = true;
      _dashboard = {};
    });

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('DEBUG status: ${response.statusCode}');
      print('DEBUG raw body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map<String, dynamic>) {
          setState(() {
            _dashboard = data;
          });
        } else {
          _showError('รูปแบบข้อมูล API ไม่ถูกต้อง');
        }
      } else if (response.statusCode == 401) {
        _goToLogin();
      } else {
        _showError('เชื่อมต่อเซิร์ฟเวอร์ไม่ได้ (${response.statusCode})');
      }
    } catch (e) {
      _showError('เกิดข้อผิดพลาด: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ================= LOGOUT =================
  void _goToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => AuthenPage()),
      (route) => false,
    );
  }

  // ================= ERROR =================
  void _showError(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'ข้อผิดพลาด',
              style: GoogleFonts.prompt(fontWeight: FontWeight.bold),
            ),
            content: Text(message, style: GoogleFonts.prompt()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('ตกลง', style: GoogleFonts.prompt()),
              ),
            ],
          ),
    );
  }

  // ================= CARD BUILDER =================
  Widget _buildCard(String title, dynamic value, Color color, IconData icon) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // TODO: กด Card ไปหน้า detail list ถ้าต้องการ
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                radius: 28,
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                value.toString(),
                style: GoogleFonts.prompt(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: GoogleFonts.prompt(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'งานทั้งหมด',
          style: GoogleFonts.prompt(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.teal),
            onPressed: _fetchData,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _dashboard.isEmpty
              ? Center(
                child: Text(
                  'ไม่พบข้อมูล',
                  style: GoogleFonts.prompt(fontSize: 18),
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(12),
                child: GridView(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  children: [
                    _buildCard(
                      'งานทั้งหมด',
                      _dashboard['all'] ?? 0,
                      Colors.blue,
                      Icons.assignment,
                    ),
                    _buildCard(
                      'ยังไม่ได้ติดตาม',
                      _dashboard['notdo'] ?? 0,
                      Colors.orange,
                      Icons.pending_actions,
                    ),
                    _buildCard(
                      'หลุดนัด',
                      _dashboard['miss'] ?? 0,
                      Colors.red,
                      Icons.warning,
                    ),
                    _buildCard(
                      'ไม่มีการนัดหมาย',
                      _dashboard['nodate'] ?? 0,
                      Colors.grey,
                      Icons.event_busy,
                    ),
                    _buildCard(
                      'ติดตามสำเร็จ',
                      _dashboard['complet'] ?? 0,
                      Colors.green,
                      Icons.check_circle,
                    ),
                  ],
                ),
              ),
    );
  }
}
