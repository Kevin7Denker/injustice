import '../../core/failure/failure.dart';
import '../../core/patterns/command.dart';
import '../../domain/models/character_entity.dart';
import '../commands/character_commands.dart';
import 'characters_state_viewmodel.dart';
import 'package:signals_flutter/signals_flutter.dart';

class CharactersCommandsViewModel {
  final CharactersStateViewmodel state;
  final GetAllCharactersCommand _getAccountCommand;
  final CreateCharacterCommand _createCharacterCommand;
  final UpdateCharacterCommand _updateCharacterCommand;
  final DeleteCharacterCommand _deleteCharacterCommand;

  CharactersCommandsViewModel({
    required this.state,
    required GetAllCharactersCommand getAccountCommand,
    required CreateCharacterCommand createCharacterCommand,
    required UpdateCharacterCommand updateCharacterCommand,
    required DeleteCharacterCommand deleteCharacterCommand,
  }) : _getAccountCommand = getAccountCommand,
       _createCharacterCommand = createCharacterCommand,
       _updateCharacterCommand = updateCharacterCommand,
       _deleteCharacterCommand = deleteCharacterCommand {
    // Observers para cada comando
    _observeGetAllCharacters();
    _observeCreateCharacter();
    _observeUpdateCharacter();
    _observeDeleteCharacter();
  }

  // ========================================================
  //   GETTERS PARA WIDGETS USAREM DIRETAMENTE OS COMANDOS
  // ========================================================
  GetAllCharactersCommand get getAllCharactersCommand => _getAccountCommand;
  CreateCharacterCommand get createCharacterCommand => _createCharacterCommand;
  UpdateCharacterCommand get updateCharacterCommand => _updateCharacterCommand;
  DeleteCharacterCommand get deleteCharacterCommand => _deleteCharacterCommand;

  // ========================================================
  //   MÉTODO GENÉRICO DE OBSERVAÇÃO DE COMANDOS
  // ========================================================
  void _observeCommand<T>(
    Command<T, Failure> command, {
    required void Function(T data) onSuccess,
    void Function(Failure err)? onFailure,
  }) {
    effect(() {
      // 1) Ignora enquanto está executando
      if (command.isExecuting.value) return;

      // 2) Ignora até existir um resultado
      final result = command.result.value;
      if (result == null) return;

      // 3) Sucesso ou falha
      result.fold(
        onSuccess: (data) {
          state.clearMessage(); // sempre limpa erros em sucesso
          onSuccess(data); // ação específica para esse comando
          command.clear();
        },
        onFailure: (err) {
          state.setMessage(err.msg); // registra o erro no estado
          if (onFailure != null) onFailure(err);
          command.clear();
        },
      );
    });
  }

  // ========================================================
  //   OBSERVERS ESPECÍFICOS
  // ========================================================

  /// Buscar todos os personagens
  void _observeGetAllCharacters() {
    _observeCommand<List<Character>>(
      _getAccountCommand,
      onSuccess: (characters) {
        state.clearMessage(); // Limpa mensagens anteriores
        state.state.value = characters;
      },
      onFailure: (err) =>
          state.setMessage(err.msg), // registra o erro no estado
    );
  }

  /// Criar um novo personagem
  void _observeCreateCharacter() {
    _observeCommand<Character>(
      _createCharacterCommand,
      onSuccess: (newCharacter) {
        final currentList = state.state.value;
        final newlist = [
          ...currentList,
          newCharacter,
        ]; // Adiciona o novo personagem a lista
        state.state.value = newlist;
      },
      onFailure: (err) =>
          state.setMessage(err.msg), // registra o erro no estado
    );
  }

  /// Atualizar um personagem existente
  void _observeUpdateCharacter() {
    _observeCommand<Character>(
      _updateCharacterCommand,
      onSuccess: (updatedCharacter) {
        final currentList = state.state.value;
        final index = currentList.indexWhere(
          (item) => item.id == updatedCharacter.id,
        );

        if (index < 0) {
          state.state.value = [...currentList, updatedCharacter];
          return;
        }

        final updatedList = List<Character>.from(currentList);
        updatedList[index] = updatedCharacter;
        state.state.value = updatedList;
      },
      onFailure: (err) =>
          state.setMessage(err.msg), // registra o erro no estado
    );
  }

  /// Deletar um personagem existente
  void _observeDeleteCharacter() {
    _observeCommand<Character>(
      _deleteCharacterCommand,
      onSuccess: (deletedCharacter) {
        final updatedList = state.state.value
            .where((item) => item.id != deletedCharacter.id)
            .toList(growable: false);
        state.state.value = updatedList;
      },
      onFailure: (err) =>
          state.setMessage(err.msg), // registra o erro no estado
    );
  }

  // ========================================================
  //   MÉTODOS PÚBLICOS (CHAMADOS PELOS WIDGETS)
  //   que disparam os commands
  // ========================================================
  /// buscca personagens e atualiza o estado
  Future<void> fetchCharacters() async {
    state.clearMessage(); // Limpa mensagens anteriores
    await _getAccountCommand.executeWith(());
  }

  /// adiciona personagem e atualiza o estado
  Future<void> addCharacter(Character character) async {
    state.clearMessage(); // Limpa mensagens anteriores
    await _createCharacterCommand.executeWith((character: character));
  }

  /// atualiza personagem e estado
  Future<void> updateCharacter(Character character) async {
    state.clearMessage(); // Limpa mensagens anteriores
    await _updateCharacterCommand.executeWith((character: character));
  }

  /// remove personagem e atualiza estado
  Future<void> deleteCharacter(Character character) async {
    state.clearMessage(); // Limpa mensagens anteriores
    await _deleteCharacterCommand.executeWith((id: character.id));
  }
}
