sealed class Result<TOk, TError> {
  const Result();

  bool get isSuccess => this is Success;

  bool get isFailure => this is Error;

  TOk? get successValueOrNull => isSuccess ? (this as Success)._value : null;

  TError? get failureValueOrNull => isFailure ? (this as Error)._value : null;

  R fold<R>({
    required R Function(TOk okValue) onSuccess,
    required R Function(TError errorValue) onFailure,
  }) {
    if (this is Success) {
      return onSuccess((this as Success)._value);
    } else if (this is Error) {
      return onFailure((this as Error)._value);
    }
    throw Exception('Unreachable code');
  }
}

final class Success<TOk, TError> extends Result<TOk, TError> {
  final TOk _value;
  const Success(this._value);
}

final class Error<TOk, TError> extends Result<TOk, TError> {
  final TError _value;
  const Error(this._value);
}
