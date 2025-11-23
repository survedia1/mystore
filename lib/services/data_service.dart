import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/app_model.dart';

class DataService {
  // رابط السيرفر الذي أنشأته في الخطوة 2
  final String baseUrl = "http://192.168.1.109:3000";

  // تغيير النوع من Stream إلى Future
  Future<List<AppModel>> getAllApps() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/apps'));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => AppModel.fromJson(item)).toList();
      } else {
        throw Exception('فشل تحميل البيانات');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }
}
