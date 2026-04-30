// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'اصطفينا';

  @override
  String get dashboard => 'الرئيسية';

  @override
  String get friends => 'الأصدقاء';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get owesYou => 'مدين لك';

  @override
  String get youOwe => 'أنت مدين';

  @override
  String get estafeto => 'اصطفيتوا؟ 🤙';

  @override
  String get estafetoPDesc => 'خلصت حسابك مع الجدع ده؟';

  @override
  String get estafena => 'اصطفينا! ✅';

  @override
  String get notYet => 'مش دلوقتي';

  @override
  String get pay => 'ادفع';

  @override
  String get paymentOptions => 'طرق الدفع';

  @override
  String get noPaymentOptions => 'لا توجد طرق دفع مضافة';

  @override
  String get addFriend => 'إضافة صديق';

  @override
  String get friendUsername => 'اسم المستخدم';

  @override
  String get add => 'إضافة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get noFriends => 'لا يوجد أصدقاء بعد.\nأضف شخصاً للبدء!';

  @override
  String get noDashboardItems => 'كل شيء على ما يرام! لا ديون مسجلة.';

  @override
  String get myProfile => 'ملفي الشخصي';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get editUsername => 'تعديل الاسم';

  @override
  String get paymentMethods => 'طرق الدفع الخاصة بي';

  @override
  String get addPaymentMethod => 'إضافة طريقة دفع';

  @override
  String get editPaymentMethod => 'تعديل طريقة الدفع';

  @override
  String get methodType => 'نوع الطريقة';

  @override
  String get accountDetails => 'رقم الحساب / المعرّف';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get instapay => 'إنستاباي';

  @override
  String get vodafoneCash => 'فودافون كاش';

  @override
  String get choosePaymentMethod => 'اختار طريقة الدفع';

  @override
  String get egp => 'ج.م';

  @override
  String get netBalance => 'الرصيد الصافي';

  @override
  String get addTransaction => 'إضافة معاملة';

  @override
  String get transactionAmount => 'المبلغ (ج.م)';

  @override
  String get transactionNote => 'ملاحظة (اختياري)';

  @override
  String get iPaid => 'أنا دفعت';

  @override
  String get theyPaid => 'هو/هي دفع';

  @override
  String get transactions => 'المعاملات';

  @override
  String get noTransactions => 'لا توجد معاملات بعد';

  @override
  String get deleteConfirm => 'حذف الصديق';

  @override
  String deleteConfirmDesc(String name) {
    return 'حذف $name وكل معاملاته؟';
  }

  @override
  String get remove => 'حذف';

  @override
  String get language => 'اللغة';

  @override
  String get english => 'الإنجليزية';

  @override
  String get arabic => 'العربية';

  @override
  String get settings => 'الإعدادات';

  @override
  String get totalOwedToYou => 'إجمالي ما لك';

  @override
  String get totalYouOwe => 'إجمالي ما عليك';

  @override
  String get settled => 'تم التسوية!';

  @override
  String get copyNumber => 'نسخ';

  @override
  String get copied => 'تم النسخ!';
}
