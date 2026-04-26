import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Widget para exibir e editar rating de estrelas (1-14)
/// 
/// Sistema de cores:
/// - Até 7 estrelas: plasma gold com glow
/// - De 8 a 14 estrelas: primeiras são violeta (neon), últimas são gold
/// 
/// Modo interativo:
/// - Tap simples na estrela N: define N estrelas (gold)
/// - Duplo tap na estrela N: define N + 7 estrelas (N violetas + N gold)
class StarRating extends StatelessWidget {
  final int stars;
  final double size;
  final bool interactive;
  final ValueChanged<int>? onStarsChanged;

  const StarRating({
    super.key,
    required this.stars,
    this.size = 24,
    this.interactive = false,
    this.onStarsChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (interactive) {
      return _InteractiveStarRating(
        stars: stars,
        size: size,
        onStarsChanged: onStarsChanged!,
      );
    } else {
      return _DisplayStarRating(
        stars: stars,
        size: size,
      );
    }
  }
}

/// Widget para exibir estrelas (não interativo) with glow effects
class _DisplayStarRating extends StatelessWidget {
  final int stars;
  final double size;

  const _DisplayStarRating({
    required this.stars,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final int violetStars;
    final int goldStars;
    final int emptyStars;
    
    if (stars <= 7) {
      violetStars = 0;
      goldStars = stars;
      emptyStars = 7 - stars;
    } else {
      violetStars = (stars - 7).clamp(0, 7);
      goldStars = (7 - violetStars).clamp(0, 7);
      emptyStars = 0;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Violet stars with plasma glow
        ...List.generate(
          violetStars,
          (_) => _GlowStar(
            icon: Icons.star_rounded,
            size: size,
            color: AppColors.plasmaViolet,
            glowColor: AppColors.plasmaViolet,
          ),
        ),
        // Gold stars with plasma gold glow
        ...List.generate(
          goldStars,
          (_) => _GlowStar(
            icon: Icons.star_rounded,
            size: size,
            color: AppColors.plasmaGold,
            glowColor: AppColors.plasmaGold,
          ),
        ),
        // Empty stars
        ...List.generate(
          emptyStars,
          (_) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Icon(
              Icons.star_border_rounded,
              size: size,
              color: AppColors.coolWhiteFaint,
            ),
          ),
        ),
      ],
    );
  }
}

/// A single star with subtle glow shadow
class _GlowStar extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final Color glowColor;

  const _GlowStar({
    required this.icon,
    required this.size,
    required this.color,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: glowColor.withOpacity(0.35),
              blurRadius: size * 0.4,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Icon(icon, size: size, color: color),
      ),
    );
  }
}

/// Widget para editar estrelas (interativo)
class _InteractiveStarRating extends StatefulWidget {
  final int stars;
  final double size;
  final ValueChanged<int> onStarsChanged;

  const _InteractiveStarRating({
    required this.stars,
    required this.size,
    required this.onStarsChanged,
  });

  @override
  State<_InteractiveStarRating> createState() => _InteractiveStarRatingState();
}

class _InteractiveStarRatingState extends State<_InteractiveStarRating> {
  Timer? _tapTimer;
  int? _pendingTapIndex;

  @override
  void dispose() {
    _tapTimer?.cancel();
    super.dispose();
  }

  void _handleStarTap(int index) {
    final position = index + 1; // 1-based index

    // Se já existe um tap pendente na mesma estrela, é um duplo tap
    if (_tapTimer != null && _tapTimer!.isActive && _pendingTapIndex == index) {
      // Cancela o tap simples pendente
      _tapTimer!.cancel();
      _tapTimer = null;
      _pendingTapIndex = null;

      // Duplo tap: toggle entre gold e violet
      final violetStars = widget.stars > 7 ? (widget.stars - 7).clamp(0, 7) : 0;
      final isVioletStar = index < violetStars;
      
      if (isVioletStar) {
        widget.onStarsChanged(position);
      } else {
        widget.onStarsChanged((position + 7).clamp(1, 14));
      }
      return;
    }

    // Tap simples: agenda com delay para detectar possível duplo tap
    _tapTimer?.cancel();
    _pendingTapIndex = index;
    
    _tapTimer = Timer(const Duration(milliseconds: 250), () {
      _tapTimer = null;
      _pendingTapIndex = null;
      
      final violetStars = widget.stars > 7 ? (widget.stars - 7).clamp(0, 7) : 0;
      final isVioletStar = index < violetStars;
      final hasVioletStars = widget.stars > 7;
      
      if (isVioletStar) return;
      if (hasVioletStars && index >= violetStars) return;
      
      if (widget.stars == position) {
        widget.onStarsChanged(0);
      } else {
        widget.onStarsChanged(position);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final int violetStars;
    final int goldStars;
    
    if (widget.stars <= 7) {
      violetStars = 0;
      goldStars = widget.stars;
    } else {
      violetStars = (widget.stars - 7).clamp(0, 7);
      goldStars = (7 - violetStars).clamp(0, 7);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(7, (index) {
        Color starColor;
        Color glowColor;
        IconData starIcon;

        if (index < violetStars) {
          starColor = AppColors.plasmaViolet;
          glowColor = AppColors.plasmaViolet;
          starIcon = Icons.star_rounded;
        } else if (index < violetStars + goldStars) {
          starColor = AppColors.plasmaGold;
          glowColor = AppColors.plasmaGold;
          starIcon = Icons.star_rounded;
        } else {
          starColor = AppColors.coolWhiteFaint;
          glowColor = Colors.transparent;
          starIcon = Icons.star_border_rounded;
        }

        return GestureDetector(
          onTap: () => _handleStarTap(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Container(
              decoration: glowColor != Colors.transparent
                  ? BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: glowColor.withOpacity(0.35),
                          blurRadius: widget.size * 0.4,
                          spreadRadius: 0,
                        ),
                      ],
                    )
                  : null,
              child: Icon(
                starIcon,
                size: widget.size,
                color: starColor,
              ),
            ),
          ),
        );
      }),
    );
  }
}
