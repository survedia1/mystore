import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_model.dart';

class DataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // هذه الدالة ترجع تياراً (Stream) من قائمة التطبيقات
  // أي تحديث يتم في لوحة التحكم يظهر فوراً في التطبيق
  Stream<List<AppModel>> getAllApps() {
    return _firestore
        .collection('apps') // اسم الـ Collection الذي تستخدمه في لوحة التحكم
        .snapshots() // جلب اللقطات الحية
        .map((snapshot) {
          // تحويل كل مستند إلى كائن AppModel
          return snapshot.docs
              .map((doc) => AppModel.fromFirestore(doc))
              .toList();
        });
  }
}
