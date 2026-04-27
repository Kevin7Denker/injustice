import '../../core/typedefs/types_defs.dart';
import '../../data/repositories/character_repository_interface.dart';
import 'character_usecases_interfaces.dart';

final class GetCharacterByIdUseCaseImpl implements IGetCharacterByIdUseCase {
  final ICharacterRepository _repository;

  GetCharacterByIdUseCaseImpl({required ICharacterRepository repository})
    : _repository = repository;

  @override
  Future<CharacterResult> call(CharacterIdParams params) {
    return _repository.getCharacterById(params.id);
  }
}

final class GetAllCharactersUseCaseImpl implements IGetAllCharactersUseCase {
  final ICharacterRepository _repository;

  GetAllCharactersUseCaseImpl({required ICharacterRepository repository})
    : _repository = repository;

  @override
  Future<ListCharacterResult> call(NoParams params) async {
    await Future.delayed(const Duration(seconds: 3));
    return _repository.getAllCharacters();
  }
}

final class SaveCharacterUseCaseImpl implements ISaveCharacterUseCase {
  final ICharacterRepository _repository;

  SaveCharacterUseCaseImpl({required ICharacterRepository repository})
    : _repository = repository;

  @override
  Future<CharacterResult> call(CharacterParams params) async {
    await Future.delayed(const Duration(seconds: 3));
    return _repository.saveCharacter(params.character);
  }
}

final class UpdateCharacterUseCaseImpl implements IUpdateCharacterUseCase {
  final ICharacterRepository _repository;

  UpdateCharacterUseCaseImpl({required ICharacterRepository repository})
    : _repository = repository;

  @override
  Future<CharacterResult> call(CharacterParams params) async {
    await Future.delayed(const Duration(seconds: 3));
    return _repository.updateCharacter(params.character);
  }
}

final class DeleteCharacterUseCaseImpl implements IDeleteCharacterUseCase {
  final ICharacterRepository _repository;

  DeleteCharacterUseCaseImpl({required ICharacterRepository repository})
    : _repository = repository;

  @override
  Future<CharacterResult> call(CharacterIdParams params) {
    return _repository.deleteCharacter(params.id);
  }
}
