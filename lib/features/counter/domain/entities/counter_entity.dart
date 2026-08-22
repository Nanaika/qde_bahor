import 'package:equatable/equatable.dart';

class CounterEntity extends Equatable {
  final int value;

  const CounterEntity({required this.value});

  @override
  List<Object> get props => [value];
}

