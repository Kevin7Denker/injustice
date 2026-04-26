import 'package:flutter/material.dart';
import '../../../../../domain/models/character_entity.dart';
import '../../../../controllers/characters_view_model.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'characters_body.dart';

class CharactersFab extends StatelessWidget {
  final CharactersViewModel viewModel;

  const CharactersFab({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final isExecuting =
          viewModel.commands.createCharacterCommand.isExecuting.value;

      return FloatingActionButton(
        onPressed: isExecuting
            ? null
            : () async {
                final newCharacter = await showModalBottomSheet<Character>(
                  context: context,
                  showDragHandle: true,
                  isScrollControlled: true,
                  builder: (_) => const CharacterFormSheet(),
                );

                if (!context.mounted || newCharacter == null) return;

                await viewModel.commands.addCharacter(newCharacter);

                if (!context.mounted) return;

                final message = viewModel.charactersState.message.value;
                final feedbackMessage =
                    message != null && message.trim().isNotEmpty
                    ? message
                    : '${newCharacter.name} adicionado com sucesso';

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(feedbackMessage)));
              },
        child: isExecuting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.add),
      );
    });
  }
}
