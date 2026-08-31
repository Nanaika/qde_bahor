import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/data/models/user_model.dart';
import '../moderate_users/users_bloc.dart';
import '../moderate_users/users_event.dart';
import '../moderate_users/users_state.dart';

class ModerateUsersPage extends StatelessWidget {
  const ModerateUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UsersBloc()..add(const FetchAllUsersEvent()),
      child: const _UsersView(),
    );
  }
}

class _UsersView extends StatefulWidget {
  const _UsersView();

  @override
  State<_UsersView> createState() => _UsersViewState();
}

class _UsersViewState extends State<_UsersView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    context.read<UsersBloc>().add(const FetchAllUsersEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<UsersBloc, UsersState>(
      listenWhen: (previous, current) {
        // Слушаем только если изменился флаг isUpdating
        if (previous is UsersLoadedState && current is UsersLoadedState) {
          return previous.isUpdating != current.isUpdating;
        }
        return false;
      },
      listener: (BuildContext context, state) {
        if (state is UsersLoadedState) {
          if (state.isUpdating) {
            // Показываем блокирующий полупрозрачный диалог
            showDialog(
              context: context,
              barrierDismissible: false, // Запрещаем закрытие кликом мимо диалога
              barrierColor: Colors.black.withValues(alpha: 0.4), // Полупрозрачный фон
              builder: (dialogContext) {
                return const PopScope(
                  canPop: false, // Запрещаем закрытие кнопкой «Назад»
                  child: Dialog(
                    backgroundColor: Colors.transparent, // Делаем сам контейнер диалога прозрачным
                    elevation: 0,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              },
            );
          } else {
            // Запрос завершился — закрываем диалог загрузки, если он открыт
            if (Navigator.of(context, rootNavigator: true).canPop()) {
              Navigator.of(context, rootNavigator: true).pop();
            }
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Users'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _onRefresh,
              tooltip: 'Refresh Users',
            ),
          ],
        ),
        body: Column(
          children: [
            // Поле поиска
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by any field...',
                  hintStyle: TextStyle(
                    color: theme.hintColor.withValues(alpha: 0.5),
                  ),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase().trim();
                  });
                },
              ),
            ),

            // Список
            Expanded(
              child: BlocBuilder<UsersBloc, UsersState>(
                builder: (context, state) {
                  if (state is UsersLoadingState) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is UsersErrorState) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(state.message),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _onRefresh,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is UsersLoadedState) {
                    final filteredUsers = state.users.where((user) {
                      if (_searchQuery.isEmpty) return true;

                      final name = user.name.toLowerCase();
                      final userName = user.userName.toLowerCase();
                      final company = user.company.toLowerCase();
                      final number = user.number.toLowerCase();
                      final id = user.id.toLowerCase();
                      final role = user.userType.name.toLowerCase();

                      return name.contains(_searchQuery) ||
                          userName.contains(_searchQuery) ||
                          company.contains(_searchQuery) ||
                          number.contains(_searchQuery) ||
                          id.contains(_searchQuery) ||
                          role.contains(_searchQuery);
                    }).toList();

                    if (filteredUsers.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: ListView(
                          children: const [
                            SizedBox(height: 100),
                            Center(child: Text('No users found')),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: ListView.separated(
                        itemCount: filteredUsers.length,
                        separatorBuilder: (_, __) => const Divider(height: 0.1),
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Верхний ряд: Аватар, имя, роль/статус, меню
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // Чип РОЛИ
                                    _buildBadge(
                                      label: user.userType.name.toUpperCase(),
                                      color: user.userType == UserType.accounting ? Colors.purple : Colors.blue,
                                    ),
                                    const SizedBox(width: 6),
                                    // Чип СТАТУСА
                                    _buildBadge(
                                      label: user.isModerated ? 'VERIFIED' : 'PENDING',
                                      color: user.isModerated ? Colors.green : Colors.orange,
                                      icon: user.isModerated ? Icons.verified : Icons.hourglass_top,
                                    ),
                                    const SizedBox(width: 4),

                                    // Меню действия (Модерация / Роль)
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert),
                                      onSelected: (value) {
                                        if (value == 'toggle_moderation') {
                                          context.read<UsersBloc>().add(
                                                UpdateUserModerationEvent(
                                                  userId: user.id,
                                                  isModerated: !user.isModerated,
                                                ),
                                              );
                                        } else if (value == 'change_role') {
                                          _showRoleDialog(context, user);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 'toggle_moderation',
                                          child: Row(
                                            children: [
                                              Icon(
                                                user.isModerated ? Icons.cancel_outlined : Icons.check_circle_outline,
                                                color: user.isModerated ? Colors.red : Colors.green,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(user.isModerated ? 'Revoke Moderation' : 'Approve Moderation'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'change_role',
                                          child: Row(
                                            children: [
                                              Icon(Icons.manage_accounts_outlined, size: 20),
                                              SizedBox(width: 8),
                                              Text('Change Role'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                      child: Text(
                                        user.name.isNotEmpty
                                            ? user.name[0].toUpperCase()
                                            : (user.userName.isNotEmpty ? user.userName[0].toUpperCase() : 'U'),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Имя и юзернейм
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            user.name.isNotEmpty ? user.name : user.userName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            '@${user.userName}',
                                            style: TextStyle(
                                              color: Theme.of(context).hintColor,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Нижний блок: Данные юзера (Компания, Телефон, ID)
                                Wrap(
                                  spacing: 16.0,
                                  runSpacing: 6.0,
                                  children: [
                                    _buildInfoRow(Icons.business_rounded, 'Company', user.company),
                                    _buildInfoRow(Icons.phone_outlined, 'Phone', user.number),
                                    _buildInfoRow(Icons.fingerprint, 'ID', user.id),
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge({
    required String label,
    required Color color,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Иконка фиксируется по верхнему краю
      children: [
        Padding(
          padding: const EdgeInsets.only(
              top: 2.0), // Небольшой микро-отступ для идеального выравнивания по высоте первой строки
          child: Icon(icon, size: 14, color: Colors.grey),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            '$label: ${value.isEmpty ? '-' : value}',
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }

  void _showRoleDialog(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: const Text('Select User Role'),
          children: UserType.values.map((type) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<UsersBloc>().add(
                      UpdateUserRoleEvent(
                        userId: user.id,
                        userType: type,
                      ),
                    );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Icon(
                      user.userType == type ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(type.name.toUpperCase()),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
