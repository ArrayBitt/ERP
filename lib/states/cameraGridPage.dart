import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:image/image.dart' as img;
import 'package:http_parser/http_parser.dart';

class CameraGridPage extends StatefulWidget {
  final String contractno;
  final String? token; // รับ token ผ่าน constructor
  final List<String?>? videoFilenames; // ✅ เพิ่ม field นี้

  const CameraGridPage({
    Key? key,
    required this.contractno,
    this.token,
    this.videoFilenames, // ✅ รับ parameter
  }) : super(key: key);

  @override
  State<CameraGridPage> createState() => _CameraGridPageState();
}

class _CameraGridPageState extends State<CameraGridPage> {
  final ImagePicker _picker = ImagePicker();
  List<File?> _imageFiles = List.generate(6, (index) => null);
  List<TextEditingController> _textControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  bool _hasUploaded = false;

  String _getPrefKey() => 'imagePaths_${widget.contractno}';

  @override
  void initState() {
    super.initState();
    _loadSavedImages();
  }

  Future<bool> _requestAllPermissions() async {
    if (kIsWeb) return true;
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        var cameraStatus = await Permission.camera.status;
        var photosStatus = await Permission.photos.status;
        if (!cameraStatus.isGranted)
          cameraStatus = await Permission.camera.request();
        if (!photosStatus.isGranted)
          photosStatus = await Permission.photos.request();
        return cameraStatus.isGranted && photosStatus.isGranted;
      } else {
        var cameraStatus = await Permission.camera.status;
        var storageStatus = await Permission.storage.status;
        if (!cameraStatus.isGranted)
          cameraStatus = await Permission.camera.request();
        if (!storageStatus.isGranted)
          storageStatus = await Permission.storage.request();
        return cameraStatus.isGranted && storageStatus.isGranted;
      }
    } else if (Platform.isIOS) {
      var cameraStatus = await Permission.camera.status;
      var photosStatus = await Permission.photos.status;
      if (!cameraStatus.isGranted)
        cameraStatus = await Permission.camera.request();
      if (!photosStatus.isGranted)
        photosStatus = await Permission.photos.request();
      return cameraStatus.isGranted && photosStatus.isGranted;
    }
    return false;
  }

  Future<void> _loadSavedImages() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedPaths =
        prefs.getStringList(_getPrefKey()) ?? List.filled(6, '');
    List<File?> tempFiles = List.generate(6, (index) => null);

    for (int i = 0; i < savedPaths.length; i++) {
      String pathStr = savedPaths[i];
      if (pathStr.isNotEmpty) {
        File file = File(pathStr);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final decoded = img.decodeImage(bytes);
          if (decoded != null) tempFiles[i] = file;
        }
      }
    }

    setState(() {
      _imageFiles = tempFiles;
    });
  }

  Future<void> _saveImagePath(int index, String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedPaths =
        prefs.getStringList(_getPrefKey()) ?? List.filled(6, '');
    savedPaths[index] = imagePath;
    await prefs.setStringList(_getPrefKey(), savedPaths);
  }

  Future<void> _pickImage(int index, ImageSource source) async {
    bool granted = await _requestAllPermissions();
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('โปรดให้สิทธิ์การเข้าถึงรูปภาพ')),
      );
      return;
    }

    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final original = img.decodeImage(bytes);
      if (original == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ ไม่สามารถ decode รูปภาพได้')),
        );
        return;
      }

      final resized = img.copyResize(original, width: 1024);
      final jpgBytes = img.encodeJpg(resized, quality: 85);

      final directory = await getApplicationDocumentsDirectory();
      final newPath = path.join(
        directory.path,
        '${widget.contractno}_${String.fromCharCode(65 + index)}.jpg',
      );
      final file = File(newPath);
      await file.writeAsBytes(jpgBytes);

      setState(() => _imageFiles[index] = file);
      await _saveImagePath(index, newPath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('บันทึกภาพ ${path.basename(newPath)} เรียบร้อย'),
        ),
      );
    }
  }

  Future<void> _uploadAllImages() async {
    try {
      final url =
          "https://erp.somjai.app/api/debttrackings/upload/file/car/tracking";

      String? token = widget.token;
      if (token == null) {
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString('jwt_token');
      }

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่พบ token สำหรับการอัปโหลด')),
        );
        return;
      }

      token = token.trim();

      final request = http.MultipartRequest('POST', Uri.parse(url))
        ..headers.addAll({
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        });

      int fileCount = 0;
      for (var file in _imageFiles) {
        if (file != null && await file.exists()) {
          final bytes = await file.readAsBytes();
          final original = img.decodeImage(bytes);
          if (original == null) continue;

          final resized = img.copyResize(original, width: 1024);
          final jpgBytes = img.encodeJpg(resized, quality: 85);

          final tempFile = File('${file.path}');
          await tempFile.writeAsBytes(jpgBytes);

          request.files.add(
            await http.MultipartFile.fromPath(
              'files',
              tempFile.path,
              contentType: MediaType('image', 'jpeg'),
            ),
          );

          fileCount++;
        }
      }

      if (fileCount == 0) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ไม่มีไฟล์ให้ส่ง')));
        return;
      }

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      print('📡 Response (${response.statusCode}): $respStr');

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _hasUploaded = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ อัปโหลดล้มเหลว (${response.statusCode})')),
        );
      }
    } catch (e) {
      print('⚠️ Upload error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    }
  }

  Future<void> _removeImage(int index) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedPaths =
        prefs.getStringList(_getPrefKey()) ?? List.filled(6, '');
    savedPaths[index] = '';
    await prefs.setStringList(_getPrefKey(), savedPaths);

    setState(() {
      _imageFiles[index] = null;
      _textControllers[index].clear();
    });
  }

  Future<void> _confirmDeleteImage(int index) async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('ยืนยันการลบรูปภาพ'),
            content: Text(
              'คุณต้องการลบรูปภาพ ${widget.contractno}_${String.fromCharCode(65 + index)} ใช่ไหม?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ยกเลิก'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  await _removeImage(index);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ลบรูปภาพเรียบร้อย ✅')),
                  );
                },
                child: const Text('ลบ'),
              ),
            ],
          ),
    );
  }

  Future<void> _confirmDeleteAllImages() async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('ยืนยันการลบรูปภาพทั้งหมด'),
            content: const Text('คุณต้องการลบรูปภาพทั้งหมดใช่ไหม?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ยกเลิก'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  for (int i = 0; i < _imageFiles.length; i++) {
                    if (_imageFiles[i] != null) await _removeImage(i);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ลบรูปภาพทั้งหมดเรียบร้อย ✅')),
                  );
                },
                child: const Text('ลบทั้งหมด'),
              ),
            ],
          ),
    );
  }

  Future<void> _uploadOnBack() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Row(
              children: const [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Expanded(child: Text('กำลังอัปโหลดรูป...')),
              ],
            ),
          ),
    );

    await _uploadAllImages();

    Navigator.pop(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: const Text('อัปโหลดสำเร็จ ✅'),
          ),
    );

    await Future.delayed(const Duration(seconds: 2));
    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final yellow = Colors.amber.shade700;
    return WillPopScope(
      onWillPop: () async {
        _uploadOnBack();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '📷 ภาพถ่าย (${widget.contractno})',
            style: GoogleFonts.prompt(),
          ),
          backgroundColor: yellow,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.cloud_upload),
              onPressed: _uploadAllImages,
            ),
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: _confirmDeleteAllImages,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.75,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _pickImage(index, ImageSource.camera),
                onLongPress:
                    () =>
                        _imageFiles[index] != null
                            ? _confirmDeleteImage(index)
                            : null,
                child: Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Expanded(
                          child:
                              _imageFiles[index] != null
                                  ? Image.file(
                                    _imageFiles[index]!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  )
                                  : const Icon(Icons.photo_camera, size: 50),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.contractno}_${String.fromCharCode(65 + index)}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
