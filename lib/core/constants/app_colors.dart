import 'package:flutter/material.dart';

class AppColors {
  // الألوان الأساسية المطابقة لهوية منصة نِعم في الويب
  static const Color primary = Color(0xFF22C55E); // الأخضر الأساسي
  static const Color primaryDark = Color(
    0xFF166534,
  ); // الأخضر الغامق (للهيدر والأيقونات)
  static const Color primaryLight = Color(
    0xFFDCFCE7,
  ); // الأخضر الفاتح جداً (للخلفيات والبطاقات)

  // ألوان الخلفيات
  static const Color background = Color(0xFFF0FDF4); // لون خلفية التطبيق

  // ألوان النصوص
  static const Color textPrimary = Color(
    0xFF1E293B,
  ); // أسود مائل للكحلي للعناوين
  static const Color textSecondary = Color(0xFF64748B); // رمادي للنصوص الفرعية

  // ألوان الحالات (Status)
  static const Color error = Color(0xFFDC2626); // الأحمر للأخطاء
  static const Color success = Color(0xFF16A34A); // الأخضر لرسائل النجاح
  static const Color warning = Color(0xFFF59E0B); // البرتقالي للانتظار
  static const Color info = Color(0xFF0EA5E9); // الأزرق للمعلومات
}
