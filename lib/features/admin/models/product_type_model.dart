class ProductTypeModel {
  final String id;
  final Map<String, String> name;

  ProductTypeModel({
    required this.id,
    required this.name,
  });

  factory ProductTypeModel.fromJson(dynamic json) {
    // Если из базы пришел null или не Map — возвращаем пустой объект
    if (json == null || json is! Map) {
      return ProductTypeModel(id: '', name: {});
    }

    // Приводим внешнюю Map к универсальному виду (защита от Map<dynamic, dynamic>)
    final map = Map<String, dynamic>.from(json);

    final Map<String, String> parsedName = {};

    // Забираем поле 'name'
    final rawName = map['name'];
    if (rawName is Map) {
      rawName.forEach((key, value) {
        if (key != null && value != null && value.toString().isNotEmpty) {
          parsedName[key.toString()] = value.toString();
        }
      });
    }
    print('111111111111============${parsedName}');
    print('111111111111============${map['id']}');
    return ProductTypeModel(
      id: map['id']?.toString() ?? '',
      name: parsedName,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  String getName(String langCode) {
    if (name.isEmpty) return 'No name';
    return name[langCode] ?? name['ru'] ?? name.values.firstWhere((e) => e.isNotEmpty, orElse: () => 'No name');
  }
}
