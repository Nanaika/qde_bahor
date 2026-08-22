import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:qde_eco_bahor/core/error/failures.dart';

/// Расширения для работы с Either
extension EitherExtensions<L extends Failure, R> on Either<L, R> {
  /// Получить значение Right
  R? getRight() {
    return fold((l) => null, (r) => r);
  }

  /// Получить значение Left
  L? getLeft() {
    return fold((l) => l, (r) => null);
  }

  /// Для использования в UI для отображения разных виджетов
  Widget when({
    required Widget Function(L failure) failure,
    required Widget Function(R data) success,
  }) {
    return fold(
      (l) => failure(l),
      (r) => success(r),
    );
  }

  /// Упростить цепочку операций, которые могут завершиться ошибкой
  Either<L, T> flatMap<T>(Either<L, T> Function(R r) f) {
    return fold(
      (l) => Left(l),
      (r) => f(r),
    );
  }
}
