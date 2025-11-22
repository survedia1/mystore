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
      // تحديد مسار التخزين المؤقت
      final directory = await getTemporaryDirectory();
      final fileName = url.split('/').last; // استخراج اسم الملف من الرابط
      final filePath = '${directory.path}/$fileName';

      // بدء التحميل
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
      );

      // بعد الانتهاء، فتح ملف التثبيت
      await OpenFilex.open(filePath);
      return true;
    } catch (e) {
      print("خطأ في التحميل: $e");
      return false;
    }
  }
}
