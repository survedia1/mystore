import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../widgets/app_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final apps = DataService.getApps(); // جلب القائمة

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'المتجر الخاص',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.black),
          ),
          const CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text('A', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // عدد التطبيقات بجانب بعض (3)
            childAspectRatio: 0.7, // نسبة الطول للعرض للكارت
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: apps.length,
          itemBuilder: (context, index) {
            return AppTile(app: apps[index]);
          },
        ),
      ),
    );
  }
}
