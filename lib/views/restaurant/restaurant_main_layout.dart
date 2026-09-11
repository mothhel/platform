import 'package:flutter/material.dart';
import 'package:neam_platform/views/beneficiary/account_tab.dart';
import '../../core/constants/app_colors.dart';
import 'restaurant_dashboard_screen.dart';
import 'restaurant_requests_screen.dart';
import 'add_food_screen.dart';

class RestaurantMainLayout extends StatefulWidget {
  const RestaurantMainLayout({super.key});

  @override
  State<RestaurantMainLayout> createState() => _RestaurantMainLayoutState();
}

class _RestaurantMainLayoutState extends State<RestaurantMainLayout> {
  int _currentIndex = 0;
  DateTime? _lastBackPressTime; // 🔥 لتتبع وقت آخر نقرة على زر الرجوع

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      RestaurantDashboardScreen(onNavigateTab: (index) => _changeTab(index)),
      const RestaurantRequestsScreen(),
      const AddFoodScreen(),
      const AccountTab(),
    ];
  }

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      // 🔥 التعامل الذكي مع الرجوع بنقرتين
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;

          // إذا كان المستخدم في تبويب آخر غير الرئيسية، يرجعه للرئيسية أولاً
          if (_currentIndex != 0) {
            _changeTab(0);
            return;
          }

          final now = DateTime.now();
          if (_lastBackPressTime == null ||
              now.difference(_lastBackPressTime!) >
                  const Duration(seconds: 2)) {
            _lastBackPressTime = now;
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "اضغط مرة أخرى للخروج من التطبيق",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.primaryDark.withOpacity(0.92),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            );
          } else {
            // الخروج النهائي عند النقر مرتين متتاليتين
            Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          body: IndexedStack(index: _currentIndex, children: _screens),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                indicatorColor: AppColors.primary.withOpacity(0.18),
                labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
                  (Set<WidgetState> states) => TextStyle(
                    fontSize: 12,
                    fontWeight:
                        states.contains(WidgetState.selected)
                            ? FontWeight.bold
                            : FontWeight.w500,
                    color:
                        states.contains(WidgetState.selected)
                            ? AppColors.primaryDark
                            : Colors.grey[600],
                  ),
                ),
              ),
              child: NavigationBar(
                height: 68,
                elevation: 0,
                backgroundColor: Colors.white,
                selectedIndex: _currentIndex,
                onDestinationSelected: _changeTab,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.dashboard_outlined, color: Colors.grey),
                    selectedIcon: Icon(
                      Icons.dashboard_rounded,
                      color: AppColors.primaryDark,
                    ),
                    label: "الرئيسية",
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.receipt_long_outlined, color: Colors.grey),
                    selectedIcon: Icon(
                      Icons.receipt_long_rounded,
                      color: AppColors.primaryDark,
                    ),
                    label: "طلبات الحجز",
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.add_circle_outline_rounded,
                      color: Colors.grey,
                    ),
                    selectedIcon: Icon(
                      Icons.add_circle_rounded,
                      color: AppColors.primaryDark,
                    ),
                    label: "إضافة وجبة",
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.person_outline_rounded,
                      color: Colors.grey,
                    ),
                    selectedIcon: Icon(
                      Icons.person_rounded,
                      color: AppColors.primaryDark,
                    ),
                    label: "حسابي",
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
