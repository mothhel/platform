import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../models/restaurant_model.dart';
import '../../models/food_donation_model.dart';
import '../../providers/food_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';

class RestaurantMenuScreen extends StatefulWidget {
  final RestaurantModel restaurant;
  const RestaurantMenuScreen({super.key, required this.restaurant});

  @override
  State<RestaurantMenuScreen> createState() => _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends State<RestaurantMenuScreen> {
  @override
  Widget build(BuildContext context) {
    final foodProvider = Provider.of<FoodProvider>(context);

    // تصفية ذكية ومزدوجة (بالمعرف أو بالاسم) لضمان ظهور وجبات المطعم دائماً
    final restaurantFoods =
        foodProvider.availableFoods.where((f) {
          final bool idMatch =
              (widget.restaurant.id != 0 &&
                  f.restaurantId != 0 &&
                  f.restaurantId == widget.restaurant.id);
          final bool nameMatch =
              f.restaurantName.trim().toLowerCase() ==
              widget.restaurant.name.trim().toLowerCase();

          return idMatch || nameMatch;
        }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            widget.restaurant.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF14532D),
          centerTitle: true,
          elevation: 0,
        ),
        body: RefreshIndicator(
          onRefresh: () => foodProvider.fetchAvailableFoods(),
          color: const Color(0xFF14532D),
          child:
              foodProvider.isLoading
                  ? const Center(
                    child: SpinKitFadingCircle(
                      color: Color(0xFF22C55E),
                      size: 40,
                    ),
                  )
                  : restaurantFoods.isEmpty
                  ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 180),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restaurant_menu,
                              size: 60,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text(
                              "لا توجد وجبات متاحة لهذا المطعم حالياً",
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                  : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: restaurantFoods.length,
                    itemBuilder: (ctx, index) {
                      final food = restaurantFoods[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    food.foodName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "متاح: ${food.quantity} وجبة",
                                    style: const TextStyle(
                                      color: Color(0xFF166534),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            const SizedBox(height: 10),

                            // عرض توقيت الإضافة وتاريخ الانتهاء
                            Row(
                              children: [
                                // تاريخ/وقت الإضافة
                                Expanded(
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time_rounded,
                                        size: 16,
                                        color: Color(0xFF64748B),
                                      ),
                                      const SizedBox(width: 5),
                                      Flexible(
                                        child: Text(
                                          "أضيفت: ${_formatDate(DateTime.now())}",
                                          style: const TextStyle(
                                            color: Color(0xFF64748B),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // تاريخ انتهاء الصلاحية
                                if (food.expiryTime != null)
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.event_busy_outlined,
                                        size: 16,
                                        color: Color(0xFFDC2626),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        "الصلاحية: ${_formatDate(food.expiryTime!)}",
                                        style: const TextStyle(
                                          color: Color(0xFFDC2626),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // زر الحجز
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: ElevatedButton.icon(
                                onPressed:
                                    () => _showBookingDialog(context, food),
                                icon: const Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  "حجز واستلام الوجبة",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF16A34A),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
        ),
      ),
    );
  }

  // دالة مساعدة لتنسيق التاريخ
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // نافذة الحجز السفلية
  void _showBookingDialog(BuildContext context, FoodDonationModel food) {
    int requestedQty = 1;
    bool isSubmitting = false;
    final foodProvider = Provider.of<FoodProvider>(context, listen: false);
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (modalCtx) => Directionality(
            textDirection: TextDirection.rtl,
            child: StatefulBuilder(
              builder: (ctx, setModalState) {
                final bottomPadding =
                    MediaQuery.of(ctx).viewInsets.bottom +
                    MediaQuery.of(ctx).padding.bottom +
                    16;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: bottomPadding,
                    left: 16,
                    right: 16,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 15),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "حجز وجبة: ${food.foodName}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF14532D),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "المطعم المانح: ${widget.restaurant.name}",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed:
                                  (requestedQty > 1 && !isSubmitting)
                                      ? () =>
                                          setModalState(() => requestedQty--)
                                      : null,
                              icon: const Icon(
                                Icons.remove_circle,
                                color: Color(0xFF166534),
                                size: 34,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "$requestedQty",
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const Text(
                                    "وجبة",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed:
                                  (requestedQty < food.quantity &&
                                          !isSubmitting)
                                      ? () =>
                                          setModalState(() => requestedQty++)
                                      : null,
                              icon: const Icon(
                                Icons.add_circle,
                                color: Color(0xFF166534),
                                size: 34,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 26),
                        SizedBox(
                          width: double.infinity,
                          height: 50,

                          child: ElevatedButton(
                            onPressed:
                                isSubmitting
                                    ? null
                                    : () async {
                                      setModalState(() => isSubmitting = true);
                                      final benId = user?.beneficiaryId ?? 1;

                                      try {
                                        final success = await foodProvider
                                            .requestPickup(
                                              foodId: food.id,
                                              beneficiaryId: benId,
                                              quantity: requestedQty,
                                            );

                                        if (success && modalCtx.mounted) {
                                          Navigator.pop(modalCtx);
                                          if (context.mounted) {
                                            _showTopBookingSuccessNotification(
                                              context,
                                              foodName: food.foodName,
                                              quantity: requestedQty,
                                              restaurantName:
                                                  widget.restaurant.name,
                                            );
                                          }
                                        }
                                      } catch (e) {
                                        // 🔥 إظهار الخطأ للجمعية في حال تم إيقاف كلاس الحجز
                                        if (modalCtx.mounted) {
                                          setModalState(
                                            () => isSubmitting = false,
                                          );
                                          String errorMsg = e
                                              .toString()
                                              .replaceAll("Exception: ", "");
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.error_outline,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      errorMsg,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              backgroundColor: AppColors.error,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        }
                                      }
                                    },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF16A34A),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child:
                                isSubmitting
                                    ? const SpinKitThreeBounce(
                                      color: Colors.white,
                                      size: 20,
                                    )
                                    : const Text(
                                      "تأكيد طلب الحجز",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
    );
  }

  // 🔥 دالة الإشعار العلوي الاحترافي الذي ينزلق من الأعلى بتفاصيل الحجز
  void _showTopBookingSuccessNotification(
    BuildContext context, {
    required String foodName,
    required int quantity,
    required String restaurantName,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder:
          (context) => _TopBookingNotificationWidget(
            foodName: foodName,
            quantity: quantity,
            restaurantName: restaurantName,
            onDismiss: () {
              if (overlayEntry.mounted) {
                overlayEntry.remove();
              }
            },
          ),
    );

    overlay.insert(overlayEntry);
  }
}

// 🔥 عنصر الواجهة المنزلق للإشعار العلوي
class _TopBookingNotificationWidget extends StatefulWidget {
  final String foodName;
  final int quantity;
  final String restaurantName;
  final VoidCallback onDismiss;

  const _TopBookingNotificationWidget({
    required this.foodName,
    required this.quantity,
    required this.restaurantName,
    required this.onDismiss,
  });

  @override
  State<_TopBookingNotificationWidget> createState() =>
      _TopBookingNotificationWidgetState();
}

class _TopBookingNotificationWidgetState
    extends State<_TopBookingNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    // إخفاء الإشعار تلقائياً بعد 4.5 ثوانٍ
    Future.delayed(const Duration(milliseconds: 4500), () {
      _dismissWithAnimation();
    });
  }

  void _dismissWithAnimation() async {
    if (mounted) {
      await _controller.reverse();
      widget.onDismiss();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeStr =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 14,
      right: 14,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFF22C55E),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // رأس الإشعار
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFFDCFCE7),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF16A34A),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "تم تأكيد طلب الحجز بنجاح! 🎉",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color(0xFF14532D),
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: _dismissWithAnimation,
                          borderRadius: BorderRadius.circular(20),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 10),

                    // جدول تفاصيل الحجز
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDetailItem(
                          icon: Icons.fastfood_outlined,
                          title: "الوجبة",
                          value: widget.foodName,
                        ),
                        _buildDetailItem(
                          icon: Icons.confirmation_number_outlined,
                          title: "الكمية",
                          value: "${widget.quantity} وجبة",
                          valueColor: const Color(0xFF16A34A),
                        ),
                        _buildDetailItem(
                          icon: Icons.storefront_outlined,
                          title: "المطعم",
                          value: widget.restaurantName,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.hourglass_top_rounded,
                              size: 14,
                              color: Color(0xFFD97706),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              "الحالة: قيد الانتظار",
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFFD97706),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "وقت الطلب: $timeStr",
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
    Color valueColor = const Color(0xFF1E293B),
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
