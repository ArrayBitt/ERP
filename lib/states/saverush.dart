import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // เพิ่มการ import สำหรับการแปลงวันที่
import 'package:cjk/states/cameraGridPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SaveRushPage extends StatefulWidget {
  final String contractId;

  final String contractNo;
  final String hpprice;
  final String username;
  final String hpIntAmount;
  final String aMount408;
  final String aRname;
  final String tranferdate;
  final String estmdate;
  final String hp_overdueamt;
  final String follow400;
  final String seqno;
  final String followCount;
  final String employeeId;
  final String currentUserId;
  final List<String?> videoFilenames;

  const SaveRushPage({
    Key? key,
    required this.contractNo,
    required this.hpprice,
    required this.username,
    required this.hpIntAmount,
    required this.aMount408,
    required this.aRname,
    required this.tranferdate,
    required this.estmdate,
    required this.videoFilenames,
    required this.hp_overdueamt,
    required this.seqno,
    required this.follow400,
    required this.contractId,
    required this.followCount,
    required this.employeeId,
    required this.currentUserId,
  }) : super(key: key);

  @override
  _SaveRushPageState createState() => _SaveRushPageState();
}

class _SaveRushPageState extends State<SaveRushPage> {
  String? _selectedFollowType;
  List<Map<String, dynamic>> _followTypes = [];
  int? _selectedFollowTypeId; // nullable

  final _formKey = GlobalKey<FormState>();

  // ตัวแปรนี้ใช้เก็บสถานะว่าควรส่ง '0.00' แทนค่าจริงหรือไม่
  bool _shouldForceZeroOnNextSaves = false;

  bool _disableFollowFee = false;
  bool _forceZeroFollowAmount = false;
  late bool _isFollowFeeEditable;
  bool _isOtherDatacarDetail = false;

  String? _selectedPersonType;
  String fperson = ''; // เก็บค่าประเภทบุคคลที่เลือกหรือกรอกเอง
  bool _isOtherPerson = false;
  TextEditingController _otherPersonController = TextEditingController();

  String? _selectedaddressType;
  String faddress = '';
  bool _isOtherAdress = false;
  TextEditingController _otherAdressController = TextEditingController();

  String? _selectedfdatacarType;
  String fdatacar = '';
  bool _isOtherDatacar = false;
  TextEditingController _otherDatacarController = TextEditingController();

  String? _selectedareaType;
  String farea = '';
  bool _isOtherArea = false;
  TextEditingController _otherAreaController = TextEditingController();

  String? _selectedproperType;
  String fproperty = '';
  bool _isOtherProperty = false;
  TextEditingController _otherPropertyController = TextEditingController();

  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _followFeeController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  String? _selectedDatacarDetail;

  final TextEditingController _otherDatacarDetailController =
      TextEditingController();

  String fcarstatus = '';

  // ฟังก์ชันแปลงวันที่จาก ค.ศ. เป็น พ.ศ.
  String convertToThaiDate(DateTime date) {
    int year = date.year + 543; // เพิ่ม 543 ปี
    return DateFormat(
      'dd/MM/yyyy',
    ).format(DateTime(year, date.month, date.day));
  }

  String getStatusText(bool status) {
    return status ? 'สำเร็จ' : 'รอดำเนินการ';
  }

