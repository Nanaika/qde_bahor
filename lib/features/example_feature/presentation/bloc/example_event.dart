part of 'example_bloc.dart';

@freezed
class ExampleEvent with _$ExampleEvent {
  const factory ExampleEvent.getExampleData() = _GetExampleData;
  const factory ExampleEvent.refreshExampleData() = _RefreshExampleData;
}
