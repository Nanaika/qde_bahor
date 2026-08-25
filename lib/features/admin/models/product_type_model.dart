class ProductTypeModel {
  final String id;
  final Map<String, String> name;

  ProductTypeModel({
    required this.id,
    required this.name,
  });

  factory ProductTypeModel.fromJson(Map<String, dynamic> json) {
    return ProductTypeModel(
      id: json['id'] as String? ?? '',
      name: Map<String, String>.from(json['name'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  String getName(String langCode) {
    return name[langCode] ?? name['ru'] ?? name.values.firstWhere((e) => e.isNotEmpty, orElse: () => 'Без названия');
  }
}
