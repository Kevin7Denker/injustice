import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/app_drawer.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SOBRE O JOGO')),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),

            Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.accentGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonCyan.withOpacity(0.35),
                      blurRadius: 28,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.radar_rounded,
                  size: 42,
                  color: AppColors.void_,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            Center(
              child: Text(
                'INJUSTICE',
                style: context.textStyles.headlineLarge?.copyWith(
                  color: AppColors.coolWhite,
                  letterSpacing: 3,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            Center(
              child: Container(
                width: 80,
                height: 2,
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            InfoSection(
              titulo: 'DESCRIÇÃO',
              conteudo:
                  'Um jogo épico de RPG onde você controla heróis poderosos, '
                  'explora mundos fantásticos e enfrenta desafios emocionantes. '
                  'Personalize seus personagens, desenvolva habilidades únicas e '
                  'embarque em uma jornada inesquecível.',
            ),
            const SizedBox(height: AppSpacing.lg),
            InfoSection(
              titulo: 'RECURSOS',
              conteudo:
                  '• Sistema de combate estratégico\n'
                  '• Mais de 50 personagens únicos\n'
                  '• Mundos vastos para explorar\n'
                  '• Sistema de progressão profundo\n'
                  '• Modo multiplayer cooperativo\n'
                  '• Eventos semanais exclusivos',
            ),
            const SizedBox(height: AppSpacing.lg),
            InfoSection(titulo: 'VERSÃO', conteudo: '1.0.0'),
            const SizedBox(height: AppSpacing.lg),
            InfoSection(
              titulo: 'DESENVOLVEDORES',
              conteudo: 'Kevin Denker & Prof. Roberto',
            ),
            const SizedBox(height: AppSpacing.xl),

            Center(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Função em desenvolvimento'),
                      backgroundColor: AppColors.surfaceElevated,
                    ),
                  );
                },
                icon: Icon(
                  Icons.help_outline_rounded,
                  color: AppColors.neonCyan,
                  size: 20,
                ),
                label: Text(
                  'Ajuda e Suporte',
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: AppColors.neonCyan,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  side: BorderSide(color: AppColors.neonCyan.withOpacity(0.35)),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class InfoSection extends StatelessWidget {
  final String titulo;
  final String conteudo;

  const InfoSection({super.key, required this.titulo, required this.conteudo});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: context.textStyles.headlineSmall?.copyWith(
            color: AppColors.coolWhite,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: AppSpacing.paddingMd,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.outline, width: 1),
          ),
          child: Text(
            conteudo,
            style: context.textStyles.bodyMedium?.copyWith(
              color: AppColors.coolWhiteMuted,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}
