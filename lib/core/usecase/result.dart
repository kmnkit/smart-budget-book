import 'package:zan/core/errors/failures.dart';

sealed class Result<T> {
  const Result();

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  });

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Fail<T>;
}

class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) =>
      success(data);
}

class Fail<T> extends Result<T> {
  const Fail(this.failure);
  final Failure failure;

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) =>
      failure(this.failure);
}
