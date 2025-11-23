import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/app_model.dart';
import '../services/download_service.dart';

class AppDetailsScreen extends StatefulWidget {
  final AppModel app;
  const AppDetailsScreen({super.key, required this.app});

  @override
  State<AppDetailsScreen> createState() => _AppDetailsScreenState();
}

class _AppDetailsScreenState extends State<AppDetailsScreen> {
  final DownloadService _downloadService = DownloadService();

  bool _isInstalled = false;
  bool _isUpdateAvailable = false; // متغير جديد لحالة التحديث
  bool _isDownloading = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _checkAppStatus(); // غيّرنا اسم الدالة لتشمل الفحصين
  }

  /// التحقق من التثبيت + التحقق من التحديث
  Future<void> _checkAppStatus() async {
    // جلب معلومات التطبيق المثبت (شاملة الإصدار)
    bool isInstalled = await DeviceApps.isAppInstalled(widget.app.packageName);

    bool updateAvailable = false;

    if (isInstalled) {
      // إذا مثبت، نجلب بياناته لنعرف إصداره
      Application? app = await DeviceApps.getApp(widget.app.packageName, true);

      if (app != null) {
        // مقارنة الإصدارات: (إصدار السيرفر) vs (الإصدار المثبت)
        // widget.app.version قادمة من لوحة التحكم (السيرفر)
        // app.versionName قادمة من الهاتف
        updateAvailable = _isServerVersionNewer(
          widget.app.version,
          app.versionName ?? "0.0.0",
        );
      }
    }

    if (mounted) {
      setState(() {
        _isInstalled = isInstalled;
        _isUpdateAvailable = updateAvailable;
      });
    }
  }

  // دالة مساعدة لمقارنة الإصدارات (مثلاً 1.0.2 أكبر من 1.0.1)
  bool _isServerVersionNewer(String serverVersion, String installedVersion) {
    try {
      List<int> serverParts = serverVersion.split('.').map(int.parse).toList();
      List<int> installedParts = installedVersion
          .split('.')
          .map(int.parse)
          .toList();

      for (int i = 0; i < serverParts.length; i++) {
        // إذا وصلنا لنهاية أجزاء المثبت (مثلاً السيرفر 1.0.1 والمثبت 1.0)
        if (i >= installedParts.length) return true;

        if (serverParts[i] > installedParts[i]) return true;
        if (serverParts[i] < installedParts[i]) return false;
      }
      // إذا كانوا متساويين، فلا يوجد تحديث
      return false;
    } catch (e) {
      // في حالة وجود خطأ في صيغة النص، نعتبر أنه لا يوجد تحديث لتجنب المشاكل
      return false;
    }
  }

  Future<void> _handleMainButton() async {
    if (_isInstalled && !_isUpdateAvailable) {
      // 1. مثبت ومحدث -> فتح
      DeviceApps.openApp(widget.app.packageName);
    } else {
      // 2. غير مثبت OR (مثبت + يوجد تحديث) -> تحميل وتثبيت
      await _startDownloadAndInstall();
    }
  }

  /// عملية التحميل والتثبيت مع طلب الأذونات
  Future<void> _startDownloadAndInstall() async {
    // طلب إذن تثبيت التطبيقات من مصادر غير معروفة
    if (await Permission.requestInstallPackages.request().isGranted) {
      setState(() {
        _isDownloading = true;
        _progress = 0.0;
      });

      bool success = await _downloadService.downloadAndInstall(
        url: widget.app.downloadUrl,
        onProgress: (val) {
          setState(() {
            _progress = val;
          });
        },
      );

      setState(() {
        _isDownloading = false;
      });

      // بعد التثبيت، نعيد الفحص (قد يحتاج المستخدم للعودة للتطبيق لرؤية التغيير)
      if (success) {
        // ملاحظة: لا يمكننا معرفة لحظة انتهاء التثبيت بدقة لأن النظام يسيطر عليها
        // لكن يمكننا فحص الحالة عند عودة المستخدم (via WidgetsBindingObserver)
        // للتبسيط سنعتمد على الفحص عند إعادة الدخول
      }
    } else {
      // المستخدم رفض الإذن
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب منح إذن التثبيت للمتابعة')),
      );
      // يمكنك توجيهه للإعدادات
      openAppSettings();
    }
  }

  // لمراقبة عودة المستخدم للتطبيق لتحديث حالة الزر (اختياري ولكنه احترافي)
  // يتطلب تحويل الـ State لـ WidgetsBindingObserver

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.app.name,
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      widget.app.iconUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[300],
                        width: 80,
                        height: 80,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.app.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 2. Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('${widget.app.rating} ★', 'التقييم'),
                  Container(width: 1, height: 20, color: Colors.grey[300]),
                  _buildStatItem(widget.app.size, 'الحجم'),
                  Container(width: 1, height: 20, color: Colors.grey[300]),
                  _buildStatItem('+3', 'الفئة'),
                ],
              ),

              const SizedBox(height: 25),

              // 3. Action Button (Install / Open / Progress)
              if (_isDownloading) ...[
                LinearProgressIndicator(
                  value: _progress,
                  color: const Color(0xFF01875F),
                  backgroundColor: Colors.grey[200],
                ),
                const SizedBox(height: 8),
                Text(
                  'جاري التحميل... ${(_progress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(color: Colors.grey),
                ),
              ] else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleMainButton,
                    style: ElevatedButton.styleFrom(
                      // لون أخضر للتثبيت، ولون أزرق للفتح
                      backgroundColor: (_isInstalled && !_isUpdateAvailable)
                          ? Colors
                                .blue // فتح
                          : const Color(0xFF01875F),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _isInstalled
                          ? (_isUpdateAvailable ? 'تحديث' : 'فتح')
                          : 'تثبيت',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // زر الغاء التثبيت يظهر فقط اذا كان التطبيق مثبتاً
              if (_isInstalled)
                Center(
                  child: TextButton(
                    onPressed: () {
                      // فتح إعدادات الحذف
                      // ملاحظة: يتطلب android_intent_plus
                      // const AndroidIntent intent = AndroidIntent(
                      //   action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
                      //   data: 'package:${widget.app.packageName}',
                      // );
                      // intent.launch();
                    },
                    child: Text(
                      "إلغاء التثبيت",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // 4. Description
              const Text(
                'لمحة عن التطبيق',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                widget.app.description,
                style: TextStyle(color: Colors.grey[700], height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String val, String label) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
