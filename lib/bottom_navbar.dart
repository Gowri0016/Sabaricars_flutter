import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  const BottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF2563eb),
      unselectedItemColor: Color(0xFF555555),
      selectedFontSize: 13,
      unselectedFontSize: 12,
      elevation: 12,
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Feather.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Feather.grid), label: 'Categories'),
        BottomNavigationBarItem(icon: Icon(Feather.search), label: 'Search'),
        BottomNavigationBarItem(icon: Icon(Feather.heart), label: 'Wishlist'),
        BottomNavigationBarItem(icon: Icon(Feather.user), label: 'Profile'),
      ],
    );
  }
}
