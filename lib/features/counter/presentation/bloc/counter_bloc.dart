import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'counter_bloc.freezed.dart';
part 'counter_event.dart';
part 'counter_state.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterState.initial(0)) {
    on<CounterEvent>((event, emit) {
      event.when(
        increment: () => _onIncrement(emit),
        decrement: () => _onDecrement(emit),
        reset: () => _onReset(emit),
      );
    });
  }

  void _onIncrement(Emitter<CounterState> emit) {
    final currentValue = state.value;
    emit(CounterState.initial(currentValue + 1));
  }

  void _onDecrement(Emitter<CounterState> emit) {
    final currentValue = state.value;
    emit(CounterState.initial(currentValue - 1));
  }

  void _onReset(Emitter<CounterState> emit) {
    emit(const CounterState.initial(0));
  }
}

extension CounterStateExtension on CounterState {
  int get value => when(initial: (value) => value);
}

