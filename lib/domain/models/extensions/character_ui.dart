// character_class_ui.dart
import 'package:flutter/material.dart';
import 'package:injustice_app/domain/models/character_entity.dart';

extension ClassUI on CharacterClass {
  Color get color {
    switch (this) {
      case CharacterClass.poderoso:
        return const Color(0xFFFF6B35); // molten orange
      case CharacterClass.metaHumano:
        return const Color(0xFFFFD740); // plasma amber
      case CharacterClass.agilidade:
        return const Color(0xFF78FF56); // lime scan
      case CharacterClass.arcano:
        return const Color(0xFFB45CFF); // plasma violet
      case CharacterClass.tecnologico:
        return const Color(0xFF00F0FF); // neon cyan
    }
  }

  IconData get icon {
    switch (this) {
      case CharacterClass.poderoso:
        return Icons.fitness_center;
      case CharacterClass.metaHumano:
        return Icons.flash_on;
      case CharacterClass.agilidade:
        return Icons.speed;
      case CharacterClass.arcano:
        return Icons.auto_fix_high;
      case CharacterClass.tecnologico:
        return Icons.settings;
    }
  }
}

extension RarityUI on CharacterRarity {
  Color get color {
    switch (this) {
      case CharacterRarity.lendario:
        return const Color(0xFFB45CFF); // plasma violet
      case CharacterRarity.ouro:
        return const Color(0xFFFFD740); // plasma gold
      case CharacterRarity.prata:
        return const Color(0xFF8B95A5); // titanium
    }
  }
}
