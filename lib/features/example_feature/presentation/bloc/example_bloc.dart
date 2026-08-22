import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:qde_eco_bahor/features/example_feature/domain/usecases/get_example_data.dart';

import 'package:qde_eco_bahor/core/error/failures.dart';
import 'package:qde_eco_bahor/features/example_feature/domain/entities/example_entity.dart';

part 'example_bloc.freezed.dart';
part 'example_event.dart';
part 'example_state.dart';

class ExampleBloc extends Bloc<ExampleEvent, ExampleState> {
  final GetExampleData getExampleData;

  ExampleBloc({required this.getExampleData}) : super(const ExampleState.initial()) {
    on<ExampleEvent>((event, emit) async {
      await event.when(
        getExampleData: () => _onGetExampleData(emit),
        refreshExampleData: () => _onRefreshExampleData(emit),
      );
    });
  }

  Future<void> _onGetExampleData(Emitter<ExampleState> emit) async {
    emit(const ExampleState.loading());
    final result = await getExampleData(NoParams());
    result.fold(
      (failure) => emit(ExampleState.error(failure)),
      (data) => emit(ExampleState.loaded(data)),
    );
  }

  Future<void> _onRefreshExampleData(Emitter<ExampleState> emit) async {
    emit(const ExampleState.loading());
    final result = await getExampleData(NoParams());
    result.fold(
      (failure) => emit(ExampleState.error(failure)),
      (data) => emit(ExampleState.loaded(data)),
    );
  }
}
