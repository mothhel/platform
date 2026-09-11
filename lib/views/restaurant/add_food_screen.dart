import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/food_provider.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedFoodName;
  final TextEditingController _quantityController = TextEditingController();
  DateTime? _selectedExpiryDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final user =
          Provider.of<AuthProvider>(context, listen: false).currentUser;
      Provider.of<FoodProvider>(
        context,
        listen: false,
      ).fetchRestaurantMenu(restaurantId: user?.restaurantId);
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _submitFood(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedExpiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("يرجى تحديد تاريخ انتهاء الصلاحية للوجبة"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    final restId = user?.restaurantId;

    if (restId == null || restId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "خطأ: لم يتم التعرف على معرّف المطعم، يرجى تسجيل الخروج والدخول مجدداً.",
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await Provider.of<FoodProvider>(
        context,
        listen: false,
      ).addFoodDonation(
        foodName: _selectedFoodName ?? '',
        quantity: int.parse(_quantityController.text.trim()),
        expiryTime: _selectedExpiryDate!,
        restaurantId: restId,
        restaurantName: user?.restaurantName ?? 'مطعم معتمد',
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تمت إضافة ونشر الوجبة بنجاح لمطعمك حصرياً! 🍔✨"),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      // 🔥 سيظهر هذا الإشعار الأحمر الأنيق للدكتور إذا أوقف الكنترولر!
      if (mounted) {
        setState(() => _isLoading = false);
        String errorMsg = e.toString().replaceAll("Exception: ", "");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    errorMsg,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final foodProvider = Provider.of<FoodProvider>(context);
    final user = Provider.of<AuthProvider>(context).currentUser;
    final List<String> menuItems = foodProvider.restaurantMenuNames;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            "إضافة وجبة فائضة للتبرع",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: AppColors.primaryDark,
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.restaurant_menu_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "بيانات وجبة الفائض الغذائي",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 28),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.storefront_outlined,
                            color: AppColors.primaryDark,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "المطعم المانح الحالي:",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                user?.restaurantName ??
                                    "غير محدد (سيتم رفض الإضافة)",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.verified,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      "اسم ونوع الوجبة (من قائمة مطعمك)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),

                    foodProvider.isMenuLoading
                        ? Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SpinKitFadingCircle(
                                color: AppColors.primary,
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "جاري تحميل قائمة الأطعمة...",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                        : DropdownButtonFormField<String>(
                          value:
                              menuItems.contains(_selectedFoodName)
                                  ? _selectedFoodName
                                  : null,
                          hint: const Text(
                            "-- اختر الوجبة من القائمة --",
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          isExpanded: true,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.fastfood_outlined,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                          items:
                              menuItems
                                  .map(
                                    (String item) => DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(
                                        item,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (val) => setState(() => _selectedFoodName = val),
                          validator:
                              (val) =>
                                  val == null || val.isEmpty
                                      ? 'يرجى اختيار الوجبة من القائمة'
                                      : null,
                        ),
                    const SizedBox(height: 6),
                    const Text(
                      "ℹ️ يتم إدارة وتحديث هذه القائمة عبر لوحة تحكم الويب.",
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      "الكمية (بالأطباق / الوجبات)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "أدخل عدد الوجبات المتاحة",
                        prefixIcon: const Icon(
                          Icons.shopping_bag_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty)
                          return 'يرجى إدخال الكمية';
                        if ((int.tryParse(val.trim()) ?? 0) <= 0)
                          return 'يرجى إدخال رقم صحيح أكبر من الصفر';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      "تاريخ انتهاء الصلاحية",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 30),
                          ),
                        );
                        if (picked != null)
                          setState(() => _selectedExpiryDate = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedExpiryDate == null
                                  ? "اضغط لتحديد تاريخ انتهاء الصلاحية"
                                  : "${_selectedExpiryDate!.year}-${_selectedExpiryDate!.month.toString().padLeft(2, '0')}-${_selectedExpiryDate!.day.toString().padLeft(2, '0')}",
                              style: TextStyle(
                                color:
                                    _selectedExpiryDate == null
                                        ? Colors.grey
                                        : const Color(0xFF1E293B),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today_outlined,
                              color: Colors.grey,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                            ),
                            child: const Text(
                              "إلغاء",
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed:
                                _isLoading ? null : () => _submitFood(context),
                            icon:
                                _isLoading
                                    ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Icon(
                                      Icons.save_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                            label: Text(
                              _isLoading ? "جاري الحفظ..." : "حفظ ونشر الوجبة",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
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
}
