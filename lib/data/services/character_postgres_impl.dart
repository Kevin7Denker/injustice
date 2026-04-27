import 'package:postgres/postgres.dart';

import '../../core/failure/failure.dart';
import '../../core/patterns/result.dart';
import '../../core/typedefs/types_defs.dart';
import '../../domain/models/character_entity.dart';
import 'character_local_storage_interface.dart';
import 'postgres_connection_service.dart';

final class CharacterPostgresService implements ICharacterLocalStorage {
  final PostgresConnectionService _postgresConnection;

  CharacterPostgresService({
    required PostgresConnectionService postgresConnection,
  }) : _postgresConnection = postgresConnection;

  @override
  Future<CharacterResult> deleteCharacter(String id) async {
    if (id.trim().isEmpty) {
      return Error(InputFailure('ID invalido.'));
    }

    try {
      final connection = await _postgresConnection.getConnection();

      final result = await connection.execute(
        Sql.named('''
          DELETE FROM characters
          WHERE id = @id
          RETURNING
            id,
            name,
            character_class,
            rarity,
            level,
            threat,
            attack,
            health,
            stars,
            alignment,
            created_at,
            updated_at;
        '''),
        parameters: {'id': id},
      );

      if (result.isEmpty) {
        return Error(EmptyResultFailure('Personagem nao encontrado.'));
      }

      return Success(_toCharacter(result.first.toColumnMap()));
    } catch (e) {
      return Error(
        ApiLocalFailure('PostgreSQL - Erro ao deletar personagem: $e'),
      );
    }
  }

  @override
  Future<ListCharacterResult> getAllCharacters() async {
    try {
      final connection = await _postgresConnection.getConnection();

      final result = await connection.execute('''
        SELECT
          id,
          name,
          character_class,
          rarity,
          level,
          threat,
          attack,
          health,
          stars,
          alignment,
          created_at,
          updated_at
        FROM characters
        ORDER BY updated_at DESC;
      ''');

      if (result.isEmpty) {
        return Error(EmptyResultFailure());
      }

      final characters = result
          .map((row) => _toCharacter(row.toColumnMap()))
          .toList(growable: false);

      return Success(characters);
    } catch (e) {
      return Error(
        ApiLocalFailure('PostgreSQL - Erro ao obter personagens: $e'),
      );
    }
  }

  @override
  Future<CharacterResult> getCharacterById(String id) async {
    if (id.trim().isEmpty) {
      return Error(InputFailure('ID invalido.'));
    }

    try {
      final connection = await _postgresConnection.getConnection();

      final result = await connection.execute(
        Sql.named('''
          SELECT
            id,
            name,
            character_class,
            rarity,
            level,
            threat,
            attack,
            health,
            stars,
            alignment,
            created_at,
            updated_at
          FROM characters
          WHERE id = @id
          LIMIT 1;
        '''),
        parameters: {'id': id},
      );

      if (result.isEmpty) {
        return Error(EmptyResultFailure('Personagem nao encontrado.'));
      }

      return Success(_toCharacter(result.first.toColumnMap()));
    } catch (e) {
      return Error(
        ApiLocalFailure('PostgreSQL - Erro ao obter personagem por ID: $e'),
      );
    }
  }

  @override
  Future<CharacterResult> saveCharacter(Character character) async {
    try {
      final connection = await _postgresConnection.getConnection();

      final result = await connection.execute(
        Sql.named('''
          INSERT INTO characters (
            id,
            name,
            character_class,
            rarity,
            level,
            threat,
            attack,
            health,
            stars,
            alignment,
            created_at,
            updated_at
          )
          VALUES (
            @id,
            @name,
            @character_class,
            @rarity,
            @level,
            @threat,
            @attack,
            @health,
            @stars,
            @alignment,
            @created_at,
            @updated_at
          )
          RETURNING
            id,
            name,
            character_class,
            rarity,
            level,
            threat,
            attack,
            health,
            stars,
            alignment,
            created_at,
            updated_at;
        '''),
        parameters: _toDbMap(character),
      );

      return Success(_toCharacter(result.first.toColumnMap()));
    } on UniqueViolationException {
      return Error(InputFailure('Personagem ja existe.'));
    } catch (e) {
      return Error(
        ApiLocalFailure('PostgreSQL - Erro ao salvar personagem: $e'),
      );
    }
  }

  @override
  Future<CharacterResult> updateCharacter(Character character) async {
    if (character.id.trim().isEmpty) {
      return Error(InputFailure('ID invalido.'));
    }

    try {
      final connection = await _postgresConnection.getConnection();

      final result = await connection.execute(
        Sql.named('''
          UPDATE characters
          SET
            name = @name,
            character_class = @character_class,
            rarity = @rarity,
            level = @level,
            threat = @threat,
            attack = @attack,
            health = @health,
            stars = @stars,
            alignment = @alignment,
            created_at = @created_at,
            updated_at = @updated_at
          WHERE id = @id
          RETURNING
            id,
            name,
            character_class,
            rarity,
            level,
            threat,
            attack,
            health,
            stars,
            alignment,
            created_at,
            updated_at;
        '''),
        parameters: _toDbMap(character),
      );

      if (result.isEmpty) {
        return Error(EmptyResultFailure('Personagem nao encontrado.'));
      }

      return Success(_toCharacter(result.first.toColumnMap()));
    } catch (e) {
      return Error(
        ApiLocalFailure('PostgreSQL - Erro ao atualizar personagem: $e'),
      );
    }
  }

  Map<String, dynamic> _toDbMap(Character character) {
    return {
      'id': character.id,
      'name': character.name,
      'character_class': character.characterClass.name,
      'rarity': character.rarity.name,
      'level': character.level,
      'threat': character.threat,
      'attack': character.attack,
      'health': character.health,
      'stars': character.stars,
      'alignment': character.alignment.name,
      'created_at': character.createdAt,
      'updated_at': character.updatedAt,
    };
  }

  Character _toCharacter(Map<String, dynamic> data) {
    return Character(
      id: data['id'] as String,
      name: data['name'] as String,
      characterClass: CharacterClass.values.byName(
        data['character_class'] as String,
      ),
      rarity: CharacterRarity.values.byName(data['rarity'] as String),
      level: _toInt(data['level']),
      threat: _toInt(data['threat']),
      attack: _toInt(data['attack']),
      health: _toInt(data['health']),
      stars: _toInt(data['stars']),
      alignment: CharacterAlignment.values.byName(data['alignment'] as String),
      createdAt: _toDateTime(data['created_at']),
      updatedAt: _toDateTime(data['updated_at']),
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
}
