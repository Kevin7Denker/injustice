import 'package:flutter/material.dart';
import '../failure/failure.dart';
import '../../domain/models/account_entity.dart';
import '../../domain/models/character_entity.dart';

import '../patterns/result.dart';

typedef VoidResult = Result<void, Failure>;
typedef AccountResult = Result<Account, Failure>;
typedef CharacterResult = Result<Character, Failure>;
typedef ListCharacterResult = Result<List<Character>, Failure>;

typedef AccountParams = ({Account account});

typedef NoParams = ();
typedef AccountNameParams = ({String accountName});

typedef CharacterIdParams = ({String id});
typedef CharacterParams = ({Character character});

typedef FormFieldControl = ({
  GlobalKey<FormFieldState> key,
  FocusNode focus,
  TextEditingController controller,
});
