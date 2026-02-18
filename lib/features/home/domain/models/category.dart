class Category {
  final String id;
  final String name;
  final String type;
  final String? icon;
  final bool isDefault;

  Category({
    required this.id,
    required this.name,
    required this.type,
    this.icon,
    required this.isDefault,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      icon: json['icon'],
      isDefault: json['is_default'] ?? false,
    );
  }
}
