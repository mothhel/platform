import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';
import '../../models/request_item_model.dart';

class RestaurantRequestsScreen extends StatefulWidget {
  const RestaurantRequestsScreen({super.key});

  @override
  State<RestaurantRequestsScreen> createState() =>
      _RestaurantRequestsScreenState();
}

class _RestaurantRequestsScreenState extends State<RestaurantRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRequests();
    });
  }

  Future<void> _loadRequests() async {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    final restaurantId = user?.restaurantId ?? 0;
    if (restaurantId > 0) {
      await Provider.of<RequestProvider>(
        context,
        listen: false,
      ).fetchMyRequests(restaurantId);
    }
  }

  String _formatDate(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
  }

  String _formatTime(DateTime dt) {
    final int hour =
        dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final String period = dt.hour >= 12 ? "م" : "ص";
    final String minute = dt.minute.toString().padLeft(2, '0');
    return "$hour:$minute $period";
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final requestProvider = Provider.of<RequestProvider>(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            "إدارة طلبات الحجز والاستلام",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: AppColors.primaryDark,
          centerTitle: true,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.hourglass_top_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "قيد الانتظار (${requestProvider.pendingRequests.length})",
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "المكتملة (${requestProvider.deliveredRequests.length})",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body:
            requestProvider.isLoading
                ? const Center(
                  child: SpinKitFadingCircle(
                    color: AppColors.primary,
                    size: 45,
                  ),
                )
                : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRequestsList(
                      requests: requestProvider.pendingRequests,
                      isPending: true,
                    ),
                    _buildRequestsList(
                      requests: requestProvider.deliveredRequests,
                      isPending: false,
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildRequestsList({
    required List<RequestItemModel> requests,
    required bool isPending,
  }) {
    if (requests.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadRequests,
        color: AppColors.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 160),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isPending
                        ? Icons.hourglass_empty_rounded
                        : Icons.inventory_2_outlined,
                    size: 60,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isPending
                        ? "لا توجد طلبات حجز قيد الانتظار حالياً."
                        : "لا توجد طلبات مكتملة أو مستلمة حتى الآن.",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRequests,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final req = requests[index];
          final serialNum = index + 1;

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // رأس البطاقة
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "طلب حجز رقم #$serialNum",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                          fontSize: 15,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isPending
                                  ? const Color(0xFFFEF3C7)
                                  : AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                isPending
                                    ? const Color(0xFFF59E0B)
                                    : AppColors.primary,
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          isPending ? "قيد الانتظار" : "تم التسليم بنجاح",
                          style: TextStyle(
                            color:
                                isPending
                                    ? const Color(0xFFB45309)
                                    : AppColors.primaryDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 12),

                  // تفاصيل الجمعية والوجبة
                  _buildDetailRow(
                    icon: Icons.volunteer_activism_outlined,
                    iconColor: AppColors.primaryDark,
                    label: "الجهة المستفيدة",
                    value:
                        (req.beneficiaryName != null &&
                                req.beneficiaryName!.isNotEmpty)
                            ? req.beneficiaryName!
                            : "جمعية خيرية معتمدة",
                    isBold: true,
                  ),
                  const SizedBox(height: 8),

                  _buildDetailRow(
                    icon: Icons.fastfood_outlined,
                    iconColor: Colors.orange[800]!,
                    label: "الوجبة المطلوبة",
                    value: req.foodName,
                  ),
                  const SizedBox(height: 8),

                  _buildDetailRow(
                    icon: Icons.shopping_bag_outlined,
                    iconColor: AppColors.primary,
                    label: "الكمية المحجوزة",
                    value: "${req.quantity} وجبة",
                    valueColor: AppColors.primary,
                    isBold: true,
                  ),

                  if (req.expiryTime != null) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      icon: Icons.event_busy_outlined,
                      iconColor: AppColors.error,
                      label: "تاريخ الصلاحية",
                      value: _formatDate(req.expiryTime!),
                      valueColor: AppColors.error,
                    ),
                  ],

                  if (!isPending && req.receiverName != null) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      icon: Icons.person_pin_outlined,
                      iconColor: const Color(0xFF0284C7),
                      label: "المستلم المعتمد",
                      value: req.receiverName!,
                      isBold: true,
                    ),
                  ],

                  const SizedBox(height: 12),

                  // صندوق التوقيت
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "تاريخ الحجز: ${_formatDate(req.requestTime)}",
                              style: const TextStyle(
                                color: Color(0xFF475569),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: Color(0xFF0284C7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "الوقت: ${_formatTime(req.requestTime)}",
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Color valueColor = const Color(0xFF1E293B),
    bool isBold = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
