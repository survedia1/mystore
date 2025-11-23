class AppModel {
  String? id; // معرف المستند في فايربيس
  final String name;
  final String developerName;
  final String iconUrl;
  final String downloadUrl;
  final String packageName;
  final String version;
  final String size;
  final String description;
  final double rating;

  AppModel({
    this.id,
    required this.name,
    required this.developerName,
    required this.iconUrl,
    required this.downloadUrl,
    required this.packageName,
    required this.version,
    required this.size,
    required this.description,
    required this.rating,
  });

  // تحويل البيانات لإرسالها لفايربيس
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'developerName': developerName,
      'iconUrl': iconUrl,
      'downloadUrl': downloadUrl,
      'packageName': packageName,
      'version': version,
      'size': size,
      'description': description,
      'rating': rating,
    };
  }

  factory AppModel.fromJson(Map<String, dynamic> json) {
    return AppModel(
      // تحويل ID إلى String لأن SQL يرجعه رقم
      id: json['id'].toString(),
      name: json['name'] ?? '',
      // لاحظ تغيير الأسماء لتطابق قاعدة البيانات (developer_name)
      developerName: json['developer_name'] ?? '',
      iconUrl: json['icon_url'] ?? '',
      downloadUrl: json['download_url'] ?? '',
      packageName: json['package_name'] ?? '',
      version: json['version'] ?? '',
      size: json['size'] ?? '',
      description: json['description'] ?? '',
      // التحويل الآمن للأرقام
      rating: (json['rating'] is num)
          ? (json['rating'] as num).toDouble()
          : double.tryParse(json['rating'].toString()) ?? 0.0,
    );
  }
}
