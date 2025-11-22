import '../models/app_model.dart';

class DataService {
  // هذه القائمة تحاكي التطبيقات القادمة من لوحة التحكم
  static List<AppModel> getApps() {
    return [
      AppModel(
        id: '1',
        name: 'تطبيق المبيعات',
        developerName: 'شركتي الخاصة',
        iconUrl:
            'https://cdn-icons-png.flaticon.com/512/3135/3135715.png', // أيقونة تجريبية
        downloadUrl: 'https://your-server.com/sales-app.apk', // رابط ملفك
        packageName: 'com.mycompany.sales',
        version: '1.2.0',
        size: '15 MB',
        rating: 4.5,
        description:
            'تطبيق لإدارة المبيعات والفواتير، يساعدك على تنظيم عملك بسهولة وسرعة...',
      ),
      AppModel(
        id: '2',
        name: 'نظام الحضور',
        developerName: 'شركتي الخاصة',
        iconUrl: 'https://cdn-icons-png.flaticon.com/512/2921/2921222.png',
        downloadUrl: 'https://your-server.com/attendance.apk',
        packageName: 'com.mycompany.attendance',
        version: '2.0.1',
        size: '8 MB',
        rating: 4.8,
        description: 'سجل حضور وانصراف الموظفين باستخدام GPS والبصمة.',
      ),
      // يمكنك إضافة المزيد من التطبيقات هنا
    ];
  }
}
