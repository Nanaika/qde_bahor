import 'package:equatable/equatable.dart';

class ExampleEntity extends Equatable {
  final int id;
  final String title;
  final String description;

  const ExampleEntity({
    required this.id,
    required this.title,
    required this.description,
  });

  @override
  List<Object> get props => [id, title, description];
}

