import 'package:flutter/material.dart';
import '../models/app_model.dart';
import '../screens/app_details_screen.dart';

class AppTile extends StatelessWidget {
  final AppModel app;

  const AppTile({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AppDetailsScreen(app: app)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الأيقونة بحواف دائرية مثل المتجر
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              app.iconUrl,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                height: 100,
                width: 100,
                child: const Icon(Icons.error),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            app.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            app.size,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
