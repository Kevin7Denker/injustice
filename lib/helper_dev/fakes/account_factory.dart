import '../../domain/models/account_entity.dart';
import 'fakes_factory.dart';

class AccountFactory {
  static Account single() {
    return FakeFactory.account();
  }

  static List<Account> list([int count = 5]) {
    var list = List.generate(count, (index) => single());

    return list;
  }
}