  // ฟังก์ชันสำหรับเลือกวันที่
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _dueDateController.text = convertToThaiDate(picked);
      });
    }
  }

  int _selectedIndex = 0;
  bool _isSaving = false;
  bool _isCompleted = false;

  bool _loadingFollowTypes = true;

  List<String?> imageFilenames = List.filled(6, null);

  @override
  void initState() {
    super.initState();
    _fetchFollowTypes();

    final overdueAmt = double.tryParse(widget.hp_overdueamt) ?? 0.0;
    final follow400 = double.tryParse(widget.follow400) ?? 0.0;

    if (overdueAmt <= 1000) {
      _isFollowFeeEditable = false;
      _followFeeController.text = '0.00';
    } else if (follow400 == 0.00) {
      _isFollowFeeEditable = false;
      _followFeeController.text = '400.00';
    } else if (follow400 < 400.00) {
      _isFollowFeeEditable = true;
      _followFeeController.text = follow400.toStringAsFixed(2);
    } else {
      _isFollowFeeEditable = false;
      _followFeeController.text = '0.00';
    }
  }

  String formatThaiDate(String input) {
    try {
      final parts = input.split('/');
      if (parts.length == 3) {
        final day = parts[0].padLeft(2, '0');
        final month = parts[1].padLeft(2, '0');
        final year = parts[2].padLeft(4, '0');

        return '$year$month$day';
      }
    } catch (e) {
      print('Error in date format: $e');
    }
    return input;
  }

  Future<void> _fetchFollowTypes() async {
    const keyword = 'M-1';
    final url =
        'https://erp-uat.somjai.app/api/trackingtypes/search?keyword=$keyword';

    try {
      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(res.body);
        final List data = responseData['data'] ?? [];

        setState(() {
          _followTypes =
              data.map<Map<String, dynamic>>((item) {
                return {
                  'id': item['id'], // ใช้ ID จริง
                  'trackingtype': item['trackingtype'].toString(),
                  'meaning': item['meaning'].toString(),
                };
              }).toList();
        });
      } else {
        print('❌ ดึงข้อมูล trackingtype ไม่สำเร็จ: Status ${res.statusCode}');
      }
    } catch (e) {
      print('❌ เกิดข้อผิดพลาดขณะดึง trackingtype: $e');
    }
  }

  Future<void> _getCurrentLocationAndSetAddress() async {
    bool serviceEnabled;
    LocationPermission permission;

    // ตรวจสอบว่าเปิด location service หรือยัง
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // แจ้งเตือนให้เปิด GPS
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('กรุณาเปิด GPS')));
      return;
    }

    // ขอสิทธิ์เข้าถึง location
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('ไม่ได้รับสิทธิ์ใช้งาน GPS')));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('สิทธิ์การใช้งาน GPS ถูกปฏิเสธถาวร')),
      );
      return;
    }

    // ดึงตำแหน่งพิกัด
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // แปลงพิกัดเป็นชื่อสถานที่
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      String address =
          '${place.street ?? ''} ${place.subLocality ?? ''} ${place.locality ?? ''} ${place.administrativeArea ?? ''} ${place.postalCode ?? ''}';

      _locationController.text = address.trim();
    }
  }


  // ฟังก์ชั่นบันทึก
  Future<Map<String, dynamic>> _saveRush() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';

    if (token.isEmpty) {
      return {'success': false, 'message': '❌ ไม่มี JWT token'};
    }

    double? latitude;
    double? longitude;

    String fperson =
        _isOtherPerson
            ? _otherPersonController.text
            : (_selectedPersonType ?? '');
    String faddress =
        _isOtherAdress
            ? _otherAdressController.text
            : (_selectedaddressType ?? '');
    String fdatacar =
        _isOtherDatacarDetail
            ? _otherDatacarDetailController.text
            : (_selectedDatacarDetail ?? '');
    String farea =
        _isOtherArea ? _otherAreaController.text : (_selectedareaType ?? '');
    String fproperty =
        _isOtherProperty
            ? _otherPropertyController.text
            : (_selectedproperType ?? '');

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      latitude = position.latitude;
      longitude = position.longitude;
    } catch (e) {
      print('⚠️ ไม่สามารถดึงตำแหน่งได้: $e');
    }

    // ป้องกันค่า ID ว่าง
    if (_selectedFollowTypeId == null) {
      return {'success': false, 'message': '❌ กรุณาเลือกประเภทการติดตาม'};
    }

    print('▶️ เริ่มบันทึกข้อมูล... trackingTypeId: $_selectedFollowTypeId');

    final Map<String, dynamic> data = {
      'contractid': widget.contractId,
      'trackingtypeid': _selectedFollowTypeId, // ใช้ nullable int ที่อัปเดตแล้ว
      'follow_up_count': int.tryParse(widget.followCount) ?? 1,
      'employeesid': int.tryParse(widget.employeeId) ?? 0,
      'follow_result': fperson,
      'due_date':
          _dueDateController.text.isNotEmpty
              ? DateFormat(
                'yyyy-MM-dd',
              ).format(DateFormat('dd/MM/yyyy').parse(_dueDateController.text))
              : null,
      'penalty_fee': double.tryParse(widget.hpIntAmount) ?? 0,
      'tracking_fee': double.tryParse(_followFeeController.text) ?? 0,
      'mileage': int.tryParse(_mileageController.text) ?? 0,
      'employees_record_id': int.tryParse(widget.currentUserId) ?? 0,
      'followupfee_amt': double.tryParse(widget.aMount408) ?? 0,
      'overdue_amt': double.tryParse(widget.hp_overdueamt) ?? 0,
      'follow_date': DateTime.now().toIso8601String(),
      'person_type': fperson,
      'tracking_address': faddress,
      'car_value': fdatacar,
      'field_result': farea,
      'asset_result': fproperty,
      'lcation_follow': locationController.text,
      'process_status': _isCompleted,
      'remark': _noteController.text,
      'latitude': latitude ?? 0,
      'longtitude': longitude ?? 0,
    };

    final url = 'https://erp-uat.somjai.app/api/debttrackings/';

    print('📤 ส่งข้อมูลไปยัง API: $url');
    print('📦 Payload API: $data');

    try {
      final res = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(data),
      );

      print('📥 Response Code: ${res.statusCode}');
      print('📥 Response Body: ${res.body}');

      if (res.statusCode == 201) {
        return {'success': true};
      } else {
        final body = json.decode(res.body);
        final msg = body['message'] ?? 'เกิดข้อผิดพลาดจาก API';
        return {'success': false, 'message': '❌ API บันทึกติดตามล้มเหลว: $msg'};
      }
    } catch (e) {
      print('❌ เกิดข้อผิดพลาดขณะส่งข้อมูล: $e');
      return {'success': false, 'message': '❌ ข้อผิดพลาดระบบ: ${e.toString()}'};
    }
  }


