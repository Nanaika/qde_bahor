import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../auth/presentation/bloc/auth_state.dart';
import '../confirm_account/profile_bloc.dart';
import '../confirm_account/profile_event.dart';
import '../confirm_account/profile_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _companyController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedState) {
      final user = authState.user;
      _nameController = TextEditingController(text: user.name);
      _companyController = TextEditingController(text: user.company);
      _phoneController = TextEditingController(text: user.number);

      // Запрашиваем проверку: есть ли юзер в базе на модерации
      context.read<ProfileBloc>().add(CheckModerationStatusEvent(user.id));
    } else {
      _nameController = TextEditingController();
      _companyController = TextEditingController();
      _phoneController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final authState = context.read<AuthBloc>().state;

      if (authState is AuthAuthenticatedState) {
        context.read<ProfileBloc>().add(
              SubmitProfileForVerificationEvent(
                id: authState.user.id,
                fullName: _nameController.text.trim(),
                companyName: _companyController.text.trim(),
                phoneNumber: _phoneController.text.trim(),
              ),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthBloc>().state;

    // Флаг проверки профиля из основного объекта авторизации
    final bool isUserModerated = authState is AuthAuthenticatedState && authState.user.isModerated;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileSubmitSuccessState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              // Перепроверяем модерацию после успешной отправки
              if (authState is AuthAuthenticatedState) {
                context.read<ProfileBloc>().add(CheckModerationStatusEvent(authState.user.id));
              }
            }
          },
          builder: (context, state) {
            final isLoading = state is ProfileSubmittingState;

            // Если есть в коллекции модерации -> isPending = true
            final bool isPending = state is ProfileModerationStatusState && state.isPending;

            // Блокируем форму, если юзер НА МОДЕРАЦИИ (есть в базе модерации) ИЛИ УЖЕ СМОДЕРИРОВАН
            final bool isInputBlocked = isPending || isUserModerated || isLoading;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Card(
                    elevation: 4,
                    shadowColor: theme.shadowColor.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
                    ),
                    color: theme.cardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. Статусные баннеры
                            if (isUserModerated)
                              _buildStatusBanner(
                                icon: Icons.verified_user_rounded,
                                color: Colors.green,
                                title: 'Account Verified',
                                subtitle: 'Your profile has been verified.',
                              )
                            else if (isPending)
                              _buildStatusBanner(
                                icon: Icons.hourglass_top_rounded,
                                color: Colors.orange,
                                title: 'Under Review',
                                subtitle: 'Your profile is currently under moderation.',
                              ),

                            Text(
                              'Personal Profile',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isInputBlocked && !isLoading
                                  ? 'Your profile information is locked.'
                                  : 'Enter your details below to submit them for verification.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.hintColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 28),

                            // Name
                            TextFormField(
                              controller: _nameController,
                              enabled: !isInputBlocked,
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.words,
                              style: theme.textTheme.bodyMedium,
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                labelStyle: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                                prefixIcon: const Icon(Icons.person_outline_rounded),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),

                            // Company
                            TextFormField(
                              controller: _companyController,
                              enabled: !isInputBlocked,
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.words,
                              style: theme.textTheme.bodyMedium,
                              decoration: InputDecoration(
                                labelText: 'Company Name',
                                labelStyle: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                                prefixIcon: const Icon(Icons.business_rounded),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter company name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),

                            // Phone Number
                            TextFormField(
                              controller: _phoneController,
                              enabled: !isInputBlocked,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.done,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s\-()]')),
                              ],
                              style: theme.textTheme.bodyMedium,
                              decoration: InputDecoration(
                                labelStyle: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                                labelText: 'Phone Number',
                                hintText: '+998 90 123 45 67',
                                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                                prefixIcon: const Icon(Icons.phone_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter phone number';
                                }
                                if (value.trim().length < 7) {
                                  return 'Please enter a valid phone number';
                                }
                                return null;
                              },
                              onFieldSubmitted: isInputBlocked ? null : (_) => _submitForm(),
                            ),
                            const SizedBox(height: 28),

                            // Submit Button
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: isInputBlocked ? null : _submitForm,
                                child: isLoading
                                    ? SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: theme.colorScheme.onPrimary,
                                        ),
                                      )
                                    : Text(
                                        isUserModerated
                                            ? 'Verified'
                                            : isPending
                                                ? 'Pending Verification'
                                                : 'Submit for Verification',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          color: isInputBlocked
                                              ? theme.colorScheme.onSurface
                                              : theme.colorScheme.onPrimary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusBanner({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
