import '../../domain/models/character_entity.dart';
import 'fakes_factory.dart';

class CharacterFactory {
  static Character single() {
    return FakeFactory.character();
  }

  static List<Character> list([int count = 5]) {
    var list = List.generate(count, (index) => single());

    return list;
  }
}
