import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:postgres/postgres.dart';

final class PostgresConnectionService {
  Connection? _connection;

  Future<Connection> getConnection() async {
    final currentConnection = _connection;

    if (currentConnection != null && currentConnection.isOpen) {
      return currentConnection;
    }

    final openedConnection = await _openConnection();
    _connection = openedConnection;

    return openedConnection;
  }

  Future<void> close() async {
    final currentConnection = _connection;

    if (currentConnection == null) {
      return;
    }

    if (currentConnection.isOpen) {
      await currentConnection.close();
    }

    _connection = null;
  }

  Future<Connection> _openConnection() async {
    final publicUrl = dotenv.maybeGet('DATABASE_PUBLIC_URL');

    if (publicUrl != null && publicUrl.trim().isNotEmpty) {
      final connectionString = _withDefaultConnectionParams(publicUrl.trim());
      return Connection.openFromUrl(connectionString);
    }

    final host = _requiredEnv('PGHOST');
    final database = _requiredEnv('PGDATABASE');
    final user = _requiredEnv('PGUSER');
    final password = _requiredEnv('PGPASSWORD');
    final port =
        int.tryParse(dotenv.maybeGet('PGPORT', fallback: '5432') ?? '') ?? 5432;

    return Connection.open(
      Endpoint(
        host: host,
        port: port,
        database: database,
        username: user,
        password: password,
      ),
      settings: const ConnectionSettings(
        sslMode: SslMode.require,
        connectTimeout: Duration(seconds: 10),
        queryTimeout: Duration(seconds: 15),
      ),
    );
  }

  String _requiredEnv(String key) {
    final value = dotenv.maybeGet(key);

    if (value == null || value.trim().isEmpty) {
      throw StateError('Variavel de ambiente obrigatoria ausente: $key');
    }

    return value.trim();
  }

  String _withDefaultConnectionParams(String url) {
    final uri = Uri.parse(url);

    if (uri.queryParameters.containsKey('sslmode')) {
      return url;
    }

    final queryParameters = Map<String, String>.from(uri.queryParameters);
    queryParameters['sslmode'] = 'require';
    queryParameters['application_name'] = 'injustice_app';

    return uri.replace(queryParameters: queryParameters).toString();
  }
}
