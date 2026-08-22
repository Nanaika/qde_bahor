part of 'example_bloc.dart';

@freezed
class ExampleState with _$ExampleState {
  const factory ExampleState.initial() = _Initial;
  const factory ExampleState.loading() = _Loading;
  const factory ExampleState.loaded(List<ExampleEntity> data) = _Loaded;
  const factory ExampleState.error(Failure failure) = _Error;
}
