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

  // قراءة البيانات من فايربيس
  factory AppModel.fromMap(Map<String, dynamic> map, String docId) {
    return AppModel(
      id: docId,
      name: map['name'] ?? '',
      developerName: map['developerName'] ?? '',
      iconUrl: map['iconUrl'] ?? '',
      downloadUrl: map['downloadUrl'] ?? '',
      packageName: map['packageName'] ?? '',
      version: map['version'] ?? '',
      size: map['size'] ?? '',
      description: map['description'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
    );
  }
}
