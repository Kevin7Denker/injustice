import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../domain/models/account_entity.dart';
import '../../../../../domain/models/character_entity.dart';
import '../../../../../domain/models/extensions/character_ui.dart';
import '../../../../controllers/characters_state_viewmodel.dart';
import '../../../../controllers/characters_view_model.dart';
import '../../../../widgets/account_summary_card.dart';
import '../../../../widgets/empty_state.dart';
import '../../../../widgets/loading_indicator.dart';
import '../../../../widgets/star_rating.dart';
import 'package:signals_flutter/signals_flutter.dart';

class CharactersBody extends StatelessWidget {
  final CharactersViewModel viewModel;
  final Account account;

  const CharactersBody({
    super.key,
    required this.viewModel,
    required this.account,
  });

  Future<void> _fetchCharacters() {
    return viewModel.commands.fetchCharacters();
  }

  void _showCharacterDetails(BuildContext context, Character character) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _CharacterDetailsSheet(character: character),
    );
  }

  Future<void> _editCharacter(BuildContext context, Character character) async {
    final updatedCharacter = await showModalBottomSheet<Character>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => CharacterFormSheet(character: character),
    );

    if (!context.mounted || updatedCharacter == null) return;

    await viewModel.commands.updateCharacter(updatedCharacter);

    if (!context.mounted) return;

    final message = viewModel.charactersState.message.value;
    final hasError = message != null && message.trim().isNotEmpty;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            hasError
                ? message
                : '${updatedCharacter.name} atualizado com sucesso',
          ),
        ),
      );
  }

  Future<void> _removeCharacterFromList(
    BuildContext context,
    Character character,
  ) async {
    final previousLength = viewModel.charactersState.state.value.length;

    await viewModel.commands.deleteCharacter(character);

    if (!context.mounted) return;

    final message = viewModel.charactersState.message.value;
    final hasError = message != null && message.trim().isNotEmpty;
    final currentLength = viewModel.charactersState.state.value.length;
    final wasRemoved = currentLength < previousLength;

    if (wasRemoved && !hasError) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('${character.name} excluido com sucesso'),
            action: SnackBarAction(
              label: 'Desfazer',
              onPressed: () async {
                await viewModel.commands.addCharacter(character);

                if (!context.mounted) return;

                final restoreError = viewModel.charactersState.message.value;
                if (restoreError == null || restoreError.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${character.name} restaurado')),
                  );
                }
              },
            ),
          ),
        );

      return;
    }

    final fallbackMessage = message ?? 'Nao foi possivel excluir o personagem.';

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(fallbackMessage)));
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final state = viewModel.charactersState;
      final isLoading =
          viewModel.commands.getAllCharactersCommand.isExecuting.value;
      final errorMessage = state.message.value;
      final hasError = errorMessage != null && errorMessage.trim().isNotEmpty;
      final characters = state.sortedCharacters.value;
      final hasCharacters = characters.isNotEmpty;
      final screenWidth = MediaQuery.sizeOf(context).width;
      final horizontalPadding = screenWidth < 360
          ? AppSpacing.sm
          : AppSpacing.md;

      return RefreshIndicator(
        onRefresh: _fetchCharacters,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            /// Header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  AppSpacing.md,
                  horizontalPadding,
                  AppSpacing.sm,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: AccountSummaryCard(account: account),
                  ),
                ),
              ),
            ),

            /// Filtros
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: FilterPanel(viewModel: viewModel),
                ),
              ),
            ),

            if (isLoading && hasCharacters)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: AppSpacing.xs,
                  ),
                  child: const LinearProgressIndicator(minHeight: 2),
                ),
              ),

            if (hasError && hasCharacters)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    AppSpacing.sm,
                    horizontalPadding,
                    AppSpacing.sm,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: _ErrorStateCard(
                        message: errorMessage,
                        onRetry: _fetchCharacters,
                      ),
                    ),
                  ),
                ),
              ),

            /// Conteúdo (loading | empty | lista)
            if (isLoading && !hasCharacters)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Semantics(
                  liveRegion: true,
                  label: 'Carregando personagens',
                  child: const LoadingIndicator(
                    message: 'Carregando personagens...',
                  ),
                ),
              )
            else if (hasError && !hasCharacters)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Semantics(
                  liveRegion: true,
                  label: 'Erro ao carregar personagens',
                  child: EmptyState(
                    icon: Icons.cloud_off_rounded,
                    title: 'Nao foi possivel carregar',
                    description: errorMessage,
                    action: Semantics(
                      button: true,
                      label: 'Tentar novamente',
                      child: ElevatedButton.icon(
                        onPressed: _fetchCharacters,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar novamente'),
                      ),
                    ),
                  ),
                ),
              )
            else if (!hasCharacters)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState.noCharacters(),
              )
            else
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final character = characters[index];
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: CharacterListItem(
                          character: character,
                          onEdit: () => _editCharacter(context, character),
                          onDelete: () =>
                              _removeCharacterFromList(context, character),
                          onTap: () =>
                              _showCharacterDetails(context, character),
                        ),
                      ),
                    );
                  }, childCount: characters.length),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _ErrorStateCard extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorStateCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.errorContainer,
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: context.textStyles.bodyMedium?.withColor(
                  colorScheme.onErrorContainer,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Item da lista de personagens
class CharacterListItem extends StatelessWidget {
  final Character character;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const CharacterListItem({
    super.key,
    required this.character,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(character.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: AppSpacing.lg),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onEdit();
          return false;
        } else {
          return await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmar exclusão'),
                  content: Text('Deseja realmente excluir ${character.name}?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Excluir'),
                    ),
                  ],
                ),
              ) ??
              false;
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete();
        }
      },
      child: Semantics(
        button: true,
        label:
            'Personagem ${character.name}, nivel ${character.level}, classe ${character.characterClass.displayName}, ${character.stars} estrelas',
        hint:
            'Toque para detalhes. Deslize para a direita para editar e para a esquerda para remover.',
        child: Card(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.9),
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Padding(
              padding: AppSpacing.paddingMd,
              child: Row(
                children: [
                  // Indicador de raridade
                  Container(
                    width: 4,
                    height: 60,
                    decoration: BoxDecoration(
                      color: character.rarity.color,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Conteúdo principal
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                character.name,
                                style: context.textStyles.titleMedium?.semiBold,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Nv. ${character.level}',
                              style: context.textStyles.labelLarge?.withColor(
                                Theme.of(context).colorScheme.onSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Icon(
                              character.characterClass.icon,
                              size: 16,
                              color: character.characterClass.color,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              character.characterClass.displayName,
                              style: context.textStyles.bodySmall?.withColor(
                                Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        StarRating(stars: character.stars, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CharacterDetailsSheet extends StatelessWidget {
  final Character character;

  const _CharacterDetailsSheet({required this.character});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              character.name,
              style: context.textStyles.headlineSmall?.semiBold,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _CharacterInfoChip(
                  icon: Icons.military_tech,
                  label: character.rarity.displayName,
                  color: character.rarity.color,
                ),
                _CharacterInfoChip(
                  icon: character.characterClass.icon,
                  label: character.characterClass.displayName,
                  color: character.characterClass.color,
                ),
                _CharacterInfoChip(
                  icon: Icons.balance,
                  label: character.alignment.displayName,
                  color: colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            StarRating(stars: character.stars),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _CharacterStatTile(
                    icon: Icons.trending_up,
                    label: 'Nivel',
                    value: '${character.level}',
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _CharacterStatTile(
                    icon: Icons.warning_amber_rounded,
                    label: 'Ameaca',
                    value: '${character.threat}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _CharacterStatTile(
                    icon: Icons.flash_on,
                    label: 'Ataque',
                    value: '${character.attack}',
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _CharacterStatTile(
                    icon: Icons.favorite,
                    label: 'Vida',
                    value: '${character.health}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CharacterFormSheet extends StatefulWidget {
  final Character? character;

  const CharacterFormSheet({super.key, this.character});

  bool get isEditMode => character != null;

  @override
  State<CharacterFormSheet> createState() => _CharacterFormSheetState();
}

class _CharacterFormSheetState extends State<CharacterFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _levelController;
  late final TextEditingController _starsController;
  late final TextEditingController _threatController;
  late final TextEditingController _attackController;
  late final TextEditingController _healthController;

  late CharacterClass _selectedClass;
  late CharacterRarity _selectedRarity;
  late CharacterAlignment _selectedAlignment;

  @override
  void initState() {
    super.initState();

    final character = widget.character;

    if (character != null) {
      _nameController = TextEditingController(text: character.name);
      _levelController = TextEditingController(
        text: character.level.toString(),
      );
      _starsController = TextEditingController(
        text: character.stars.toString(),
      );
      _threatController = TextEditingController(
        text: character.threat.toString(),
      );
      _attackController = TextEditingController(
        text: character.attack.toString(),
      );
      _healthController = TextEditingController(
        text: character.health.toString(),
      );

      _selectedClass = character.characterClass;
      _selectedRarity = character.rarity;
      _selectedAlignment = character.alignment;
      return;
    }

    _nameController = TextEditingController();
    _levelController = TextEditingController(text: '1');
    _starsController = TextEditingController(text: '1');
    _threatController = TextEditingController(text: '0');
    _attackController = TextEditingController(text: '0');
    _healthController = TextEditingController(text: '0');

    _selectedClass = CharacterClass.poderoso;
    _selectedRarity = CharacterRarity.prata;
    _selectedAlignment = CharacterAlignment.heroi;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _levelController.dispose();
    _starsController.dispose();
    _threatController.dispose();
    _attackController.dispose();
    _healthController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Informe o nome';
    if (text.length < 2) return 'Nome muito curto';
    return null;
  }

  String? _validateInt(
    String? value, {
    required String fieldLabel,
    required int min,
    int? max,
  }) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null) return '$fieldLabel invalido';
    if (parsed < min) return '$fieldLabel deve ser >= $min';
    if (max != null && parsed > max) return '$fieldLabel deve ser <= $max';
    return null;
  }

  void _submit() {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    final now = DateTime.now();
    final characterInEdition = widget.character;

    final character = characterInEdition != null
        ? characterInEdition.copyWith(
            name: _nameController.text.trim(),
            level: int.parse(_levelController.text.trim()),
            stars: int.parse(_starsController.text.trim()),
            threat: int.parse(_threatController.text.trim()),
            attack: int.parse(_attackController.text.trim()),
            health: int.parse(_healthController.text.trim()),
            characterClass: _selectedClass,
            rarity: _selectedRarity,
            alignment: _selectedAlignment,
            updatedAt: now,
          )
        : Character(
            id: now.microsecondsSinceEpoch.toString(),
            name: _nameController.text.trim(),
            level: int.parse(_levelController.text.trim()),
            stars: int.parse(_starsController.text.trim()),
            threat: int.parse(_threatController.text.trim()),
            attack: int.parse(_attackController.text.trim()),
            health: int.parse(_healthController.text.trim()),
            characterClass: _selectedClass,
            rarity: _selectedRarity,
            alignment: _selectedAlignment,
            createdAt: now,
            updatedAt: now,
          );

    Navigator.of(context).pop(character);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isEditMode = widget.isEditMode;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg + mediaQuery.viewInsets.bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditMode ? 'Editar personagem' : 'Novo personagem',
                style: context.textStyles.headlineSmall?.semiBold,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: _validateName,
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<CharacterClass>(
                initialValue: _selectedClass,
                decoration: const InputDecoration(
                  labelText: 'Classe',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: CharacterClass.values
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(item.displayName),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedClass = value);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<CharacterRarity>(
                      initialValue: _selectedRarity,
                      decoration: const InputDecoration(
                        labelText: 'Raridade',
                        prefixIcon: Icon(Icons.military_tech_outlined),
                      ),
                      items: CharacterRarity.values
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item.displayName),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _selectedRarity = value);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: DropdownButtonFormField<CharacterAlignment>(
                      initialValue: _selectedAlignment,
                      decoration: const InputDecoration(
                        labelText: 'Alinhamento',
                        prefixIcon: Icon(Icons.balance_outlined),
                      ),
                      items: CharacterAlignment.values
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item.displayName),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _selectedAlignment = value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _levelController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Nivel',
                        prefixIcon: Icon(Icons.trending_up),
                      ),
                      validator: (value) => _validateInt(
                        value,
                        fieldLabel: 'Nivel',
                        min: 1,
                        max: 80,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextFormField(
                      controller: _starsController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Estrelas',
                        prefixIcon: Icon(Icons.star_outline),
                      ),
                      validator: (value) => _validateInt(
                        value,
                        fieldLabel: 'Estrelas',
                        min: 1,
                        max: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _threatController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Ameaca',
                        prefixIcon: Icon(Icons.warning_amber_outlined),
                      ),
                      validator: (value) =>
                          _validateInt(value, fieldLabel: 'Ameaca', min: 0),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextFormField(
                      controller: _attackController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Ataque',
                        prefixIcon: Icon(Icons.flash_on_outlined),
                      ),
                      validator: (value) =>
                          _validateInt(value, fieldLabel: 'Ataque', min: 0),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextFormField(
                      controller: _healthController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Vida',
                        prefixIcon: Icon(Icons.favorite_outline),
                      ),
                      validator: (value) =>
                          _validateInt(value, fieldLabel: 'Vida', min: 0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _submit,
                      icon: Icon(isEditMode ? Icons.save_outlined : Icons.add),
                      label: Text(isEditMode ? 'Salvar' : 'Adicionar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CharacterInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _CharacterInfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _CharacterStatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _CharacterStatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: context.textStyles.labelMedium),
                Text(value, style: context.textStyles.titleMedium?.semiBold),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FilterPanel extends StatelessWidget {
  final CharactersViewModel viewModel;

  const FilterPanel({super.key, required this.viewModel});

  CharactersStateViewmodel get state => viewModel.charactersState;

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final filtersCount = state.activeFiltersCount.value;
      final isExpanded = state.isFilterPanelExpanded.value;

      return Container(
        margin: EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          bottom: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.85),
              Theme.of(context).colorScheme.secondary,
              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
          color: Theme.of(context).colorScheme.secondary,
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
              width: 1,
            ),
          ),
        ),
        child: Column(
          children: [
            // Cabeçalho do painel
            InkWell(
              onTap: state.toggleFilterPanel,
              child: Padding(
                padding: AppSpacing.paddingMd,
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_list,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Filtros',
                      style: context.textStyles.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    if (filtersCount > 0) ...[
                      const SizedBox(width: 6),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$filtersCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],

                    const Spacer(),

                    if (filtersCount > 0)
                      TextButton.icon(
                        onPressed: state.clearFilters,
                        icon: const Icon(Icons.clear, size: 16),
                        label: const Text('Limpar'),
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onSecondary,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ],
                ),
              ),
            ),

            // Conteúdo do painel (expansível)
            if (isExpanded)
              // if (_isExpanded)
              SizedBox(
                width: double.infinity,
                child: _FiltersContent(state: state),
              ),
          ],
        ),
      );
    });
  }
}

class _FiltersContent extends StatelessWidget {
  const _FiltersContent({required this.state});

  final CharactersStateViewmodel state;

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 RARIDADE
            _FilterSection(
              title: 'Raridade',
              sectionKey: 'rarity',
              state: state,
              child: Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: CharacterRarity.values.map((rarity) {
                  final isSelected = state.selectedRarities.value.contains(
                    rarity,
                  );

                  return FilterChip(
                    label: Text(
                      rarity.displayName,
                      style: TextStyle(color: rarity.color),
                    ),
                    selected: isSelected,
                    onSelected: (_) => state.toggleRarity(rarity),
                  );
                }).toList(),
              ),
            ),

            /// 🔹 CLASSE
            _FilterSection(
              title: 'Classe',
              sectionKey: 'class',
              state: state,
              child: Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: CharacterClass.values.map((characterClass) {
                  final isSelected = state.selectedClasses.value.contains(
                    characterClass,
                  );

                  return FilterChip(
                    label: Text(
                      characterClass.displayName,
                      style: TextStyle(color: characterClass.color),
                    ),
                    selected: isSelected,
                    onSelected: (_) => state.toggleClass(characterClass),
                  );
                }).toList(),
              ),
            ),

            /// 🔹 LEVEL
            _FilterSection(
              title: 'Level',
              sectionKey: 'level',
              state: state,
              child: Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: LevelFilter.values.map((filter) {
                  return FilterChip(
                    label: Text(filter.label),
                    selected: state.levelFilter.value == filter,
                    onSelected: (_) => state.setLevelFilter(filter),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final String sectionKey;
  final CharactersStateViewmodel state;
  final Widget child;

  const _FilterSection({
    required this.title,
    required this.sectionKey,
    required this.state,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final isExpanded = state.isSectionExpanded(sectionKey);
      final selectedCount = switch (sectionKey) {
        'rarity' => state.selectedRarities.value.length,
        'class' => state.selectedClasses.value.length,
        'alignment' => state.selectedAlignments.value.length,
        _ => 0,
      };

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => state.toggleSection(sectionKey),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  Text(title),
                  if (selectedCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$selectedCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ],
              ),
            ),
          ),

          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: child,
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),

          const SizedBox(height: AppSpacing.md),
        ],
      );
    });
  }
}
