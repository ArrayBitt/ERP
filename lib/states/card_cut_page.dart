import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';

class CardCutPage extends StatefulWidget {
  final Uint8List pdfBytes;

  const CardCutPage({Key? key, required this.pdfBytes}) : super(key: key);

  @override
  _CardCutPageState createState() => _CardCutPageState();
}

class _CardCutPageState extends State<CardCutPage> {
  String? localFilePath;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    savePDF();
  }

  Future<void> savePDF() async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/cardcut_temp.pdf');
    await file.writeAsBytes(widget.pdfBytes, flush: true);
    setState(() {
      localFilePath = file.path;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('การ์ดชำระลูกหนี้')),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : PDFView(filePath: localFilePath!),
    );
  }
}
