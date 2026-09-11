import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/food_provider.dart';
import '../../providers/request_provider.dart';
import 'add_food_screen.dart';

class RestaurantDashboardScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;
  const RestaurantDashboardScreen({super.key, this.onNavigateTab});

  @override
  State<RestaurantDashboardScreen> createState() =>
      _RestaurantDashboardScreenState();
}

class _RestaurantDashboardScreenState extends State<RestaurantDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // 🔥 استخدام Future.microtask بنفس أسلوب شاشة الجمعية لطلب البيانات فوراً وبشكل متوازي
    Future.microtask(() {
      final user =
          Provider.of<AuthProvider>(context, listen: false).currentUser;
      final restaurantId = user?.restaurantId ?? 1;

      Provider.of<FoodProvider>(context, listen: false).fetchAvailableFoods();
      Provider.of<RequestProvider>(
        context,
        listen: false,
      ).fetchMyRequests(restaurantId);
    });
  }

  String _formatDate(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final foodProvider = Provider.of<FoodProvider>(context);
    final requestProvider = Provider.of<RequestProvider>(context);
    final user = authProvider.currentUser;

    // تصفية الوجبات التابعة لهذا المطعم
    final restaurantFoods =
        foodProvider.availableFoods.where((food) {
          return (user?.restaurantId != null &&
                  food.restaurantId == user!.restaurantId) ||
              (user?.restaurantName != null &&
                  food.restaurantName.trim().toLowerCase() ==
                      user!.restaurantName!.trim().toLowerCase());
        }).toList();

    final totalMealsCount = restaurantFoods.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
    final pendingCount = requestProvider.pendingRequests.length;
    final deliveredCount = requestProvider.deliveredRequests.length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            "لوحة تحكم المطعم المانح",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: AppColors.primaryDark,
          centerTitle: true,
          elevation: 0,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            final restaurantId = user?.restaurantId ?? 1;
            await foodProvider.fetchAvailableFoods();
            await requestProvider.fetchMyRequests(restaurantId);
          },
          color: AppColors.primary,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // كرت الترحيب وهوية المطعم
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "مرحباً بك، ${user?.username ?? 'مدير المطعم'}",
                              style: const TextStyle(
                                color: AppColors.primaryDark,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "معاً للحد من الهدر وإيصال النعم لمستحقيها 🌿",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.storefront,
                              color: AppColors.primaryDark,
                              size: 15,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              user?.restaurantName ?? "مطعم معتمد",
                              style: const TextStyle(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // الكروت الإحصائية الثلاثة
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: "الوجبات المعروضة",
                        count: "$totalMealsCount",
                        color: AppColors.primary,
                        icon: Icons.fastfood_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatCard(
                        title: "قيد الانتظار",
                        count: "$pendingCount",
                        color: const Color(0xFFD97706),
                        icon: Icons.hourglass_top_rounded,
                        onTap: () {
                          if (widget.onNavigateTab != null) {
                            widget.onNavigateTab!(1);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatCard(
                        title: "تم تسليمها",
                        count: "$deliveredCount",
                        color: const Color(0xFF0284C7),
                        icon: Icons.done_all_rounded,
                        onTap: () {
                          if (widget.onNavigateTab != null) {
                            widget.onNavigateTab!(1);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // زر الإضافة السريع
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddFoodScreen(),
                        ),
                      ).then((_) {
                        final restId = user?.restaurantId ?? 1;
                        foodProvider.fetchAvailableFoods();
                        requestProvider.fetchMyRequests(restId);
                      });
                    },
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "إضافة وجبة فائضة جديدة",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 26),

                // قسم الوجبات المعروضة
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          color: AppColors.primaryDark,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "وجباتك المعروضة حالياً",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "${restaurantFoods.length} أصناف",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                foodProvider.isLoading
                    ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: SpinKitFadingCircle(
                          color: AppColors.primary,
                          size: 40,
                        ),
                      ),
                    )
                    : restaurantFoods.isEmpty
                    ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(36),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.fastfood_outlined,
                            size: 54,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "لا توجد وجبات معروضة لمطعمك حالياً",
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "اضغط على زر الإضافة لنشر فائض الأطعمة للجمعيات",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: restaurantFoods.length,
                      itemBuilder: (context, index) {
                        final food = restaurantFoods[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.restaurant,
                                  color: AppColors.primaryDark,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      food.foodName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          "الكمية: ${food.quantity} وجبة",
                                          style: const TextStyle(
                                            color: Color(0xFF475569),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (food.expiryTime != null) ...[
                                          const SizedBox(width: 10),
                                          Text(
                                            "• تنتهي: ${_formatDate(food.expiryTime!)}",
                                            style: const TextStyle(
                                              color: AppColors.error,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  "متاح للحجز",
                                  style: TextStyle(
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String count,
    required Color color,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              count,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
