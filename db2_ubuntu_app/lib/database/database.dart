import 'package:postgres/postgres.dart';
import 'package:dotenv/dotenv.dart';

class DatabaseConnection {
  static final DatabaseConnection _singleton = DatabaseConnection._internal();

  factory DatabaseConnection() {
    return _singleton;
  }

  DatabaseConnection._internal();

  PostgreSQLConnection? _connection;

  Future<PostgreSQLConnection?> get connection async {
    if (_connection == null) {
      await _init();
    }
    return _connection;
  }

  Future<void> _init() async {
    var env = DotEnv(includePlatformEnvironment: true)..load();

    final host = env['DATABASE_HOST'];
    final port = int.parse(env['DATABASE_PORT']!);
    final database = env['DATABASE_DATABASE'];
    final username = env['DATABASE_USERNAME'];
    final password = env['DATABASE_PASSWORD'];

    _connection = PostgreSQLConnection(host!, port, database!, username: username, password: password);
    await _connection!.open();
  }

  Future<void> closeConnection() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null;
    }
  }
}
