import 'package:flutter/material.dart';
import '../services/data_service.dart'; //
import '../widgets/app_tile.dart';
import '../models/app_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DataService dataService = DataService();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: FutureBuilder<List<AppModel>>(
          // تغيير هنا
          future: dataService.getAllApps(), // الدالة الجديدة
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // 2. حالة الخطأ
            if (snapshot.hasError) {
              return Center(child: Text("حدث خطأ: ${snapshot.error}"));
            }

            // 3. حالة عدم وجود بيانات
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("لا توجد تطبيقات حالياً"));
            }

            final allApps = snapshot.data!;
            // تقسيم التطبيقات
            final featuredApps = allApps.take(5).toList();

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // شريط البحث
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.menu, color: Colors.grey),
                          SizedBox(width: 16),
                          Text(
                            "البحث...",
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                          Spacer(),
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.blue,
                            child: Text(
                              "A",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // قسم التطبيقات المميزة
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8,
                    ),
                    child: Text(
                      "مقترح لك",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 160,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: featuredApps.length,
                      separatorBuilder: (ctx, i) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        return SizedBox(
                          width: 120,
                          child: AppTile(app: featuredApps[index]),
                        );
                      },
                    ),
                  ),
                ),

                // قسم جميع التطبيقات
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                    child: Text(
                      "أحدث التطبيقات",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.75,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return AppTile(app: allApps[index]);
                    }, childCount: allApps.length),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            );
          },
        ),
      ),
    );
  }
}
