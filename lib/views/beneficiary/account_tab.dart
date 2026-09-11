import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class AccountTab extends StatelessWidget {
  const AccountTab({super.key});

  String _getArabicRoleName(String? role) {
    if (role == null) return 'مستخدم معتمد';
    switch (role.toLowerCase()) {
      case 'superadmin':
      case 'admin':
        return 'مدير النظام (SuperAdmin)';
      case 'restaurantmanager':
        return 'مدير مطعم';
      case 'employee':
        return 'موظف في مطعم';
      case 'beneficiarymanager':
        return 'مدير جمعية خيرية';
      case 'beneficiaryemployee':
        return 'مندوب جمعية خيرية';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final arabicRole = _getArabicRoleName(user?.role);

    final displayName =
        (user?.restaurantName != null &&
                user!.restaurantName!.isNotEmpty &&
                user.restaurantName != 'مطعم')
            ? user.restaurantName!
            : ((user?.beneficiaryName != null &&
                    user!.beneficiaryName!.isNotEmpty &&
                    user.beneficiaryName != 'جمعية')
                ? user.beneficiaryName!
                : arabicRole);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // 🔥 استخدام لون الخلفية من AppColors
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            "حسابي الشخصي",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          // 🔥 استخدام اللون الأساسي الغامق
          backgroundColor: AppColors.primaryDark,
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 95,
                      height: 95,
                      decoration: BoxDecoration(
                        // 🔥 استخدام درجات اللون الأساسي
                        color: AppColors.primary.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.storefront_rounded,
                        size: 50,
                        color: AppColors.primaryDark, // 🔥 أيقونة المتجر
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary, // 🔥 شارة التوثيق
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user?.username ?? 'مستخدم النظام',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  displayName,
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // بطاقة بيانات الحساب
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildInfoTile(
                      icon: Icons.person_outline,
                      title: "اسم المستخدم",
                      value: user?.username ?? 'غير متوفر',
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildInfoTile(
                      icon: Icons.storefront_outlined,
                      title: "الجهة التابع لها",
                      value: displayName,
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildInfoTile(
                      icon: Icons.admin_panel_settings_outlined,
                      title: "الدور / الصلاحية",
                      value: arabicRole,
                      valueColor: AppColors.primaryDark, // 🔥 لون الدور
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildInfoTile(
                      icon: Icons.security_outlined,
                      title: "حالة الحساب",
                      value: "نشط ومعتمد",
                      valueColor: AppColors.primary, // 🔥 لون الحالة
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // زر تسجيل الخروج الآمن
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _showLogoutDialog(context),
                  icon: const Icon(Icons.logout_rounded, color: Colors.white),
                  label: const Text(
                    "تسجيل الخروج",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error, // 🔥 زر الخروج الأحمر
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    Color valueColor = const Color(0xFF1E293B),
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryDark, size: 20), // 🔥
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(Icons.logout, color: AppColors.error, size: 24), // 🔥
                  SizedBox(width: 8),
                  Text(
                    "تسجيل الخروج",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: const Text(
                "هل أنت متأكد من رغبتك في تسجيل الخروج من التطبيق؟",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    "إلغاء",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.error, // 🔥 زر الخروج في الـ Dialog
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    ).logout();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                  child: const Text(
                    "تأكيد الخروج",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
