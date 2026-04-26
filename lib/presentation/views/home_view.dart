import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/dependency_injection.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/account_viewmodel.dart';
import '../widgets/app_drawer.dart';
import 'package:intl/intl.dart';
import 'package:signals_flutter/signals_flutter.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  late final AccountViewModel _vmAccount;

  // ── Orchestrated stagger system ──
  late final AnimationController _staggerController;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  // ── Hero icon pulse ──
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  // ── Gradient shimmer ──
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _vmAccount = injector.get<AccountViewModel>();
    _vmAccount.getAccountCommand();

    // Staggered entrance — 6 slots, each delayed 80ms
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnims = List.generate(7, (i) {
      final start = (i * 0.10).clamp(0.0, 0.7);
      final end = (start + 0.35).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      );
    });

    _slideAnims = List.generate(7, (i) {
      final start = (i * 0.10).clamp(0.0, 0.7);
      final end = (start + 0.35).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ));
    });

    // Looping pulse glow on hero icon
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.25, end: 0.55).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Shimmer sweep on CTA button
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();

    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  // ── Stagger helper ──
  Widget _staggerSlot(int index, Widget child) {
    return SlideTransition(
      position: _slideAnims[index.clamp(0, 6)],
      child: FadeTransition(
        opacity: _fadeAnims[index.clamp(0, 6)],
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PLAYER ACCOUNT')),
      drawer: AppDrawer(),
      body: Watch((context) {
        if (_vmAccount.saveAccountCommand.isExecuting.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.neonCyan),
          );
        }

        if (!_vmAccount.accountState.hasAccount.value) {
          return _buildWelcomeContent(context);
        }

        return _accountDashboard(context);
      }),
    );
  }

  // ===========================================================================
  // WELCOME CONTENT — no account exists
  // ===========================================================================
  Widget _buildWelcomeContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 48),

          // ── SLOT 0: Animated pulsing hero icon ──
          _staggerSlot(0, _buildPulsingHeroIcon()),

          const SizedBox(height: 36),

          // ── SLOT 1: Big headline ──
          _staggerSlot(
            1,
            Text(
              'PREPARE FOR\nBATTLE',
              style: context.textStyles.displayMedium?.copyWith(
                color: AppColors.coolWhite,
                height: 1.0,
                letterSpacing: 4,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 16),

          // ── Animated gradient divider ──
          _staggerSlot(1, _buildAnimatedDivider()),

          const SizedBox(height: 24),

          // ── SLOT 2: Subtitle ──
          _staggerSlot(
            2,
            Text(
              'Um jogo épico de RPG onde você controla heróis poderosos, '
              'explora mundos fantásticos e enfrenta desafios emocionantes.',
              style: context.textStyles.bodyMedium?.copyWith(
                color: AppColors.coolWhiteMuted,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 36),

          // ── SLOT 3-4: Feature cards grid (2 per row) ──
          _staggerSlot(3, _buildFeatureGrid()),

          const SizedBox(height: 36),

          // ── SLOT 5: Animated CTA button ──
          _staggerSlot(5, _buildShimmerCTA(context)),

          const SizedBox(height: 48),
        ],
      ),
    );
  }

  // ── Pulsing hero icon with animated glow ──
  Widget _buildPulsingHeroIcon() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) {
        return Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.accentGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.neonCyan.withOpacity(_pulseAnim.value),
                blurRadius: 40,
                spreadRadius: 6,
              ),
              BoxShadow(
                color: AppColors.plasmaViolet.withOpacity(
                  _pulseAnim.value * 0.5,
                ),
                blurRadius: 60,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.radar_rounded,
            size: 52,
            color: AppColors.void_,
          ),
        );
      },
    );
  }

  // ── Gradient divider with shimmer sweep ──
  Widget _buildAnimatedDivider() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, _) {
        return Container(
          width: 100,
          height: 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: LinearGradient(
              colors: [
                AppColors.neonCyan.withOpacity(0.3),
                AppColors.neonCyan,
                AppColors.plasmaViolet,
                AppColors.plasmaViolet.withOpacity(0.3),
              ],
              stops: [
                0.0,
                _shimmerController.value.clamp(0.1, 0.4),
                _shimmerController.value.clamp(0.6, 0.9),
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Feature cards in 2×3 grid ──
  Widget _buildFeatureGrid() {
    final features = [
      (Icons.flash_on_rounded, 'Combate', 'Estratégico e dinâmico'),
      (Icons.people_rounded, 'Personagens', '50+ heróis únicos'),
      (Icons.public_rounded, 'Mundos', 'Vastos para explorar'),
      (Icons.trending_up_rounded, 'Progressão', 'Sistema profundo'),
      (Icons.group_rounded, 'Multiplayer', 'Cooperativo online'),
      (Icons.event_rounded, 'Eventos', 'Semanais exclusivos'),
    ];

    return Column(
      children: [
        for (int row = 0; row < 3; row++) ...[
          if (row > 0) const SizedBox(height: 12),
          _staggerSlot(
            3 + row,
            Row(
              children: [
                Expanded(
                  child: _FeatureCard(
                    icon: features[row * 2].$1,
                    title: features[row * 2].$2,
                    subtitle: features[row * 2].$3,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FeatureCard(
                    icon: features[row * 2 + 1].$1,
                    title: features[row * 2 + 1].$2,
                    subtitle: features[row * 2 + 1].$3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── Shimmer-glow CTA button ──
  Widget _buildShimmerCTA(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: AppColors.accentGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonCyan.withOpacity(
                  0.15 + (_shimmerController.value * 0.15),
                ),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        );
      },
      child: FilledButton.icon(
        onPressed: () => context.goNamed(AppRouteNames.accountCreate),
        icon: const Icon(Icons.person_add_rounded, size: 20),
        label: const Text('CRIAR CONTA'),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.void_,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // ACCOUNT DASHBOARD — when user has an account
  // ===========================================================================
  Widget _accountDashboard(BuildContext context) {
    final account = _vmAccount.accountState.state.value!;

    return RefreshIndicator(
      onRefresh: () async => await _vmAccount.getAccountCommand(),
      color: AppColors.neonCyan,
      backgroundColor: AppColors.surface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ── SLOT 0: Account header ──
            _staggerSlot(
              0,
              _AccountHeaderCard(
                displayName: account.displayName,
                email: account.email,
                level: account.level,
              ),
            ),

            const SizedBox(height: 28),

            // ── SLOT 1: Section label — Resources ──
            _staggerSlot(1, _buildSectionLabel('RECURSOS')),
            const SizedBox(height: 14),

            // ── SLOT 2: Resource cards ──
            _staggerSlot(
              2,
              Row(
                children: [
                  Expanded(
                    child: _ResourceCard(
                      icon: Icons.diamond_rounded,
                      label: 'Gemas',
                      value: account.gems.toString(),
                      color: AppColors.techBlue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ResourceCard(
                      icon: Icons.bolt_rounded,
                      label: 'Energia',
                      value: account.energy.toString(),
                      color: AppColors.limeScan,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ResourceCard(
                      icon: Icons.monetization_on_rounded,
                      label: 'Gold',
                      value: NumberFormat.currency(
                        locale: 'en_US',
                        symbol: '\$ ',
                        decimalDigits: 0,
                      ).format(account.gold),
                      color: AppColors.plasmaGold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── SLOT 3: Section label — Info ──
            _staggerSlot(3, _buildSectionLabel('INFORMAÇÕES')),
            const SizedBox(height: 14),

            // ── SLOT 4: Info cards ──
            _staggerSlot(
              4,
              Column(
                children: [
                  _InfoCard(
                    icon: Icons.calendar_today_rounded,
                    label: 'Data de Criação',
                    value: DateFormat('dd/MM/yyyy').format(account.createdAt),
                  ),
                  const SizedBox(height: 10),
                  _InfoCard(
                    icon: Icons.update_rounded,
                    label: 'Última Atualização',
                    value: DateFormat('dd/MM/yyyy').format(account.updatedAt),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── SLOT 5: Characters CTA ──
            _staggerSlot(5, _buildShimmerCharacterButton(context, account)),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            gradient: AppColors.accentGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: context.textStyles.labelLarge?.copyWith(
            color: AppColors.coolWhiteMuted,
            letterSpacing: 3,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerCharacterButton(
    BuildContext context,
    dynamic account,
  ) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: AppColors.accentGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonCyan.withOpacity(
                  0.12 + (_shimmerController.value * 0.12),
                ),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        );
      },
      child: FilledButton.icon(
        onPressed: () => context.goNamed(
          AppRouteNames.characters,
          extra: account,
        ),
        icon: const Icon(Icons.people_rounded, size: 20),
        label: const Text('VER MEUS PERSONAGENS'),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.void_,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// EXTRACTED WIDGETS
// =============================================================================

/// Feature card — compact tile for welcome grid
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.outline.withOpacity(0.8),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon with soft glow ring
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.neonCyan.withOpacity(0.08),
              border: Border.all(
                color: AppColors.neonCyan.withOpacity(0.18),
              ),
            ),
            child: Icon(icon, size: 18, color: AppColors.neonCyan),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: context.textStyles.titleSmall?.copyWith(
              color: AppColors.coolWhite,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: context.textStyles.bodySmall?.copyWith(
              color: AppColors.coolWhiteMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Account header with avatar, name, email, and level badge
class _AccountHeaderCard extends StatelessWidget {
  final String displayName;
  final String email;
  final int level;

  const _AccountHeaderCard({
    required this.displayName,
    required this.email,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outline, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonCyan.withOpacity(0.04),
            blurRadius: 24,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with gradient ring
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.accentGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonCyan.withOpacity(0.2),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(2.5),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceVariant,
              ),
              child: Center(
                child: Text(
                  displayName[0].toUpperCase(),
                  style: context.textStyles.headlineMedium?.copyWith(
                    color: AppColors.neonCyan,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Name + email + level
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName.toUpperCase(),
                  style: context.textStyles.titleLarge?.copyWith(
                    color: AppColors.coolWhite,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: AppColors.coolWhiteMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Level badge — inline
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.neonCyan.withOpacity(0.12),
                        AppColors.plasmaViolet.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.neonCyan.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.military_tech_rounded,
                        color: AppColors.neonCyan,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'LV $level',
                        style: context.textStyles.labelSmall?.copyWith(
                          color: AppColors.neonCyan,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Chevron hint
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.coolWhiteFaint,
            size: 24,
          ),
        ],
      ),
    );
  }
}

/// Resource card with glowing icon
class _ResourceCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ResourceCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outline, width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.10),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.18),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: context.textStyles.bodySmall?.copyWith(
              color: AppColors.coolWhiteMuted,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: context.textStyles.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Info card with left accent bar
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.outline, width: 1),
      ),
      child: Row(
        children: [
          // Gradient accent bar
          Container(
            width: 3,
            height: 32,
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),
          Icon(icon, color: AppColors.coolWhiteMuted, size: 20),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.textStyles.bodySmall?.copyWith(
                  color: AppColors.coolWhiteMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: context.textStyles.titleMedium?.copyWith(
                  color: AppColors.coolWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