void _submitForm() async {
    print('เริ่มบันทึกข้อมูล...');

    // ✅ แก้ไขตรงนี้ ใช้ _selectedFollowTypeId แทน _selectedFollowType
    if (_selectedFollowTypeId == null || _selectedFollowTypeId == 0) {
      print('ยังไม่ได้เลือกประเภทการตาม');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('กรุณาเลือกประเภทการติดตาม')));
      return;
    }

    // เช็ค memo ไม่เกิน 250 ตัวอักษร
    if (_noteController.text.length > 250) {
      print('memo ยาวเกิน 250 ตัวอักษร');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ข้อความหมายเหตุห้ามเกิน 250 ตัวอักษร')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      print('Form validation ไม่ผ่าน');
      return;
    }

    setState(() => _isSaving = true);
    final result = await _saveRush();
    setState(() => _isSaving = false);

    print('บันทึกสำเร็จหรือไม่: ${result['success']}');

    if (!result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'บันทึกไม่สำเร็จ โปรดลองใหม่'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('✅ บันทึกข้อมูลสำเร็จ')));
    Navigator.pop(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder:
            (BuildContext dialogContext) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              insetPadding: EdgeInsets.symmetric(horizontal: 24),
              backgroundColor: Colors.grey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Center(
                      child: Icon(
                        Icons.check_circle_rounded,
                        size: 72,
                        color: Colors.teal.shade600,
                      ),
                    ),
                    SizedBox(height: 16),
                    Center(
                      child: Text(
                        'บันทึกสำเร็จ',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade800,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Divider(thickness: 1.2, color: Colors.grey.shade300),

                    _buildInfoRow('เลขที่สัญญา', widget.contractNo),
                    _buildInfoRow('ผู้ติดตาม', widget.username),
                    _buildInfoRow('ชื่อลูกค้า', widget.aRname),
                    _buildInfoRow('ประเภทบุคคล', fperson),
                    _buildInfoRow('ที่อยู่ติดตาม', faddress),
                    _buildInfoRow('ข้อมูลรถ', fdatacar),
                    _buildInfoRow('ผลการลงพื้นที่', farea),
                    _buildInfoRow('ผลทรัพย์สิน', fproperty),
                    _buildInfoRow('ข้อความ', _noteController.text),

                    // ✅ แก้ตรงนี้ ใช้ _selectedFollowTypeId
                    _buildInfoRow(
                      'ประเภทการตาม',
                      _followTypes.firstWhere(
                            (e) => e['id'] == _selectedFollowTypeId,
                            orElse: () => {'meaning': '-'},
                          )['meaning'] ??
                          '-',
                    ),

                    _buildInfoRow('วันนัดชำระ', _dueDateController.text),
                    _buildInfoRow('จำนวนเงิน', _amountController.text),
                    _buildInfoRow(
                      'ค่าติดตาม (ระบบคำนวณ)',
                      _followFeeController.text,
                    ),
                    _buildInfoRow('ระยะไมล์', _mileageController.text),
                    _buildInfoRow('สถานที่', locationController.text),
                    _buildInfoRow(
                      'สถานะการดำเนินการ',
                      getStatusText(_isCompleted),
                    ),
                  ],
                ),
              ),
            ),
      );
    });
  }


  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value.isEmpty ? '-' : value,
              style: TextStyle(color: Colors.grey.shade900),
            ),
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        _submitForm(); // เรียกบันทึกข้อมูล
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CameraGridPage(contractno: widget.contractNo),
          ),
        ).then((result) {
          if (result != null && result is Map<String, String>) {
            setState(() {
              // รับค่าที่ส่งกลับมาและเก็บไว้ใน imageFilenames
              imageFilenames = [
                result['pica'] ?? '',
                result['picb'] ?? '',
                result['picc'] ?? '',
                result['picd'] ?? '',
                result['pice'] ?? '',
                result['picf'] ?? '',
              ];
            });
          }
        });

        break;
    }
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    Widget? suffixIcon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    FormFieldValidator<String>? validator,
    bool enabled = true, // เพิ่มพารามิเตอร์นี้ (ดีฟอลต์เป็น true)
    bool readOnly = false, // ✅ เพิ่มตัวนี้
    List<TextInputFormatter>? inputFormatters, // ✅ เพิ่มตรงนี้
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: GoogleFonts.prompt(),
        enabled: enabled, // เพิ่มตรงนี้สำหรับเปิด/ปิดการกรอก
        readOnly: readOnly, // ✅ เพิ่มตรงนี้
        inputFormatters: inputFormatters, // ✅ ใช้ตรงนี้
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.amber.shade800),
          labelText: label,
          labelStyle: GoogleFonts.prompt(color: Colors.grey.shade800),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.amber.shade800, width: 1.5),
          ),
          suffixIcon: suffixIcon,
        ),
        validator:
            validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return 'กรุณากรอก $label';
              }
              return null;
            },
      ),
    );
  }

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

    List<String> adressTypes = [
      'ที่อยู่ปัจจุบัน',
      'ที่อยู่ตามทะเบียนราฎ',
      'ที่ทำงาน',
      'ที่อยู่พ่อ/แม่',
      'ที่อยู่ใหม่จากการสืบทราบ',
      'อื่นๆ',
    ];

    List<String> fareaTypes = [
      'นัดชำระ',
      'ติดตามต่อ',
      'ส่งต่อสายงานอื่น',
      'รถจำนำ/ขาย',
      'ส่งเรื่องฝ่ายกฎหมาย',
      'อื่นๆ',
    ];

    List<String> datacarTypes = ['พบรถ', 'ไม่พบรถ'];

    String? _selectedDatacarDetail; // สำหรับ dropdown ย่อย
    List<String> foundCarDetails = [
      'สภาพดี',
      'รถพังเสียหาย',
      'รถดัดแปลง',
      'จอดทิ้งไว้ไม่ได้ใช้งาน',
      'อื่นๆ',
    ];
    List<String> notFoundCarDetails = [
      'รถใช้งานนอกสถานที่',
      'รถใช้ในพื้นที่ แต่ไม่พบ',
      'จำนำหรือขาย',
      'ไม่ให้ข้อมูล',
      'อื่นๆ',
    ];

    List<String> fproperTypes = ['ไม่มีทรัพย์สิน', 'มีทรัพย์สิน'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: yellow,
        title: Text(
          'บันทึกข้อมูลการตามหนี้',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.payment, color: Colors.amber.shade700),
                      SizedBox(width: 12),
                      Text(
                        'ค่าปรับ: ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber.shade900,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${widget.hpIntAmount}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.payment, color: Colors.amber.shade700),
                      SizedBox(width: 12),
                      Text(
                        'ค่าทวงถาม: ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber.shade900,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${widget.aMount408}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.payment, color: Colors.amber.shade700),
                      SizedBox(width: 12),
                      Text(
                        'ค่างวดคงค้าง: ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber.shade900,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${widget.hp_overdueamt}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  //_selectedPersonType
                  DropdownButtonFormField<String>(
                    value: _isOtherPerson ? 'อื่นๆ' : _selectedPersonType,
                    items:
                        personTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPersonType = value;
                        if (value == 'อื่นๆ') {
                          _isOtherPerson = true;
                          _otherPersonController.text = '';
                          fperson = ''; // เคลียร์ค่า fperson ก่อนกรอกใหม่
                        } else {
                          _isOtherPerson = false;
                          fperson =
                              value ??
                              ''; // **อัพเดต fperson ให้เท่ากับค่าที่เลือก**
                        }
                      });
                    },

                    decoration: InputDecoration(
                      labelText: 'ประเภทบุคคล',
                      labelStyle: GoogleFonts.prompt(
                        color: Colors.amber.shade700,
                      ),
                      prefixIcon: Icon(Icons.person, color: yellow),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
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
                  SizedBox(height: 12),

                  if (_isOtherPerson) ...[
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _otherPersonController,
                      decoration: InputDecoration(
                        labelText: 'กรุณาระบุประเภทบุคคล',
                        prefixIcon: Icon(Icons.edit, color: yellow),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
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
                      onChanged: (val) {
                        setState(() {
                          fperson = val;
                          print('กรอกอื่นๆ: $fperson');
                        });
                      },
                      validator: (value) {
                        if (_isOtherPerson &&
                            (value == null || value.isEmpty)) {
                          return 'กรุณาระบุประเภทบุคคล';
                        }
                        return null;
                      },
                    ),
                  ],
                  SizedBox(height: 12),

                  //_selectedPersonType

                  //_selectedaddressType
                  DropdownButtonFormField<String>(
                    value: _isOtherAdress ? 'อื่นๆ' : _selectedaddressType,
                    items:
                        adressTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedaddressType = value;
                        if (value == 'อื่นๆ') {
                          _isOtherAdress = true;
                          _otherAdressController.text = '';
                          faddress = ''; // เคลียร์ค่า faddress
                        } else {
                          _isOtherAdress = false;
                          faddress = value ?? ''; // ← ตรงนี้ควรอัปเดต faddress
                        }
                      });
                    },

                    decoration: InputDecoration(
                      labelText: 'ที่อยู่ติดตาม',
                      labelStyle: GoogleFonts.prompt(
                        color: Colors.amber.shade700,
                      ),
                      prefixIcon: Icon(Icons.add_reaction_sharp, color: yellow),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
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
                  SizedBox(height: 12),

                  if (_isOtherAdress) ...[
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _otherAdressController,
                      decoration: InputDecoration(
                        labelText: 'กรุณาระบุที่อยู่ติดตาม',
                        prefixIcon: Icon(Icons.edit, color: yellow),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
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
                      onChanged: (val) {
                        setState(() {
                          faddress = val;
                          print('กรอกอื่นๆ ที่อยู่ติดตาม: $faddress');
                        });
                      },

                      validator: (value) {
                        if (_isOtherAdress &&
                            (value == null || value.isEmpty)) {
                          return 'กรุณาระบุประเภทบุคคล';
                        }
                        return null;
                      },
                    ),
                  ],
                  SizedBox(height: 12),

                  // ===================== ข้อมูลรถ =====================
                  DropdownButtonFormField<String>(
                    value: _selectedfdatacarType,
                    items:
                        datacarTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedfdatacarType = value;
                        _selectedDatacarDetail = null;
                        _isOtherDatacarDetail = false;
                        _otherDatacarDetailController.clear();

                        // เคลียร์ค่า fdatacar และ fcarstatus ทุกครั้งที่เปลี่ยนหลัก
                        fdatacar = '';
                        fcarstatus = '';
                      });
                    },

                    decoration: InputDecoration(
                      labelText: 'ข้อมูลรถ',
                      labelStyle: GoogleFonts.prompt(
                        color: Colors.amber.shade700,
                      ),
                      prefixIcon: Icon(Icons.car_crash, color: yellow),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
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
                  SizedBox(height: 12),

                  if (_selectedfdatacarType == 'พบรถ' ||
                      _selectedfdatacarType == 'ไม่พบรถ') ...[
                    DropdownButtonFormField<String>(
                      value: _selectedDatacarDetail,
                      items:
                          (_selectedfdatacarType == 'พบรถ'
                                  ? foundCarDetails
                                  : notFoundCarDetails)
                              .map(
                                (detail) => DropdownMenuItem(
                                  value: detail,
                                  child: Text(detail),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDatacarDetail = value;
                          _isOtherDatacarDetail = value == 'อื่นๆ';

                          if (_isOtherDatacarDetail) {
                            _otherDatacarDetailController.clear();
                            fdatacar =
                                '${_selectedfdatacarType!} - '; // เตรียมข้อความสำหรับกรอกเอง
                            fcarstatus = ''; // เคลียร์ก่อนกรอกเอง
                          } else {
                            fdatacar = '${_selectedfdatacarType!} - $value';
                            fcarstatus =
                                value ?? ''; // เก็บค่ารายละเอียดที่เลือก
                          }
                        });
                      },

                      decoration: InputDecoration(
                        labelText:
                            _selectedfdatacarType == 'พบรถ'
                                ? 'รายละเอียดรถที่พบ'
                                : 'สาเหตุที่ไม่พบรถ',
                        prefixIcon: Icon(Icons.info_outline, color: yellow),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                  ],

                  if (_isOtherDatacarDetail) ...[
                    TextFormField(
                      controller: _otherDatacarDetailController,
                      decoration: InputDecoration(
                        labelText: 'กรุณาระบุรายละเอียด',
                        prefixIcon: Icon(Icons.edit, color: yellow),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onChanged: (val) {
                        setState(() {
                          fdatacar = '${_selectedfdatacarType!} - $val';
                          fcarstatus = val; // เก็บค่าที่กรอกเอง
                        });
                      },

                      validator: (value) {
                        if (_isOtherDatacarDetail &&
                            (value == null || value.isEmpty)) {
                          return 'กรุณาระบุรายละเอียดเพิ่มเติม';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                  ],

                  //area
                  DropdownButtonFormField<String>(
                    value: _isOtherArea ? 'อื่นๆ' : _selectedareaType,
                    items:
                        fareaTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedareaType = value;
                        if (value == 'อื่นๆ') {
                          _isOtherArea = true;
                          _otherAreaController.text = '';
                          farea = ''; // เคลียร์ค่า farea
                        } else {
                          _isOtherArea = false;
                          farea = value ?? ''; // ← ตรงนี้ควรอัปเดต farea
                        }
                      });
                    },

                    decoration: InputDecoration(
                      labelText: 'ผลการลงพื้นที่',
                      labelStyle: GoogleFonts.prompt(
                        color: Colors.amber.shade700,
                      ),
                      prefixIcon: Icon(Icons.area_chart, color: yellow),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
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
                  SizedBox(height: 12),

                  if (_isOtherArea) ...[
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _otherAreaController,
                      decoration: InputDecoration(
                        labelText: 'กรุณาระบุผลการลงพื้นที่',
                        prefixIcon: Icon(Icons.edit, color: yellow),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
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
                      onChanged: (val) {
                        setState(() {
                          farea = val;
                          print('กรอกอื่นๆ ผลการลงพื้นที่: $farea');
                        });
                      },

                      validator: (value) {
                        if (_isOtherArea && (value == null || value.isEmpty)) {
                          return 'กรุณาระบุประผลการลงพื้นที่';
                        }
                        return null;
                      },
                    ),
                  ],
                  SizedBox(height: 12),

                  //fproperty
                  DropdownButtonFormField<String>(
                    value:
                        _isOtherProperty ? 'มีทรัพย์สิน' : _selectedproperType,
                    items:
                        fproperTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedproperType = value;
                        if (value == 'มีทรัพย์สิน') {
                          _isOtherProperty = true;
                          _otherPropertyController.text = '';
                          fproperty = ''; // เคลียร์ค่า fproperty
                        } else {
                          _isOtherProperty = false;
                          fproperty =
                              value ?? ''; // ← ตรงนี้ควรอัปเดต fproperty
                        }
                      });
                    },

                    decoration: InputDecoration(
                      labelText: 'ผลทรัพย์สิน',
                      labelStyle: GoogleFonts.prompt(
                        color: Colors.amber.shade700,
                      ),
                      prefixIcon: Icon(Icons.money_off, color: yellow),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
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
                  SizedBox(height: 12),

                  if (_isOtherProperty) ...[
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _otherPropertyController,
                      decoration: InputDecoration(
                        labelText: 'กรุณาระบุทรัพย์สิน',
                        prefixIcon: Icon(Icons.edit, color: yellow),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
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
                      onChanged: (val) {
                        setState(() {
                          fproperty = val;
                          print('มีทรัพย์สิน: $fproperty');
                        });
                      },

                      validator: (value) {
                        if (_isOtherProperty &&
                            (value == null || value.isEmpty)) {
                          return 'กรุณาระบุประทรัพย์สิน';
                        }
                        return null;
                      },
                    ),
                  ],
                  SizedBox(height: 12),

                  //_selectedaddressType
                  _buildTextField(
                    label: 'ข้อความ',
                    icon: Icons.note,
                    controller: _noteController,
                    maxLines: 3,
                    validator:
                        (value) => value!.isEmpty ? 'กรุณากรอกหมายเหตุ' : null,
                  ),
                 DropdownButtonFormField<int>(
                    value:
                        _selectedFollowTypeId != 0
                            ? _selectedFollowTypeId
                            : null,
                    items:
                        _followTypes.map((type) {
                          final id = type['id'] as int;
                          final meaning = type['meaning'] ?? '';
                          return DropdownMenuItem<int>(
                            value: id,
                            child: Text(meaning),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedFollowTypeId = value ?? 0;
                      });

                      
                      print('📌 Dropdown เลือกแล้ว: ${value ?? 'null'}');
                      print(
                        '📌 _selectedFollowTypeId ตอนนี้: $_selectedFollowTypeId',
                      );
                      print('📌 _followTypes: $_followTypes');
                      print('------------------------------------');
                    },
                    decoration: InputDecoration(
                      labelText: 'ประเภทการตาม',
                      prefixIcon: Icon(
                        Icons.assignment_turned_in,
                        color: Colors.amber.shade700,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Colors.amber.shade700,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 12),
                  TextFormField(
                    controller: _dueDateController,
                    decoration: InputDecoration(
                      labelText: 'วันที่นัดชำระ',
                      prefixIcon: Icon(
                        Icons.calendar_today,
                        color:
                            _dueDateController.text.isEmpty
                                ? Colors.orange
                                : Colors.orange, // ไอคอนจะเป็นสีส้มถ้าเลือกแล้ว
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey.shade300, // สีขอบเมื่อไม่ได้เลือก
                          width: 2.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.orange, // สีขอบเมื่อมีโฟกัส
                          width: 2.0,
                        ),
                      ),
                      labelStyle: TextStyle(
                        color:
                            _dueDateController.text.isEmpty
                                ? const Color.fromARGB(255, 15, 15, 15)
                                : Colors.orange, // สีตัวอักษรของ label
                      ),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context),
                  ),
                  SizedBox(height: 12),
                  _buildTextField(
                    label: 'จำนวนเงิน',
                    icon: Icons.money,
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกจำนวนเงิน';
                      }
                      if (!RegExp(r'^\d+\.00$').hasMatch(value)) {
                        return 'จำนวนเงินต้องลงท้ายด้วย .00';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    label: 'ค่าติดตาม',
                    icon: Icons.attach_money,
                    controller: _followFeeController,
                    keyboardType: TextInputType.number,
                    enabled: _isFollowFeeEditable, // สีเทาหรือไม่
                    readOnly: !_isFollowFeeEditable, // ปิดให้พิมพ์
                    validator: (value) {
                      if (!_isFollowFeeEditable) return null;
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกค่าติดตาม';
                      }
                      if (!RegExp(r'^\d+\.00$').hasMatch(value)) {
                        return 'ค่าติดตามต้องลงท้ายด้วย .00';
                      }
                      return null;
                    },
                  ),

                  _buildTextField(
                    label: 'ระยะไมล์',
                    icon: Icons.directions_car,
                    controller: _mileageController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),

                  _buildTextField(
                    label: 'สถานที่',
                    icon: Icons.location_on,
                    controller: locationController,
                    suffixIcon: IconButton(
                      icon: Icon(Icons.location_on),
                      onPressed: () async {
                        try {
                          // ขอ permission
                          LocationPermission permission =
                              await Geolocator.checkPermission();
                          if (permission == LocationPermission.denied) {
                            permission = await Geolocator.requestPermission();
                            if (permission == LocationPermission.denied ||
                                permission ==
                                    LocationPermission.deniedForever) {
                              print('Permission denied');
                              return;
                            }
                          }

                          // ตรวจสอบว่าเปิด Location Service อยู่ไหม
                          bool serviceEnabled =
                              await Geolocator.isLocationServiceEnabled();
                          if (!serviceEnabled) {
                            print('Location service disabled');
                            return;
                          }

                          // ดึงพิกัด
                          Position position =
                              await Geolocator.getCurrentPosition(
                                desiredAccuracy: LocationAccuracy.high,
                              );

                          double latitude = position.latitude;
                          double longitude = position.longitude;
                          print('latitude: $latitude, longtitude: $longitude');

                          // ดึงข้อมูลที่อยู่
                          List<Placemark> placemarks =
                              await placemarkFromCoordinates(
                                latitude,
                                longitude,
                                localeIdentifier: "th", // ใช้ locale ภาษาไทย
                              );

                          if (placemarks.isNotEmpty) {
                            Placemark place = placemarks.first;

                            print('locality: ${place.locality}');
                            print(
                              'subAdministrativeArea: ${place.subAdministrativeArea}',
                            );
                            print(
                              'administrativeArea: ${place.administrativeArea}',
                            );
                            print('postalCode: ${place.postalCode}');
                            print('country: ${place.country}');

                            String placeName =
                                '${place.locality ?? ''} ${place.subAdministrativeArea ?? ''} '
                                '${place.administrativeArea ?? ''} ${place.postalCode ?? ''} ${place.country ?? ''}\n'
                                'ละติจูด: $latitude, ลองจิจูด: $longitude';

                            // เซ็ตข้อความลง TextField
                            locationController.text = placeName.trim();
                          }
                        } catch (e) {
                          print('เกิดข้อผิดพลาดในการดึงตำแหน่ง: $e');
                        }
                      },
                    ),
                  ),

                  SizedBox(height: 16),

                  DropdownButtonFormField<bool>(
                    value: _isCompleted,
                    items: const [
                      DropdownMenuItem(
                        value: false,
                        child: Text('รอดำเนินการ'),
                      ),
                      DropdownMenuItem(value: true, child: Text('สำเร็จ')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _isCompleted = value!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'สถานะการดำเนินการ',
                      labelStyle: GoogleFonts.prompt(color: Colors.black),
                      prefixIcon: Icon(
                        Icons.check_circle_outline,
                        color: yellow,
                      ),
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
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: GoogleFonts.prompt(fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.prompt(),
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (!_isSaving) {
            _onItemTapped(index);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.save), label: 'บันทึก'),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'ถ่ายภาพ',
          ),
        ],
      ),
    );
  }
}
