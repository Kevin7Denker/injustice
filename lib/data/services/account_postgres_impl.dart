import 'package:postgres/postgres.dart';

import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/models/account_entity.dart';
import 'account_local_storage_interface.dart';
import 'postgres_connection_service.dart';

final class AccountPostgresService implements IAccountLocalStorage {
  final PostgresConnectionService _postgresConnection;

  AccountPostgresService({
    required PostgresConnectionService postgresConnection,
  }) : _postgresConnection = postgresConnection;

  @override
  Future<VoidResult> deleteAccount() async {
    try {
      final connection = await _postgresConnection.getConnection();

      await connection.execute(
        Sql.named('''
          DELETE FROM account_profile
          WHERE singleton_key = @singleton_key;
        '''),
        parameters: {'singleton_key': 1},
      );

      return Success(null);
    } catch (e) {
      return Error(ApiLocalFailure('PostgreSQL - Erro ao deletar conta: $e'));
    }
  }

  @override
  Future<AccountResult> getAccount() async {
    try {
      final connection = await _postgresConnection.getConnection();

      final result = await connection.execute(
        Sql.named('''
          SELECT
            name,
            email,
            display_name,
            created_at,
            updated_at,
            level,
            gold,
            gems,
            energy
          FROM account_profile
          WHERE singleton_key = @singleton_key
          LIMIT 1;
        '''),
        parameters: {'singleton_key': 1},
      );

      if (result.isEmpty) {
        return Error(EmptyResultFailure());
      }

      final account = _toAccount(result.first.toColumnMap());
      return Success(account);
    } catch (e) {
      return Error(ApiLocalFailure('PostgreSQL - Erro ao obter conta: $e'));
    }
  }

  @override
  Future<VoidResult> saveAccount(Account account) {
    return _upsertAccount(account);
  }

  @override
  Future<VoidResult> updateAccount(Account account) {
    return _upsertAccount(account);
  }

  Future<VoidResult> _upsertAccount(Account account) async {
    try {
      final connection = await _postgresConnection.getConnection();

      await connection.execute(
        Sql.named('''
          INSERT INTO account_profile (
            singleton_key,
            name,
            email,
            display_name,
            created_at,
            updated_at,
            level,
            gold,
            gems,
            energy
          )
          VALUES (
            @singleton_key,
            @name,
            @email,
            @display_name,
            @created_at,
            @updated_at,
            @level,
            @gold,
            @gems,
            @energy
          )
          ON CONFLICT (singleton_key)
          DO UPDATE SET
            name = EXCLUDED.name,
            email = EXCLUDED.email,
            display_name = EXCLUDED.display_name,
            created_at = EXCLUDED.created_at,
            updated_at = EXCLUDED.updated_at,
            level = EXCLUDED.level,
            gold = EXCLUDED.gold,
            gems = EXCLUDED.gems,
            energy = EXCLUDED.energy;
        '''),
        parameters: {
          'singleton_key': 1,
          'name': account.name,
          'email': account.email,
          'display_name': account.displayName,
          'created_at': account.createdAt,
          'updated_at': account.updatedAt,
          'level': account.level,
          'gold': account.gold,
          'gems': account.gems,
          'energy': account.energy,
        },
      );

      return Success(null);
    } catch (e) {
      return Error(ApiLocalFailure('PostgreSQL - Erro ao salvar conta: $e'));
    }
  }

  Account _toAccount(Map<String, dynamic> data) {
    return Account(
      name: data['name'] as String,
      email: data['email'] as String,
      displayName: data['display_name'] as String,
      createdAt: _toDateTime(data['created_at']),
      updatedAt: _toDateTime(data['updated_at']),
      level: _toInt(data['level']),
      gold: _toDouble(data['gold']),
      gems: _toInt(data['gems']),
      energy: _toInt(data['energy']),
    );
  }

  DateTime _toDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.parse(value);
    }

    throw StateError('Valor de data invalido: $value');
  }

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.parse(value);
    }

    throw StateError('Valor inteiro invalido: $value');
  }

  double _toDouble(dynamic value) {
    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.parse(value);
    }

    throw StateError('Valor decimal invalido: $value');
  }
}
