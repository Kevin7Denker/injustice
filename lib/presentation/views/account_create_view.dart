import 'package:flutter/material.dart';
import '../../core/di/dependency_injection.dart';
import '../../core/theme/app_theme.dart';
import '../../core/typedefs/types_defs.dart';
import '../../core/validators/email_str_validator.dart';
import '../../core/validators/empty_str_validator.dart';
import '../../domain/models/account_entity.dart';
import '../controllers/account_state_viewmodel.dart';
import '../controllers/account_viewmodel.dart';
import '../functions/ui_functions.dart';
import '../widgets/account_attribute_card.dart';
import '../widgets/app_drawer.dart';
import '../widgets/date_wheel_picker.dart';
import '../widgets/input_text_field.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Página de cadastro de conta
class AccountCreateView extends StatefulWidget {
  const AccountCreateView({super.key});

  @override
  State<AccountCreateView> createState() => _AccountCreateViewState();
}

class _AccountCreateViewState extends State<AccountCreateView> {
  late final AccountViewModel _vmAccount;
  late final void Function() _disposeAccountEffect;
  late final void Function() _disposeSuccessEffect;
  late final void Function() _disposeErrorEffect;

  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  late final AccountFormFieldsController _formFields;

  DateTime _createdAt = DateTime.now();
  int _level = 1;
  double _gold = 0;
  int _gems = 0;
  int _energy = 1;

