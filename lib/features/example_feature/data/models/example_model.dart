import 'package:qde_eco_bahor/features/example_feature/domain/entities/example_entity.dart';

class ExampleModel extends ExampleEntity {
  const ExampleModel({
    required super.id,
    required super.title,
    required super.description,
  });

  factory ExampleModel.fromJson(Map<String, dynamic> json) {
    return ExampleModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
    };
  }

  ExampleEntity toEntity() {
    return ExampleEntity(
      id: id,
      title: title,
      description: description,
    );
  }
}
