import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../providers/food_provider.dart';
import '../../providers/request_provider.dart';
import '../../models/restaurant_model.dart';
import 'restaurant_menu_screen.dart';

class RestaurantsScreen extends StatefulWidget {
  const RestaurantsScreen({super.key});

  @override
  State<RestaurantsScreen> createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends State<RestaurantsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final user =
          Provider.of<AuthProvider>(context, listen: false).currentUser;
      final beneficiaryId = user?.beneficiaryId ?? 1;

      Provider.of<RestaurantProvider>(
        context,
        listen: false,
      ).fetchRestaurants();
      Provider.of<FoodProvider>(context, listen: false).fetchAvailableFoods();
      Provider.of<RequestProvider>(
        context,
        listen: false,
      ).fetchMyRequests(beneficiaryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    final restProvider = Provider.of<RestaurantProvider>(context);
    final foodProvider = Provider.of<FoodProvider>(context);
    final requestProvider = Provider.of<RequestProvider>(context);

    // عداد قيد الانتظار الحقيقي
    final pendingCount = requestProvider.pendingRequests.length;

    // عداد الطلبات المستلمة/المكتملة الحقيقي
    // عداد الطلبات المستلمة الحقيقي من الـ Provider الخاص بك
    final deliveredCount = requestProvider.deliveredRequests.length;

    // استخراج ذكي للمطاعم في حال كانت القائمة فارغة
    List<RestaurantModel> activeRestaurants = restProvider.restaurants;
    if (activeRestaurants.isEmpty && foodProvider.groupedFoods.isNotEmpty) {
      int tempId = 1;
      activeRestaurants =
          foodProvider.groupedFoods.keys.map((name) {
            return RestaurantModel(
              id: tempId++,
              name: name,
              address: "المطاعم المشاركة",
              isActive: true,
            );
          }).toList();
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text(
            "لوحة الجمعية الخيرية",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: const Color(0xFF14532D),
          centerTitle: true,
          elevation: 0,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            final beneficiaryId = user?.beneficiaryId ?? 1;
            await restProvider.fetchRestaurants();
            await foodProvider.fetchAvailableFoods();
            await requestProvider.fetchMyRequests(beneficiaryId);
          },
          color: AppColors.primary,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. كرت الترحيب
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
                              "مرحباً بك، ${user?.username ?? 'مندوب الجمعية'}",
                              style: const TextStyle(
                                color: Color(0xFF14532D),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "جاهزون لاستقبال وتنسيق فائض الأطعمة",
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
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF22C55E),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.volunteer_activism,
                              color: Color(0xFF166534),
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            // 🔥 تم استبدال "مسجل معتمد" باسم الجمعية الحقيقي هنا
                            Text(
                              user?.beneficiaryName ?? "جمعية خيرية معتمدة",
                              style: const TextStyle(
                                color: Color(0xFF166534),
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 20),

                // 2. كروت الإحصائيات (الوجبات المتاحة تحسب عدد الأصناف length)
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        "الوجبات المتاحة",
                        "${foodProvider.availableFoods.length}", // 🔥 تم التعديل هنا ليحسب عدد الأصناف
                        const Color(0xFF16A34A),
                        Icons.inventory_2_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatCard(
                        "قيد الانتظار",
                        "$pendingCount",
                        const Color(0xFFD97706),
                        Icons.hourglass_empty,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatCard(
                        "المستلمة",
                        "$deliveredCount", // 🔥 تم تفعيل العداد الحقيقي للمستلمة
                        const Color(0xFF0284C7),
                        Icons.check_circle_outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. عنوان قسم المطاعم
                const Row(
                  children: [
                    Icon(Icons.storefront, color: Color(0xFF14532D), size: 20),
                    SizedBox(width: 8),
                    Text(
                      "المطاعم المشاركة المانحة",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF14532D),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 4. عرض قائمة المطاعم
                restProvider.isLoading && foodProvider.isLoading
                    ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: SpinKitFadingCircle(
                          color: Color(0xFF22C55E),
                          size: 40,
                        ),
                      ),
                    )
                    : activeRestaurants.isEmpty
                    ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.store_outlined,
                            size: 50,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text(
                            "لا توجد مطاعم مسجلة أو وجبات متاحة حالياً.",
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: activeRestaurants.length,
                      itemBuilder: (context, index) {
                        final restaurant = activeRestaurants[index];

                        final availableCount = foodProvider.availableFoods
                            .where(
                              (f) =>
                                  f.restaurantId == restaurant.id ||
                                  f.restaurantName == restaurant.name,
                            )
                            .fold(0, (sum, f) => sum + f.quantity);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
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
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => RestaurantMenuScreen(
                                        restaurant: restaurant,
                                      ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0FDF4),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFBBF7D0),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.storefront,
                                      color: Color(0xFF166534),
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          restaurant.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          restaurant.address ?? "الموقع العام",
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                availableCount > 0
                                                    ? const Color(0xFFDCFCE7)
                                                    : const Color(0xFFFEE2E2),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            availableCount > 0
                                                ? "$availableCount وجبة فائضة متاحة"
                                                : "لا توجد وجبات حالياً",
                                            style: TextStyle(
                                              color:
                                                  availableCount > 0
                                                      ? const Color(0xFF166534)
                                                      : const Color(0xFF991B1B),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_back_ios_new,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
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

  Widget _buildStatCard(
    String title,
    String count,
    Color color,
    IconData icon,
  ) {
    return Container(
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
    );
  }
}
