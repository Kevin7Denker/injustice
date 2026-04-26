import 'package:flutter_test/flutter_test.dart';
import 'package:injustice_app/core/failure/failure.dart';
import 'package:injustice_app/core/patterns/result.dart';
import 'package:injustice_app/core/typedefs/types_defs.dart';
import 'package:injustice_app/domain/facades/character_facade_usecases_interface.dart';
import 'package:injustice_app/domain/models/character_entity.dart';
import 'package:injustice_app/presentation/controllers/characters_view_model.dart';

void main() {
  group('CharactersViewModel CRUD', () {
    late _FakeCharacterFacade facade;
    late CharactersViewModel viewModel;

    setUp(() {
      facade = _FakeCharacterFacade();
      viewModel = CharactersViewModel(facade);
    });

    test('adiciona personagem no estado', () async {
      final character = _buildCharacter(id: '1', name: 'Batman');

      await viewModel.commands.addCharacter(character);
      await _flushEffects();

      expect(viewModel.charactersState.state.value, hasLength(1));
      expect(viewModel.charactersState.state.value.first, equals(character));
      expect(viewModel.charactersState.message.value, isNull);
    });

    test('edita personagem existente no estado', () async {
      final character = _buildCharacter(id: '2', name: 'Superman', level: 20);
      await viewModel.commands.addCharacter(character);
      await _flushEffects();

      final updated = character.copyWith(name: 'Superman Prime', level: 80);
      await viewModel.commands.updateCharacter(updated);
      await _flushEffects();

      final state = viewModel.charactersState.state.value;
      expect(state, hasLength(1));
      expect(state.first.name, equals('Superman Prime'));
      expect(state.first.level, equals(80));
      expect(state.first.id, equals('2'));
      expect(viewModel.charactersState.message.value, isNull);
    });

    test('remove personagem do estado', () async {
      final character = _buildCharacter(id: '3', name: 'Mulher Maravilha');
      await viewModel.commands.addCharacter(character);
      await _flushEffects();

      await viewModel.commands.deleteCharacter(character);
      await _flushEffects();

      expect(viewModel.charactersState.state.value, isEmpty);
      expect(viewModel.charactersState.message.value, isNull);
    });
  });
}

Future<void> _flushEffects() async {
  await Future<void>.delayed(Duration.zero);
}

Character _buildCharacter({
  required String id,
  required String name,
  int level = 1,
  int stars = 1,
  int threat = 0,
  int attack = 10,
  int health = 100,
}) {
  final now = DateTime.now();

  return Character(
    id: id,
    name: name,
    characterClass: CharacterClass.poderoso,
    rarity: CharacterRarity.ouro,
    level: level,
    threat: threat,
    attack: attack,
    health: health,
    stars: stars,
    alignment: CharacterAlignment.heroi,
    createdAt: now,
    updatedAt: now,
  );
}

final class _FakeCharacterFacade implements ICharacterFacadeUseCases {
  final Map<String, Character> _storage = <String, Character>{};

  @override
  Future<CharacterResult> deleteCharacter(CharacterIdParams params) async {
    if (params.id.trim().isEmpty) {
      return Error(InputFailure('ID invalido.'));
    }

    final removed = _storage.remove(params.id);
    if (removed == null) {
      return Error(EmptyResultFailure('Personagem nao encontrado.'));
    }

    return Success(removed);
  }

  @override
  Future<ListCharacterResult> getAllCharacters(NoParams params) async {
    return Success(_storage.values.toList(growable: false));
  }

  @override
  Future<CharacterResult> getCharacterById(CharacterIdParams params) async {
    if (params.id.trim().isEmpty) {
      return Error(InputFailure('ID invalido.'));
    }

    final character = _storage[params.id];
    if (character == null) {
      return Error(EmptyResultFailure('Personagem nao encontrado.'));
    }

    return Success(character);
  }

  @override
  Future<CharacterResult> saveCharacter(CharacterParams params) async {
    final character = params.character;
    if (character.id.trim().isEmpty) {
      return Error(InputFailure('ID invalido.'));
    }

    if (_storage.containsKey(character.id)) {
      return Error(InputFailure('Personagem ja existe.'));
    }

    _storage[character.id] = character;
    return Success(character);
  }

  @override
  Future<CharacterResult> updateCharacter(CharacterParams params) async {
    final character = params.character;
    if (character.id.trim().isEmpty) {
      return Error(InputFailure('ID invalido.'));
    }

    if (!_storage.containsKey(character.id)) {
      return Error(EmptyResultFailure('Personagem nao encontrado.'));
    }

    _storage[character.id] = character;
    return Success(character);
  }
}
