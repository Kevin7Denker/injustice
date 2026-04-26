import 'package:flutter/material.dart';
import '../../core/di/dependency_injection.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/account_entity.dart';
import '../../domain/models/character_entity.dart';
import '../../domain/models/extensions/character_ui.dart';
import '../controllers/characters_state_viewmodel.dart';
import '../controllers/characters_view_model.dart';
import '../widgets/account_summary_card.dart';
import '../widgets/app_drawer.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/star_rating.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../helper_dev/fakes/factories.dart';

/// Página de listagem de personagens
class CharactersView extends StatefulWidget {
  final Account account;

  const CharactersView({super.key, required this.account});

  @override
  State<CharactersView> createState() => _CharactersViewState();
}

class _CharactersViewState extends State<CharactersView> {
  late final CharactersViewModel _viewModel;
  Account get account => widget.account;

  @override
  void initState() {
    super.initState();
    _viewModel = injector.get<CharactersViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.commands.fetchCharacters();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _deleteCharacter(Character character) async {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(
        content: Text('${character.name} removido'),
        backgroundColor: AppColors.hotMagenta,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PERSONAGENS'),
        actions: [
          // Sort direction button
          Watch((context) {
            final order = _viewModel.charactersState.sortOrder.value;
            return IconButton(
              icon: Icon(
                order == SortOrder.ascending
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                color: AppColors.neonCyan,
              ),
              tooltip: order == SortOrder.ascending
                  ? 'Ascendente'
                  : 'Descendente',
              onPressed: _viewModel.charactersState.toggleSortOrder,
            );
          }),
          // Sort by button
          Watch((context) {
            final currentSort = _viewModel.charactersState.sortBy.value;
            return PopupMenuButton<SortBy>(
              icon: Icon(Icons.sort_rounded, color: AppColors.coolWhiteMuted),
              tooltip: 'Ordenar',
              onSelected: _viewModel.charactersState.setSortBy,
              itemBuilder: (context) => [
                _buildSortMenuItem(
                  value: SortBy.name,
                  icon: Icons.sort_by_alpha_rounded,
                  label: 'Nome',
                  isSelected: currentSort == SortBy.name,
                ),
                _buildSortMenuItem(
                  value: SortBy.level,
                  icon: Icons.trending_up_rounded,
                  label: 'Level',
                  isSelected: currentSort == SortBy.level,
                ),
                _buildSortMenuItem(
                  value: SortBy.stars,
                  icon: Icons.star_rounded,
                  label: 'Estrelas',
                  isSelected: currentSort == SortBy.stars,
                ),
              ],
            );
          }),
        ],
      ),

      drawer: AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: AppSpacing.paddingMd,
            child: AccountSummaryCard(account: account),
          ),
          FilterPanel(viewModel: _viewModel),
          Expanded(
            child: Watch((context) {
              final isLoading =
                  _viewModel.commands.getAllCharactersCommand.isExecuting.value;

              if (isLoading) {
                return LoadingIndicator(message: 'Carregando personagens...');
              }

              final characters = _viewModel.charactersState.state.value;

              if (characters.isEmpty) {
                return EmptyState();
              }

              return RefreshIndicator(
                onRefresh: () async {},
                color: AppColors.neonCyan,
                backgroundColor: AppColors.surface,
                child: ListView.builder(
                  padding: AppSpacing.paddingMd,
                  itemCount: characters.length,
                  itemBuilder: (context, index) {
                    final character = characters[index];
                    return CharacterListItem(
                      character: character,
                      onDelete: () => _deleteCharacter(character),
                      onTap: () {},
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Watch((context) {
        final isExecuting =
            _viewModel.commands.createCharacterCommand.isExecuting.value;

        return FloatingActionButton(
          onPressed: isExecuting
              ? null
              : () async {
                  final character = CharacterFactory.list(1).first;
                  await _viewModel.commands.addCharacter(character);
                },
          child: isExecuting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.void_,
                  ),
                )
              : const Icon(Icons.add_rounded),
        );
      }),
    );
  }

  PopupMenuItem<SortBy> _buildSortMenuItem({
    required SortBy value,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.neonCyan : AppColors.coolWhiteMuted,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.neonCyan : AppColors.coolWhite,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.xxl,
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceVariant,
                border: Border.all(color: AppColors.outline),
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                size: 40,
                color: AppColors.coolWhiteFaint,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'NENHUM PERSONAGEM',
              style: context.textStyles.headlineSmall?.copyWith(
                color: AppColors.coolWhiteMuted,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Adicione seu primeiro personagem usando o botão +',
              textAlign: TextAlign.center,
              style: context.textStyles.bodyMedium?.copyWith(
                color: AppColors.coolWhiteFaint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Character list item with rarity glow stripe
class CharacterListItem extends StatelessWidget {
  final Character character;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const CharacterListItem({
    super.key,
    required this.character,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final rarityColor = character.rarity.color;

    return Dismissible(
      key: Key(character.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.techBlue.withOpacity(0.8),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: AppSpacing.lg),
        child: const Icon(Icons.edit_rounded, color: Colors.white),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.hotMagenta.withOpacity(0.8),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onTap();
          return false;
        } else {
          return await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('CONFIRMAR EXCLUSÃO'),
                  content: Text('Deseja realmente excluir ${character.name}?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(color: AppColors.coolWhiteMuted),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        'Excluir',
                        style: TextStyle(color: AppColors.hotMagenta),
                      ),
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
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.outline, width: 1),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Rarity glow stripe
                Container(
                  width: 4,
                  height: 56,
                  decoration: BoxDecoration(
                    color: rarityColor,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: rarityColor.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              character.name,
                              style: context.textStyles.titleMedium?.copyWith(
                                color: AppColors.coolWhite,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          // Level badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.neonCyan.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.neonCyan.withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              'Nv.${character.level}',
                              style: context.textStyles.labelSmall?.copyWith(
                                color: AppColors.neonCyan,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Icon(
                            character.characterClass.icon,
                            size: 14,
                            color: character.characterClass.color,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            character.characterClass.displayName,
                            style: context.textStyles.bodySmall?.copyWith(
                              color: AppColors.coolWhiteMuted,
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

      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        margin: EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          bottom: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.outline, width: 1),
        ),
        child: Column(
          children: [
            // Header
            InkWell(
              onTap: state.toggleFilterPanel,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Padding(
                padding: AppSpacing.paddingMd,
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_list_rounded,
                      color: AppColors.coolWhiteMuted,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'FILTROS',
                      style: context.textStyles.labelLarge?.copyWith(
                        color: AppColors.coolWhite,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),

                    if (filtersCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.neonCyan.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.neonCyan.withOpacity(0.25),
                          ),
                        ),
                        child: Text(
                          '$filtersCount',
                          style: TextStyle(
                            color: AppColors.neonCyan,
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
                        icon: Icon(Icons.clear_rounded, size: 14,
                            color: AppColors.hotMagenta),
                        label: Text(
                          'Limpar',
                          style: TextStyle(
                            color: AppColors.hotMagenta,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    Icon(
                      isExpanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: AppColors.coolWhiteMuted,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),

            // Expandable content
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _FiltersContent(state: state),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
              sizeCurve: Curves.easeOutCubic,
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
      return ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 450),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Divider ──
                Container(
                  height: 1,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  color: AppColors.outline,
                ),

                // Rarity filter
                Text(
                  'RARIDADE',
                  style: context.textStyles.labelLarge?.copyWith(
                    color: AppColors.coolWhiteMuted,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: CharacterRarity.values.map((rarity) {
                    final isSelected = state.selectedRarities.value.contains(
                      rarity,
                    );

                    return FilterChip(
                      label: Text(rarity.displayName),
                      selected: isSelected,
                      selectedColor: rarity.color.withOpacity(0.12),
                      side: BorderSide(
                        color: isSelected
                            ? rarity.color.withOpacity(0.45)
                            : AppColors.outline,
                      ),
                      labelStyle: TextStyle(
                        color: isSelected ? rarity.color : AppColors.coolWhiteMuted,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      onSelected: (_) => state.toggleRarity(rarity),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.md),

                // Class filter
                Text(
                  'CLASSE',
                  style: context.textStyles.labelLarge?.copyWith(
                    color: AppColors.coolWhiteMuted,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  alignment: WrapAlignment.start,
                  children: CharacterClass.values.map((characterClass) {
                    final isSelected = state.selectedClasses.value.contains(
                      characterClass,
                    );
                    return FilterChip(
                      label: Text(characterClass.displayName),
                      selected: isSelected,
                      selectedColor: characterClass.color.withOpacity(0.12),
                      side: BorderSide(
                        color: isSelected
                            ? characterClass.color.withOpacity(0.45)
                            : AppColors.outline,
                      ),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? characterClass.color
                            : AppColors.coolWhiteMuted,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      onSelected: (_) => state.toggleClass(characterClass),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.md),

                // Level filter
                Text(
                  'LEVEL',
                  style: context.textStyles.labelLarge?.copyWith(
                    color: AppColors.coolWhiteMuted,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: LevelFilter.values.map((filter) {
                    final isSelected = state.levelFilter.value == filter;
                    return FilterChip(
                      label: Text(filter.label),
                      selected: isSelected,
                      selectedColor: AppColors.neonCyan.withOpacity(0.10),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.neonCyan.withOpacity(0.35)
                            : AppColors.outline,
                      ),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.neonCyan : AppColors.coolWhiteMuted,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      onSelected: (_) => state.setLevelFilter(filter),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
