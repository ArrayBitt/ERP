import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ContractImagePage extends StatefulWidget {
  final String contractNo;
  const ContractImagePage({Key? key, required this.contractNo})
    : super(key: key);

  @override
  State<ContractImagePage> createState() => _ContractImagePageState();
}

class _ContractImagePageState extends State<ContractImagePage> {
  String? _selectedDocumentType;
  List<Map<String, dynamic>> _images = [];

  // ==========================
  // GET IMAGE BY TYPE
  // ==========================
  Future<void> _getImagesByType(String documentType) async {
    setState(() => _images = []);

    print('==========================');
    print('Selected DocumentType: $documentType');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) {
        print('❌ Token not found');
        return;
      }

      final int docTypeInt =
          int.tryParse(documentType.replaceAll('.', '')) ?? -1;

      // --------------------------
      // API 1 : GET IMAGE PATH
      // --------------------------
      final api1 =
          'https://erp.somjai.app/api/requestforms/get/imagesrequest/161';

      final res1 = await http.get(
        Uri.parse(api1),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res1.statusCode != 200) {
        print('❌ API1 failed');
        return;
      }

      final List list = jsonDecode(res1.body);
      print('API1 item count: ${list.length}');

      String? imagePath;
      for (final item in list) {
        if (item['imagetypes_id'].toString() == docTypeInt.toString()) {
          imagePath = item['imagepath'];
          break;
        }
      }

      if (imagePath == null) {
        print('❌ ไม่พบรูปสำหรับ type $documentType');
        return;
      }

      // --------------------------
      // API 2 : LOAD IMAGE (STREAM)
      // --------------------------
      final api2 =
          'https://erp.somjai.app/api/requestforms/get/images/request/path'
          '?imagepath=$imagePath';

      print('Calling API2: $api2');

      final request = http.Request('GET', Uri.parse(api2));
      request.headers['Authorization'] = 'Bearer $token';

      final response = await request.send();

      if (response.statusCode == 200) {
        final Uint8List bytes = await response.stream.toBytes();
        print('✅ Image loaded: ${bytes.length} bytes');

        setState(() {
          _images = [
            {'bytes': bytes, 'name': imagePath!.split('/').last},
          ];
        });
      } else {
        print('❌ API2 failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR: $e');
    }
  }

  // ==========================
  // UI
  // ==========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '📷 ภาพสัญญา: ${widget.contractNo}',
          style: GoogleFonts.prompt(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedDocumentType,
              decoration: InputDecoration(
                labelText: 'เลือกประเภทเอกสาร',
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onChanged: (v) {
                _selectedDocumentType = v;
                if (v != null) _getImagesByType(v);
              },
              items: _dropdownItems(),
            ),
            const SizedBox(height: 20),
            Expanded(
              child:
                  _images.isEmpty
                      ? Center(
                        child: Text(
                          'ไม่พบรูปภาพ',
                          style: GoogleFonts.prompt(color: Colors.grey),
                        ),
                      )
                      : ListView.builder(
                        itemCount: _images.length,
                        itemBuilder: (_, i) {
                          final img = _images[i];
                          return Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            margin: const EdgeInsets.only(bottom: 20),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                  child: Image.memory(
                                    img['bytes'] as Uint8List,
                                    height: 400,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    img['name'],
                                    style: GoogleFonts.prompt(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _dropdownItems() {
    final map = {
      '01': 'บปช.คนซื้อ',
      '02': 'บปช.คนใช้',
      '03': 'บปช.คนค้ำ',
      '04': 'ทบบ.หน้าแรกคนซื้อ',
      '05': 'ทบบ.หน้าที่มีชื่อคนซื้อ',
      '06': 'ทบบ.หน้าแรกคนใช้',
      '07': 'ทบบ.หน้าที่มีคนใช้',
      '08': 'ทบบ.หน้าแรกคนค้ำ',
      '09': 'ทบบ.หน้าที่มีชื่อคนค้ำ',
      '10': 'รูปถ่ายคนซื้อ',
      '11': 'รูปถ่ายคนใช้',
      '12': 'รูปถ่ายคนค้ำ',
      '13': 'รูปถ่ายอาชีพ',
    };

    return map.entries
        .map(
          (e) => DropdownMenuItem(
            value: e.key,
            child: Text(e.value, style: GoogleFonts.prompt()),
          ),
        )
        .toList();
  }
}
