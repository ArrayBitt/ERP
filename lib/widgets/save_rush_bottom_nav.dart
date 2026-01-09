import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SaveRushBottomNav extends StatelessWidget {
  final int selectedIndex;
  final bool isSaving;
  final Function(int) onItemTapped;

  const SaveRushBottomNav({
    Key? key,
    required this.selectedIndex,
    required this.isSaving,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final yellow = Colors.amber.shade700;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.amber[800],
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      selectedLabelStyle: GoogleFonts.prompt(fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.prompt(),
      currentIndex: selectedIndex,
      onTap: (index) {
        if (!isSaving) {
          onItemTapped(index);
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.save), label: 'บันทึก'),
        BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'ถ่ายภาพ'),
      ],
    );
  }
}
