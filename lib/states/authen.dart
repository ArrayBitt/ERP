import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:erp/states/mainmobile.dart';
import 'package:erp/widgets/login_logo.dart';
import 'package:erp/widgets/login_form.dart';
import 'package:erp/widgets/login_button.dart';
import 'package:erp/widgets/loading_indicator.dart';

class AuthenPage extends StatefulWidget {
  @override
  _AuthenPageState createState() => _AuthenPageState();
}

class _AuthenPageState extends State<AuthenPage> {
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  List<Map<String, dynamic>> _branches = [];
  List<Map<String, dynamic>> _nitiList = [];
  Map<String, dynamic>? _selectedBranch;
  Map<String, dynamic>? _selectedNiti;

  @override
  void initState() {
    super.initState();
    _loadBranches();
    _loadNiti();
  }

  // 🔹 Load สาขา
  Future<void> _loadBranches() async {
    final url = 'https://erp.somjai.app/api/auth/get/branch?keyword=';
    //final url = 'https://erp-uat.somjai.app/api/auth/get/branch?keyword=';
      
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          _branches =
              data
                  .map<Map<String, dynamic>>((e) => e as Map<String, dynamic>)
                  .toList();
        });
      }
    } catch (e) {
      print('Error loadBranches: $e');
    }
  }

// 🔹 Load นิติ
  Future<void> _loadNiti() async {
    final url = 'https://erp.somjai.app/api/auth/get/niti?keyword=';
//final url = 'https://erp-uat.somjai.app/api/auth/get/niti?keyword=';
    
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          _nitiList =
              data
                  .map<Map<String, dynamic>>((e) => e as Map<String, dynamic>)
                  .toList();
        });
      } else {
        print('LoadNiti failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loadNiti: $e');
    }
  }

  // 🔹 Save token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  // 🔹 Save username
  Future<void> saveUserJson(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(user);
    await prefs.setString('username', jsonString);
  }

  // 🔹 Login
  Future<void> _login() async {
    if ((_formKey.currentState?.validate() ?? false) &&
        _selectedBranch != null &&
        _selectedNiti != null) {
      setState(() => _isLoading = true);

      final username = _userController.text.trim();
      final password = _passwordController.text.trim();
 
       final url = 'https://erp.somjai.app/api/auth/team/rush/login';

       //final url = 'https://erp-uat.somjai.app/api/auth/team/rush/login';


     final body = {
        'username': username,
        'password': password,
        'branch_id': _selectedBranch!['branchid'].toString(),
        'niti_id': _selectedNiti!['companyid'].toString(),
      };

      print("Login API body: $body");

      try {
        final response = await http.post(Uri.parse(url), body: body);
        print('Login Response: ${response.body}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print("==== Full Login JSON Response ====");
          print(const JsonEncoder.withIndent('  ').convert(data));
          print("==================================");

          if (data.containsKey('access_token')) {
            final token = data['access_token'];
            await saveToken(token);
            await saveUserJson({'username': username});

            // 🔹 Decode JWT token
            Map<String, dynamic> decodedToken = Jwt.parseJwt(token);

            print("==== Decoded JWT Payload ====");
            decodedToken.forEach((key, value) {
              print("$key: $value");
            });
            print("==================================");

            // ดึงค่า employeesid / employees_record_id จาก payload
            final employeesId = decodedToken['emp_id'] ?? decodedToken['empid'];
            final employeesRecordId =
                decodedToken['emp_code'] ?? decodedToken['emp_record_id'];

            print("employeesid: $employeesId");
            print("employees_record_id: $employeesRecordId");

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (context) => MainMobile(
                      username: username,
                      employeesId: employeesId,
                      employeesRecordId: employeesRecordId,
                    ),
              ),
            );
          } else {
            _showError('เข้าสู่ระบบไม่สำเร็จ: ไม่พบ token');
          }
        } else {
          _showError('ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง');
        }
      } catch (e) {
        _showError('เกิดข้อผิดพลาด: ${e.toString()}');
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      _showError('กรุณาเลือกสาขาและนิติ');
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
                  style: GoogleFonts.prompt(color: Colors.amber[800]),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  LoginLogo(),
                  SizedBox(height: 20),
                  Text(
                    'เข้าสู่ระบบ',
                    style: GoogleFonts.prompt(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 30),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        LoginForm(
                          userController: _userController,
                          passwordController: _passwordController,
                          isPasswordVisible: _isPasswordVisible,
                          onTogglePassword: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        SizedBox(height: 16),

                        // 🔹 Dropdown นิติ
                        DropdownButtonFormField<Map<String, dynamic>>(
                          value: _selectedNiti,
                          items:
                              _nitiList
                                  .map(
                                    (n) => DropdownMenuItem(
                                      value: n,
                                      child: Text(n['companyname']),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (val) => setState(() => _selectedNiti = val),
                          decoration: InputDecoration(
                            labelText: 'เลือกนิติ',
                            border: OutlineInputBorder(),
                          ),
                          validator:
                              (val) => val == null ? 'กรุณาเลือกนิติ' : null,
                        ),
                        SizedBox(height: 16),

                        // 🔹 Dropdown สาขา
                        DropdownButtonFormField<Map<String, dynamic>>(
                          value: _selectedBranch,
                          items:
                              _branches
                                  .map(
                                    (b) => DropdownMenuItem(
                                      value: b,
                                      child: Text(
                                        '${b['branchname']} - ${b['branchcode']}',
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (val) => setState(() => _selectedBranch = val),
                          decoration: InputDecoration(
                            labelText: 'เลือกสาขา',
                            border: OutlineInputBorder(),
                          ),
                          validator:
                              (val) => val == null ? 'กรุณาเลือกสาขา' : null,
                        ),
                        SizedBox(height: 30),
                        _isLoading
                            ? LoadingIndicator()
                            : LoginButton(onPressed: _login),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
