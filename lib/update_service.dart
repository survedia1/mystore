import 'dart:convert'; // لتحويل JSON
import 'dart:io'; // لاستخدام File
import 'package:http/http.dart' as http; // للاتصال بـ API
import 'package:package_info_plus/package_info_plus.dart'; // لمعرفة الإصدار الحالي
import 'package:dio/dio.dart'; // لتحميل الملف (أداء أفضل)
import 'package:path_provider/path_provider.dart'; // لمعرفة مسار الحفظ
import 'package:open_filex/open_filex.dart'; // لفتح ملف APK

class UpdateService {
  // ⬇️⬇️ !! هام جداً: استبدل هذا برابط Vercel الخاص بك !! ⬇️⬇️
  final String _versionCheckUrl =
      "https://YOUR-VERCEL-DOMAIN.vercel.app/api/version";
  // ⬆️⬆️ !! هام جداً: استبدل هذا برابط Vercel الخاص بك !! ⬆️⬆️

  final Dio _dio = Dio();

  // متغيرات لتخزين حالة التحديث
  Map<String, dynamic>? _updateInfo;
  bool updateAvailable = false;
  String? _apkPath; // مسار ملف APK بعد تحميله

  /// 1. التحقق من وجود تحديثات
  /// يتصل بـ Vercel API ويقارن الإصدارات
  Future<bool> checkForUpdate() async {
    try {
      // جلب بيانات الإصدار الأخير من Vercel API
      final response = await http.get(Uri.parse(_versionCheckUrl));

      if (response.statusCode != 200) {
        // حدث خطأ في الخادم أو API
        print("Failed to check version: ${response.body}");
        return false;
      }

      // تحليل بيانات JSON القادمة من الـ API
      final data = json.decode(response.body) as Map<String, dynamic>;
      final latestVersionCode = data['version_code'] as int;

      // جلب بيانات الإصدار المثبت حالياً على جهاز المستخدم
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersionCode = int.parse(packageInfo.buildNumber);

      // المقارنة
      if (latestVersionCode > currentVersionCode) {
        // نعم، يوجد تحديث
        _updateInfo = data; // حفظ بيانات التحديث (الرابط، الاسم)
        updateAvailable = true;
        return true;
      }

      // لا يوجد تحديث
      return false;
    } catch (e) {
      // حدث خطأ عام (مثل عدم وجود إنترنت)
      print("Error checking for update: $e");
      return false;
    }
  }

  /// 2. تحميل ملف التحديث
  /// (onProgress) هي دالة نرسلها من الواجهة لتتبع نسبة التحميل
  Future<bool> downloadUpdate(Function(double) onProgress) async {
    if (_updateInfo == null) return false; // لا يوجد تحديث للتحميل

    try {
      // تحديد مسار حفظ الملف في ذاكرة الجهاز
      // (استخدام getExternalStorageDirectory يتطلب أذونات في بعض الأحيان، getTemporaryDirectory أسهل)
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/app-release.apk';
      _apkPath = filePath; // حفظ المسار لخطوة التثبيت

      // بدء التحميل باستخدام Dio
      await _dio.download(
        _updateInfo!['download_url'], // رابط التحميل من Vercel Blob
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            // إرسال النسبة (من 0.0 إلى 1.0) إلى الواجهة
            onProgress(received / total);
          }
        },
      );

      return true; // اكتمل التحميل بنجاح
    } catch (e) {
      print("Error downloading update: $e");
      return false;
    }
  }

  /// 3. تثبيت التحديث
  /// يقوم بفتح ملف الـ APK المحمل ليقوم النظام بتثبيته
  Future<void> installUpdate() async {
    if (_apkPath == null) {
      print("APK path is null, cannot install.");
      return;
    }

    // استخدام open_filex لفتح ملف APK
    // سيتعرف نظام أندرويد أنه ملف تثبيت وسيبدأ الـ Package Installer
    final result = await OpenFilex.open(_apkPath!);

    // لطباعة أي رسالة (نجاح أو خطأ) من عملية الفتح
    print("OpenFilex result: ${result.message}");
  }
}
