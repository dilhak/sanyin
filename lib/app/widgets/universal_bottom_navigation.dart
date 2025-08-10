import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UniversalBottomNavigation extends StatelessWidget {
  final int currentIndex;

  const UniversalBottomNavigation({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              if (currentIndex != 0) Get.offAllNamed('/home');
              break;
            case 1:
              if (currentIndex != 1) Get.toNamed('/client/dashboard');
              break;
            case 2:
              if (currentIndex != 2) Get.toNamed('/tasks');
              break;
            case 3:
              Get.snackbar(
                'Info',
                'Settings coming soon',
                backgroundColor: Colors.blue[100],
                colorText: Colors.blue[800],
              );
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue[600],
        unselectedItemColor: Colors.grey[600],
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Homes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Clients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
} 