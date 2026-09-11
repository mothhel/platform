import 'package:flutter/material.dart';
import 'package:neam_platform/views/beneficiary/account_tab.dart';
import 'package:neam_platform/views/beneficiary/completed_requests_screen.dart';
import 'package:neam_platform/views/beneficiary/restaurants_screen.dart';
import '../../core/constants/app_colors.dart';
import 'pending_requests_tab.dart'; // قيد الانتظار

class BeneficiaryMainLayout extends StatefulWidget {
  const BeneficiaryMainLayout({super.key});
  @override
  State<BeneficiaryMainLayout> createState() => _BeneficiaryMainLayoutState();
}

class _BeneficiaryMainLayoutState extends State<BeneficiaryMainLayout> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    RestaurantsScreen(), // التبويبة الأولى (عرض المطاعم أولاً)
    PendingRequestsTab(), // طلبات قيد الانتظار
    CompletedRequestsScreen(),
    AccountTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey[400],
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_filled),
                label: "الرئيسية",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.hourglass_top_rounded),
                label: "قيد الانتظار",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.check_circle_rounded),
                label: "المستلمة",
              ),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: "حسابي"),
            ],
          ),
        ),
      ),
    );
  }
}
