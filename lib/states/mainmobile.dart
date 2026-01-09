import 'dart:convert';
import 'package:erp/states/followallcontract.dart';
import 'package:erp/widgets/contract_detail_dialog_loader.dart';
import 'package:erp/widgets/contract_list.dart';
import 'package:erp/widgets/contract_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../states/authen.dart';

class MainMobile extends StatefulWidget {
  final String username;
  final int employeesId;
  final String employeesRecordId;
  MainMobile({
    required this.username,
    required this.employeesId,
    required this.employeesRecordId,
  });

  @override
  _MainMobileState createState() => _MainMobileState();
}

class _MainMobileState extends State<MainMobile> {
  bool _isLoading = false;
  List<dynamic> _contracts = [];
  List<String> _contractIds = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token') ?? '';
  }

  Future<void> _fetchData() async {
    final url =
        'https://erp.somjai.app/api/followups/fin/send/mobilepp?username=${widget.username}';
    final token = await _getToken();

    setState(() {
      _isLoading = true;
      _contracts = [];
      _contractIds = [];
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
        print('DEBUG decoded data: $data');

        if (data is List) {
          final contractsWithId =
              data.map((item) {
                final cd = item['contractdi'] ?? item['contractid'] ?? '';

                item['employeesid'] = widget.employeesId;
                item['employees_record_id'] = widget.employeesRecordId;

                // ❗ log ดูค่า
                print(
                  'DEBUG contract after assigning employeesId/RecordId: '
                  '${item['contractno']} | employeesId=${item['employeesid']} | employeesRecordId=${item['employees_record_id']}',
                );

                print('DEBUG item with employees: $item');

                return {...item, 'contractdi': cd};
              }).toList();

          final ids =
              contractsWithId
                  .map<String>((item) => item['contractdi'].toString())
                  .toList();

          setState(() {
            _contracts = contractsWithId;
            _contractIds = ids;
          });
        } else {
          _showError('ข้อมูลไม่ถูกต้อง');
        }
      } else {
        _showError('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ (${response.statusCode})');
      }
    } catch (e) {
      _showError('เกิดข้อผิดพลาด: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'ตกลง',
                  style: GoogleFonts.prompt(color: Colors.blueAccent),
                ),
              ),
            ],
          ),
    );
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => AuthenPage()),
      (route) => false,
    );
  }

  void _setSearchQuery(String query) {
    setState(() {
      _searchQuery = query.trim();
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      final result = await launchUrl(
        launchUri,
        mode: LaunchMode.externalApplication,
      );
      if (!result) {
        throw 'เปิดโทรศัพท์ไม่ได้';
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ไม่สามารถโทรออกได้: $e')));
    }
  }

void _showContractDetails(dynamic contract) {
    // ❗ log ก่อนเปิด dialog
    print(
      'DEBUG _showContractDetails: contractNo=${contract['contractno']} | '
      'employeesId=${contract['employeesid']} | employeesRecordId=${contract['employees_record_id']}',
    );

    ContractDetailDialogLoader.show(
      context: context,
      contract: contract,
      username: widget.username,
      employeesId: widget.employeesId,
      employeesRecordId: widget.employeesRecordId,
    );
  }


  

  @override
  Widget build(BuildContext context) {
    final filteredContracts =
        _contracts.where((contract) {
          final search = _searchQuery.toLowerCase();
          return contract.values.any(
            (value) =>
                value != null &&
                value.toString().toLowerCase().contains(search),
          );
        }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'เร่งรัด ERPV.1',
              style: GoogleFonts.prompt(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: const Icon(Icons.menu, color: Colors.black87),
              onSelected: (value) {
                if (value == 'follow_all') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => FollowAllContractPage(
                            username: widget.username,
                            employeesId: widget.employeesId,
                            employeesRecordId: widget.employeesRecordId,
                          ),
                    ),
                  );
                }
              },
              itemBuilder:
                  (context) => [
                    PopupMenuItem<String>(
                      value: 'follow_all',
                      child: Row(
                        children: [
                          Icon(Icons.assignment, color: Colors.teal),
                          const SizedBox(width: 8),
                          Text('งานทั้งหมด', style: GoogleFonts.prompt()),
                        ],
                      ),
                    ),
                  ],
            ),
          ],
        ),
        iconTheme: IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.teal),
            onPressed: _fetchData,
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _logout,
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  ContractSearchBar(onChanged: _setSearchQuery),
                  Expanded(
                    child:
                        filteredContracts.isEmpty
                            ? Center(
                              child: Text(
                                'ไม่พบข้อมูล',
                                style: GoogleFonts.prompt(fontSize: 18),
                              ),
                            )
                            : ContractList(
                              contracts: filteredContracts,
                              onPhoneCall: _makePhoneCall,
                              onShowDetail: _showContractDetails,
                            ),
                  ),
                ],
              ),
    );
  }
}
