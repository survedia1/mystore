import 'package:flutter/material.dart';
import 'home_page.dart'; // تأكد من وجود هذا الملف لديك

void main() {
  // تأكد من تهيئة Flutter (مطلوب دائماً)
  WidgetsFlutterBinding.ensureInitialized();

  // تشغيل التطبيق
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App Store',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto', // يمكنك تحديد خط إذا أردت
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(), // هذا الملف يحتوي على الواجهة الرئيسية
    );
  }
}
