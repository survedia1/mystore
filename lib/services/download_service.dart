import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class DownloadService {
  final Dio _dio = Dio();

  Future<bool> downloadAndInstall({
    required String url,
    required Function(double) onProgress,
  }) async {
    try {
      final directory = await getTemporaryDirectory();
      // بنسمى الملف باسم ثابت مؤقتاً للتجربة
      final String filePath = '${directory.path}/update.apk';

      // حذف الملف القديم لو موجود عشان نتأكد إننا بننزل الجديد
      File oldFile = File(filePath);
      if (await oldFile.exists()) {
        await oldFile.delete();
      }

      print("جاري التحميل من: $url");

      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
      );

      print("✅ تم التحميل. المسار: $filePath");

      // التأكد من حجم الملف (لو صغير جداً يبقى نزل ملف HTML غلط)
      File file = File(filePath);
      int size = await file.length();
      print("حجم الملف: $size بايت");

      if (size < 1000000) {
        // لو أقل من 1 ميجا غالباً الملف بايظ
        print("❌ تحذير: الملف صغير جداً، ربما يكون صفحة خطأ وليس APK");
      }

      // محاولة الفتح
      final result = await OpenFilex.open(filePath);
      print("نتائج محاولة الفتح: ${result.message} (${result.type})");

      if (result.type != ResultType.done) {
        // هنا المشكلة: فشل الفتح
        return false;
      }
      return true;
    } catch (e) {
      print("❌ Error: $e");
      return false;
    }
  }
}
