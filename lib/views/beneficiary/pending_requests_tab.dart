import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';

class PendingRequestsTab extends StatefulWidget {
  const PendingRequestsTab({super.key});

  @override
  State<PendingRequestsTab> createState() => _PendingRequestsTabState();
}

class _PendingRequestsTabState extends State<PendingRequestsTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final user =
          Provider.of<AuthProvider>(context, listen: false).currentUser;
      final beneficiaryId = user?.beneficiaryId ?? 1;
      Provider.of<RequestProvider>(
        context,
        listen: false,
      ).fetchMyRequests(beneficiaryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final requestProvider = Provider.of<RequestProvider>(context);

    // 🔥 فرض اتجاه التطبيق بالكامل من اليمين لليسار (RTL)
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            "طلبات قيد الانتظار",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: const Color(0xFF14532D),
          centerTitle: true,
          elevation: 0,
        ),
        body:
            requestProvider.isLoading
                ? const Center(
                  child: SpinKitFadingCircle(
                    color: AppColors.primary,
                    size: 50,
                  ),
                )
                : requestProvider.pendingRequests.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.hourglass_empty_rounded,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "لا توجد طلبات قيد الانتظار حالياً.",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
                : RefreshIndicator(
                  onRefresh: () async {
                    final user =
                        Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        ).currentUser;
                    await requestProvider.fetchMyRequests(
                      user?.beneficiaryId ?? 1,
                    );
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: requestProvider.pendingRequests.length,
                    itemBuilder: (context, index) {
                      final req = requestProvider.pendingRequests[index];
                      final serialNumber = index + 1; // الرقم التسلسلي التكراري

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // رقم الطلب التسلسلي في اليمين
                                  Text(
                                    "رقم الطلب: $serialNumber",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryDark,
                                      fontSize: 16,
                                    ),
                                  ),
                                  // لون أصفر هادئ وجميل للحالة
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFFEF3C7,
                                      ), // أصفر فاتح وهادئ جداً
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFFF59E0B),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: const Text(
                                      "قيد الانتظار",
                                      style: TextStyle(
                                        color: Color(
                                          0xFFB45309,
                                        ), // أصفر غامق ومريح للعين
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              // تفاصيل الوصف متجهة من اليمين
                              Row(
                                children: [
                                  const Icon(
                                    Icons.storefront,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "المطعم: ${req.restaurantName}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.fastfood,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "الوجبة: ${req.foodName}",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "الكمية المطلوبة: ${req.quantity} وجبة",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),

                              // 🔥 تاريخ الصلاحية للوجبة بعد الكمية
                              if (req.expiryTime != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.event_busy_outlined,
                                      size: 18,
                                      color: Color(0xFFDC2626),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "تاريخ الصلاحية: ${req.expiryTime.toString().split(' ')[0]}",
                                      style: const TextStyle(
                                        color: Color(0xFFDC2626),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],

                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "تاريخ الطلب: ${req.requestTime.toString().split(' ')[0]}",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),

                              // 🔥 وقت الحجز بعد تاريخ الطلب
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time_rounded,
                                    size: 18,
                                    color: Color(0xFF0284C7),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "وقت الحجز: ${TimeOfDay.fromDateTime(req.requestTime).format(context)}",
                                    style: const TextStyle(
                                      color: Color(0xFF0284C7),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      ),
    );
  }
}
