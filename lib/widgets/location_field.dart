import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationField extends StatelessWidget {
  final TextEditingController controller;

  const LocationField({Key? key, required this.controller}) : super(key: key);

  Future<void> _getCurrentLocation(BuildContext context) async {
    try {
      // ขอ permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          print('Permission denied');
          return;
        }
      }

      // ตรวจสอบว่าเปิด Location Service อยู่ไหม
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location service disabled');
        return;
      }

      // ดึงพิกัด
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double latitude = position.latitude;
      double longitude = position.longitude;
      print('latitude: $latitude, longitude: $longitude');

      // ดึงข้อมูลที่อยู่
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
        localeIdentifier: "th",
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        String placeName =
            '${place.locality ?? ''} ${place.subAdministrativeArea ?? ''} '
            '${place.administrativeArea ?? ''} ${place.postalCode ?? ''} ${place.country ?? ''}\n'
            'ละติจูด: $latitude, ลองจิจูด: $longitude';

        // เซ็ตข้อความลง TextField
        controller.text = placeName.trim();
      }
    } catch (e) {
      print('เกิดข้อผิดพลาดในการดึงตำแหน่ง: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        style: GoogleFonts.prompt(),
        decoration: InputDecoration(
          labelText: 'สถานที่',
          prefixIcon: IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: () => _getCurrentLocation(context),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(14),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber.shade700, width: 1.5),
            borderRadius: BorderRadius.circular(14),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'กรุณากรอกสถานที่';
          }
          return null;
        },
      ),
    );
  }
}
