import 'package:signals_flutter/signals_flutter.dart';

import 'result.dart';

abstract interface class ICommand<Success, Error> {
  Future<Result<Success, Error>> execute();
}

abstract base class Command<Success, Error>
    implements ICommand<Success, Error> {
  final _running = signal(false);
  final _result = signal<Result<Success, Error>?>(null);

  ReadonlySignal<bool> get isExecuting => _running.readonly();
  ReadonlySignal<Result<Success, Error>?> get result => _result.readonly();

  late final hasResult = computed(() => _result.value != null);
  late final hasError = computed(() => _result.value?.isFailure ?? false);
  late final isSuccess = computed(() => _result.value?.isSuccess ?? false);

  Future<Result<Success, Error>> call() async {
    if (_running.value) {
      return _result.value ?? await execute();
    }
    _running.value = true;
    _result.value = null;
    final result = await execute();
    _result.value = result;
    _running.value = false;
    return result;
  }

  void clear() {
    _result.value = null;
  }

  void reset() {
    _running.value = false;
    clear();
  }
}

abstract base class ParameterizedCommand<Success, Error, P>
    extends Command<Success, Error> {
  P? _parameter;

  set parameter(P? value) => _parameter = value;
  P? get parameter => _parameter;

  Future<Result<Success, Error>> executeWith(P parameter) {
    _parameter = parameter;
    return call();
  }

  @override
  Future<Result<Success, Error>> execute();
}

final class CompositeCommand<TOk, TError> extends Command<List<TOk>, TError> {
  final List<Command<TOk, TError>> _commands;

  CompositeCommand(this._commands);

  @override
  Future<Result<List<TOk>, TError>> execute() async {
    final results = <TOk>[];

    for (final command in _commands) {
      final result = await command.call();

      if (result.isFailure) {
        return Error(result.failureValueOrNull as TError);
      }

      final value = result.successValueOrNull;
      if (value != null) {
        results.add(value);
      }
    }

    return Success(results);
  }
}
