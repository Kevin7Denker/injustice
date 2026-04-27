import 'package:auto_injector/auto_injector.dart';

import '../../data/repositories/account_repository_impl.dart';
import '../../data/repositories/account_repository_interface.dart';
import '../../data/repositories/character_repository_impl.dart';
import '../../data/repositories/character_repository_interface.dart';
import '../../data/services/account_postgres_impl.dart';
import '../../data/services/account_local_storage_interface.dart';
import '../../data/services/character_local_storage_interface.dart';
import '../../data/services/character_postgres_impl.dart';
import '../../data/services/oauth2_service.dart';
import '../../data/services/postgres_connection_service.dart';
import '../../domain/facades/account_facade_usecases_impl.dart';
import '../../domain/facades/account_facade_usecases_interface.dart';
import '../../domain/facades/character_facade_usecases_impl.dart';
import '../../domain/facades/character_facade_usecases_interface.dart';
import '../../domain/usecases/account_usecases_impl.dart';
import '../../domain/usecases/account_usecases_interfaces.dart';
import '../../domain/usecases/character_usecases_impl.dart';
import '../../domain/usecases/character_usecases_interfaces.dart';
import '../../presentation/controllers/auth_viewmodel.dart';
import '../../presentation/controllers/account_viewmodel.dart';
import '../../presentation/controllers/characters_view_model.dart';
import '../theme/theme_controller.dart';

final injector = AutoInjector();
void setupDependencyInjection() {
  // Regristração de dependências do Core
  injector.addSingleton<ThemeController>(ThemeController.new);
  injector.addSingleton<PostgresConnectionService>(
    PostgresConnectionService.new,
  );
  injector.addSingleton<OAuth2Service>(OAuth2Service.new);
  injector.addSingleton<AuthViewModel>(AuthViewModel.new);

  // Regristração de dependências para Account
  // Repositories e servicos
  injector.addSingleton<IAccountLocalStorage>(AccountPostgresService.new);
  injector.addSingleton<IAccountRepository>(AccountRepositoryImpl.new);
  // Use Cases e Facades
  injector.addSingleton<IAccountFacadeUseCases>(AccountFacadeUsecasesImpl.new);
  injector.addSingleton<IGetAccountUseCase>(GetAccountUseCaseImpl.new);
  injector.addSingleton<ISaveAccountUseCase>(SaveAccountUseCaseImpl.new);
  injector.addSingleton<IDeleteAccountUseCase>(DeleteAccountUseCaseImpl.new);
  injector.addSingleton<IUpdateAccountUseCase>(UpdateAccountUseCaseImpl.new);

  // Regristração de dependências para Character
  // Repositories e serviços
  injector.addSingleton<ICharacterLocalStorage>(CharacterPostgresService.new);
  injector.addSingleton<ICharacterRepository>(CharacterRepositoryImpl.new);
  // Use Cases e Facades
  injector.addSingleton<ICharacterFacadeUseCases>(
    CharacterFacadeUseCasesImpl.new,
  );
  injector.addSingleton<IGetAllCharactersUseCase>(
    GetAllCharactersUseCaseImpl.new,
  );
  injector.addSingleton<IGetCharacterByIdUseCase>(
    GetCharacterByIdUseCaseImpl.new,
  );
  injector.addSingleton<ISaveCharacterUseCase>(SaveCharacterUseCaseImpl.new);
  injector.addSingleton<IUpdateCharacterUseCase>(
    UpdateCharacterUseCaseImpl.new,
  );
  injector.addSingleton<IDeleteCharacterUseCase>(
    DeleteCharacterUseCaseImpl.new,
  );

  // viewmodes
  // Account viewmodes
  injector.addSingleton<AccountViewModel>(AccountViewModel.new);
  // Character List viewmodel
  injector.addSingleton<CharactersViewModel>(CharactersViewModel.new);

  injector.commit();
}