  @override
  void initState() {
    super.initState();
    _formFields = AccountFormFieldsController();

    _vmAccount = injector.get<AccountViewModel>();
    _vmAccount.accountState.clearMessage();
    _vmAccount.accountState.clearSuccessEvent();

    _disposeAccountEffect = effect(() {
      final account = _vmAccount.accountState.state.value;

      if (account != null) {
        _preencherCampos(account);
      } else {
        _limparCampos();
      }
    });

    _disposeErrorEffect = effect(() {
      final errorMessage = _vmAccount.accountState.message.value;

      if (errorMessage != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          showSnackBar(context, errorMessage, backgroundColor: AppColors.hotMagenta);

          _vmAccount.accountState.clearMessage();
        });
      }
    });

    _disposeSuccessEffect = effect(() {
      final event = _vmAccount.accountState.successEvent.value;

      if (event != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          String message;
          Color color;

          switch (event) {
            case AccountSuccessEvent.created:
              message = 'Conta criada com sucesso!';
              color = AppColors.limeScan;

            case AccountSuccessEvent.updated:
              message = 'Conta atualizada com sucesso!';
              color = AppColors.limeScan;

            case AccountSuccessEvent.deleted:
              message = 'Conta excluída com sucesso!';
              color = AppColors.hotMagentaLight;
          }

          showSnackBar(context, message, backgroundColor: color);

          _vmAccount.accountState.clearSuccessEvent();
        });
      }
    });
  }

  @override
  void dispose() {
    _disposeAccountEffect();
    _disposeSuccessEffect();
    _disposeErrorEffect;

    _scrollController.dispose();

    _formFields.dispose();
    super.dispose();
  }

  void _preencherCampos(Account account) {
    _formFields.email.controller.text = account.email;
    _formFields.name.controller.text = account.name;
    _formFields.displayName.controller.text = account.displayName;

    _createdAt = account.createdAt;
    _level = account.level;
    _gold = account.gold;
    _gems = account.gems;
    _energy = account.energy;

    setState(() {});
  }

  void _limparCampos() {
    _formKey.currentState?.reset();
    _formFields.clear();

    _createdAt = DateTime.now();
    _level = 1;
    _gold = 0;
    _gems = 0;
    _energy = 1;

    setState(() {});
  }

  void _resetFormView() {
    // Remove foco de qualquer TextField
    FocusScope.of(context).unfocus();

    // Rola para o topo
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _focusFirstError() {
    for (final field in _formFields.fields) {
      final state = field.key.currentState;

      if (state != null && !state.isValid) {
        field.focus.requestFocus();

        Scrollable.ensureVisible(
          field.key.currentContext!,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );

        break;
      }
    }
  }

  bool _validateForm() {
    final valid = _formKey.currentState!.validate();

    if (!valid) {
      _focusFirstError();
    }

    return valid;
  }

  Future<void> _salvarConta() async {
    if (!_validateForm()) return;

    Account newAccount = Account(
      email: _formFields.email.controller.text.trim(),
      name: _formFields.name.controller.text.trim(),
      displayName: _formFields.displayName.controller.text.trim(),
      createdAt: _createdAt,
      level: _level,
      gold: _gold,
      gems: _gems,
      energy: _energy,
      updatedAt: _createdAt,
    );

    if (_vmAccount.accountState.hasAccount.value) {
      await _vmAccount.commands.updateAccount(newAccount);
    } else {
      await _vmAccount.commands.saveAccount(newAccount);
    }
    _resetFormView();
  }

  Future<void> _excluirConta() async {
    final confirm = await confirmDialog(
      context,
      title: 'Excluir conta',
      message:
          'Tem certeza que deseja excluir esta conta?\n\n'
          'Esta ação não poderá ser desfeita.',
      confirmText: 'EXCLUIR',
    );

    if (!confirm) return;

    await _vmAccount.commands.deleteAccount();
    _formKey.currentState?.reset();
    _formFields.clear();
    _resetFormView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Watch(
          (_) => Text(
            _vmAccount.accountState.labelEditMode.value.toUpperCase(),
          ),
        ),
      ),
      drawer: AppDrawer(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: AppSpacing.paddingLg,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header icon with accent gradient glow ──
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.accentGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonCyan.withOpacity(0.25),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_add_rounded,
                      size: 32,
                      color: AppColors.void_,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                Text(
                  'Preencha os dados abaixo para criar sua conta',
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: AppColors.coolWhiteMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Form Fields ──
                InputTextField(
                  fieldKey: _formFields.email.key,
                  controller: _formFields.email.controller,
                  focusNode: _formFields.email.focus,
                  label: 'Email',
                  hint: 'Digite seu e-mail',
                  prefixIcon: Icons.email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => validateField(value, [
                    EmptyStrValidator(),
                    EmailStrValidator(),
                  ]),
                ),
                const SizedBox(height: AppSpacing.md),

                InputTextField(
                  fieldKey: _formFields.name.key,
                  controller: _formFields.name.controller,
                  focusNode: _formFields.name.focus,
                  prefixIcon: Icons.account_circle_rounded,
                  label: 'Nome',
                  hint: 'Digite seu nome',
                  validator: (value) =>
                      validateField(value, [EmptyStrValidator()]),
                ),
                const SizedBox(height: AppSpacing.md),

                InputTextField(
                  label: 'Apelido',
                  fieldKey: _formFields.displayName.key,
                  controller: _formFields.displayName.controller,
                  focusNode: _formFields.displayName.focus,
                  prefixIcon: Icons.verified_user_rounded,
                  hint: 'Digite seu apelido',
                  validator: (value) =>
                      validateField(value, [EmptyStrValidator()]),
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Date Picker ──
                DateWheelPicker(
                  label: 'Data de Criação',
                  selectedDate: _createdAt,
                  onDateSelected: (date) => setState(() => _createdAt = date),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Section Title ──
                Text(
                  'ATRIBUTOS',
                  style: context.textStyles.headlineSmall?.copyWith(
                    color: AppColors.coolWhite,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Attribute Cards ──
                AccountAttributeCard(
                  icon: Icons.star_rounded,
                  iconColor: AppColors.neonCyan,
                  label: 'Nível',
                  hint: '[1, 80]',
                  minValue: 1,
                  maxValue: 80,
                  value: _level,
                  onChanged: (value) => setState(() => _level = value),
                ),
                const SizedBox(height: AppSpacing.xs),

                AccountAttributeCard(
                  icon: Icons.monetization_on_rounded,
                  iconColor: AppColors.plasmaGold,
                  label: 'Ouro',
                  hint: 'Min: 0',
                  minValue: 0,
                  maxValue: 999999,
                  value: _gold.toInt(),
                  onChanged: (value) =>
                      setState(() => _gold = value.toDouble()),
                ),
                const SizedBox(height: AppSpacing.xs),

                AccountAttributeCard(
                  icon: Icons.diamond_rounded,
                  iconColor: AppColors.techBlue,
                  label: 'Gemas',
                  hint: 'Min: 0',
                  minValue: 0,
                  maxValue: 999999,
                  value: _gems,
                  onChanged: (value) => setState(() => _gems = value),
                ),
                const SizedBox(height: AppSpacing.xs),

                AccountAttributeCard(
                  icon: Icons.bolt_rounded,
                  iconColor: AppColors.limeScan,
                  label: 'Energia',
                  hint: 'Min: 1',
                  minValue: 1,
                  maxValue: 999999,
                  value: _energy,
                  onChanged: (value) => setState(() => _energy = value),
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Action Buttons ──
                Row(
                  children: [
                    // SAVE / EDIT
                    Expanded(
                      child: Watch((context) {
                        final isRunning =
                            _vmAccount
                                .commands
                                .saveAccountCommand
                                .isExecuting
                                .value ||
                            _vmAccount
                                .commands
                                .updateAccountCommand
                                .isExecuting
                                .value;

                        return Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.accentGradient,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.neonCyan.withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: isRunning ? null : _salvarConta,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: AppColors.void_,
                              disabledBackgroundColor: Colors.transparent,
                              disabledForegroundColor:
                                  AppColors.void_.withOpacity(0.5),
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                              shadowColor: Colors.transparent,
                            ),
                            child: isRunning
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.void_,
                                    ),
                                  )
                                : Text(
                                    _vmAccount
                                        .accountState.labelEditMode.value
                                        .toUpperCase(),
                                    style:
                                        context.textStyles.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.void_,
                                    ),
                                  ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(width: AppSpacing.md),

                    // DELETE
                    Expanded(
                      child: Watch((_) {
                        final canDelete =
                            _vmAccount.accountState.canDelete.value;

                        final isDeleting = _vmAccount
                            .commands
                            .deleteAccountCommand
                            .isExecuting
                            .value;

                        final isSaving = _vmAccount
                            .commands
                            .saveAccountCommand
                            .isExecuting
                            .value;

                        final isUpdating = _vmAccount
                            .commands
                            .updateAccountCommand
                            .isExecuting
                            .value;

                        final isBusy = isDeleting || isSaving || isUpdating;

                        return OutlinedButton(
                          onPressed: canDelete && !isBusy
                              ? _excluirConta
                              : null,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.hotMagenta,
                            side: BorderSide(
                              color: canDelete && !isBusy
                                  ? AppColors.hotMagenta.withOpacity(0.5)
                                  : AppColors.outline,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            disabledForegroundColor: AppColors.coolWhiteFaint,
                          ),
                          child: isDeleting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.hotMagenta,
                                  ),
                                )
                              : Text(
                                  'EXCLUIR',
                                  style:
                                      context.textStyles.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        );
                      }),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AccountFormFieldsController {
  final FormFieldControl email = _createField();
  final FormFieldControl name = _createField();
  final FormFieldControl displayName = _createField();

  List<FormFieldControl> get fields => [email, name, displayName];

  static FormFieldControl _createField() {
    return (
      key: GlobalKey<FormFieldState>(),
      focus: FocusNode(),
      controller: TextEditingController(),
    );
  }

  void clear() {
    for (final field in fields) {
      field.controller.clear();
    }
  }

  void dispose() {
    for (final field in fields) {
      field.focus.dispose();
      field.controller.dispose();
    }
  }
}
