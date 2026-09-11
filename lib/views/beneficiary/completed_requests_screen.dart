import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';

class CompletedRequestsScreen extends StatefulWidget {
  const CompletedRequestsScreen({super.key});

  @override
  State<CompletedRequestsScreen> createState() =>
      _CompletedRequestsScreenState();
}

class _CompletedRequestsScreenState extends State<CompletedRequestsScreen> {
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

  String _formatDate(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
  }

  String _formatDateTime(DateTime dt) {
    final int hour =
        dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final String period = dt.hour >= 12 ? "م" : "ص";
    final String minute = dt.minute.toString().padLeft(2, '0');
    return "${_formatDate(dt)} ($hour:$minute $period)";
  }

  @override
  Widget build(BuildContext context) {
    final requestProvider = Provider.of<RequestProvider>(context);

    // 🔥 الترتيب تصاعدياً حسب وقت وتاريخ التسليم (من الأقدم تسليماً إلى الأحدث)
    final completedRequests = List.from(requestProvider.deliveredRequests)
      ..sort((a, b) {
        final timeA = a.deliveredTime ?? a.requestTime;
        final timeB = b.deliveredTime ?? b.requestTime;
        return timeA.compareTo(timeB);
      });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            "الطلبات المستلمة (المكتملة)",
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
                    size: 45,
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
                  color: AppColors.primary,
                  child:
                      completedRequests.isEmpty
                          ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const SizedBox(height: 180),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.inventory_2_outlined,
                                      size: 60,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 14),
                                    const Text(
                                      "لا توجد طلبات مكتملة أو مستلمة حالياً.",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                          : ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: completedRequests.length,
                            itemBuilder: (context, index) {
                              final req = completedRequests[index];
                              final serialNum = index + 1;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: const Icon(
                                                  Icons.task_alt_rounded,
                                                  size: 18,
                                                  color: AppColors.primaryDark,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                "طلب مكتمل رقم: $serialNum",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF1E293B),
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: AppColors.primary,
                                                width: 0.5,
                                              ),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.done_all_rounded,
                                                  size: 14,
                                                  color: AppColors.primaryDark,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  "تم الاستلام",
                                                  style: TextStyle(
                                                    color:
                                                        AppColors.primaryDark,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      const Divider(
                                        height: 1,
                                        color: Color(0xFFF1F5F9),
                                      ),
                                      const SizedBox(height: 12),

                                      _buildInfoRow(
                                        icon: Icons.storefront_outlined,
                                        iconColor: AppColors.primaryDark,
                                        label: "المطعم المانح",
                                        value: req.restaurantName,
                                        valueBold: true,
                                      ),
                                      const SizedBox(height: 8),

                                      _buildInfoRow(
                                        icon: Icons.fastfood_outlined,
                                        iconColor: Colors.orange[800]!,
                                        label: "الوجبة المستلمة",
                                        value: req.foodName,
                                      ),
                                      const SizedBox(height: 8),

                                      _buildInfoRow(
                                        icon: Icons.inventory_2_outlined,
                                        iconColor: AppColors.primary,
                                        label: "الكمية المستلمة",
                                        value: "${req.quantity} وجبة",
                                        valueColor: AppColors.primary,
                                        valueBold: true,
                                      ),

                                      if (req.expiryTime != null) ...[
                                        const SizedBox(height: 8),
                                        _buildInfoRow(
                                          icon: Icons.event_busy_outlined,
                                          iconColor: AppColors.error,
                                          label: "تاريخ الصلاحية",
                                          value: _formatDate(req.expiryTime!),
                                          valueColor: AppColors.error,
                                          valueBold: true,
                                        ),
                                      ],

                                      const SizedBox(height: 8),
                                      _buildInfoRow(
                                        icon: Icons.person_pin_outlined,
                                        iconColor: const Color(0xFF0284C7),
                                        label: "المستلم المعتمد",
                                        value:
                                            (req.receiverName != null &&
                                                    req
                                                        .receiverName!
                                                        .isNotEmpty)
                                                ? req.receiverName!
                                                : (req.beneficiaryName !=
                                                            null &&
                                                        req
                                                            .beneficiaryName!
                                                            .isNotEmpty
                                                    ? req.beneficiaryName!
                                                    : "مندوب الجمعية"),
                                        valueBold: true,
                                      ),
                                      const SizedBox(height: 12),

                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.background,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFE2E8F0),
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.access_time_rounded,
                                                  size: 15,
                                                  color: Color(0xFF64748B),
                                                ),
                                                const SizedBox(width: 6),
                                                const Text(
                                                  "تاريخ ووقت الطلب: ",
                                                  style: TextStyle(
                                                    color: Color(0xFF64748B),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    _formatDateTime(
                                                      req.requestTime,
                                                    ),
                                                    style: const TextStyle(
                                                      color: Color(0xFF334155),
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),

                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.verified_outlined,
                                                  size: 15,
                                                  color: AppColors.primary,
                                                ),
                                                const SizedBox(width: 6),
                                                const Text(
                                                  "تاريخ ووقت التسليم: ",
                                                  style: TextStyle(
                                                    color: AppColors.primary,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    req.deliveredTime != null
                                                        ? _formatDateTime(
                                                          req.deliveredTime!,
                                                        )
                                                        : "تم التسليم بنجاح",
                                                    style: const TextStyle(
                                                      color:
                                                          AppColors.primaryDark,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Color valueColor = const Color(0xFF1E293B),
    bool valueBold = false,
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
              fontWeight: valueBold ? FontWeight.bold : FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
