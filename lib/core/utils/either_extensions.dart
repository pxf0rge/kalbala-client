import 'package:fpdart/fpdart.dart';
import 'package:rahmani_project/core/errors/failures.dart';

/// Extensions for [Either] used across the domain layer.
extension EitherFailureX<L extends Failure, R> on Either<L, R> {
  R getRightOrThrow() => fold((failure) => throw failure, (value) => value);

  Failure getLeftOrNull() => fold((failure) => failure, (_) => throw StateError('Expected Left'));
}
