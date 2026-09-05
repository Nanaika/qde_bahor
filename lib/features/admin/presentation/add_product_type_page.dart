import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qde_eco_bahor/features/admin/models/product_type_model.dart';

import '../manage_products/manage_products_bloc.dart';
import '../manage_products/manage_products_event.dart';
import '../manage_products/manage_products_state.dart';
import '../manage_products/product_types_bloc.dart';

class AddProductTypePage extends StatefulWidget {
  const AddProductTypePage({super.key});

  @override
  State<AddProductTypePage> createState() => _AddProductTypePageState();
}

class _AddProductTypePageState extends State<AddProductTypePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProductTypesBloc>().add(GetProductsTypesEvent());
  }

  void _showTypeBottomSheet(BuildContext context, {ProductTypeModel? typeToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Чтобы шторка поднималась при открытии клавиатуры
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return EditProductTypeSheet(
          initialNameMap: typeToEdit?.name, // Передаем существующие названия, если редактируем
          onSubmit: (nameMap) {
            if (typeToEdit == null) {
              // СОЗДАНИЕ
              final newType = ProductTypeModel(id: '', name: nameMap);
              context.read<ProductTypesBloc>().add(AddProductsTypeEvent(newType));
            } else {
              // РЕДАКТИРОВАНИЕ (сохраняем оригинальный id)
              final updatedType = ProductTypeModel(id: typeToEdit.id, name: nameMap);
              context.read<ProductTypesBloc>().add(EditProductsTypeEvent(updatedType));
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage types'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showTypeBottomSheet(context);
            },
          ),
        ],
      ),
      body: BlocBuilder<ProductTypesBloc, ManageProductsState>(
        builder: (context, state) {
          // 1. Состояние загрузки
          if (state is ManageProductsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // 2. Состояние ошибки
          if (state is ManageProductsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${state.failure.message}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Повторный запрос данных
                      context.read<ManageProductsBloc>().add(GetProductsTypesEvent());
                    },
                    child: Text('Retry'.tr()),
                  ),
                ],
              ),
            );
          }

          // 3. Состояние успеха
          if (state is ManageProductsTypeSuccess) {
            final types = state.types;

            // Если список пуст
            if (types.isEmpty) {
              return Center(
                child: Text('No types'.tr()),
              );
            }

            // Список товаров
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: types.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final type = types[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Названия (переносятся на новую строку при нехватке места)
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: type.name.entries.map((entry) {
                            return Chip(
                              visualDensity: VisualDensity.compact,
                              label: Text('${entry.key.toUpperCase()}: ${entry.value}'),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 8),

                        // 2. Иконки действий отдельной строкой снизу справа
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showTypeBottomSheet(context, typeToEdit: type),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteDialog(context, type.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class EditProductTypeSheet extends StatefulWidget {
  final Map<String, String>? initialNameMap; // Передаем сюда type.name при редактировании
  final Function(Map<String, String> nameMap) onSubmit;

  const EditProductTypeSheet({
    super.key,
    this.initialNameMap, // null -> режим создания, не null -> режим редактирования
    required this.onSubmit,
  });

  @override
  State<EditProductTypeSheet> createState() => _EditProductTypeSheetState();
}

class _EditProductTypeSheetState extends State<EditProductTypeSheet> {
  late final Map<String, TextEditingController> _controllers;

  bool get isEdit => widget.initialNameMap != null;

  @override
  void initState() {
    super.initState();
    _controllers = {
      'ru': TextEditingController(text: widget.initialNameMap?['ru'] ?? ''),
      'uz': TextEditingController(text: widget.initialNameMap?['uz'] ?? ''),
    };
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() {
    final Map<String, String> nameMap = {};

    _controllers.forEach((lang, controller) {
      final text = controller.text.trim();
      if (text.isNotEmpty) {
        nameMap[lang] = text;
      }
    });

    if (nameMap.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Enter name at least in one'.tr()),
        ),
      );
      return;
    }

    widget.onSubmit(nameMap);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: bottomInset + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEdit ? 'Edit product type'.tr() : 'Add product type'.tr(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controllers['ru'],
              decoration: InputDecoration(
                labelText: 'Name (RU)'.tr(),
                hintText: 'Example: Drinks'.tr(),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controllers['uz'],
              decoration: InputDecoration(
                labelText: 'Name (UZ)'.tr(),
                hintText: 'Example: Drinks'.tr(),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                isEdit ? 'Save'.tr() : 'Add'.tr(),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showDeleteDialog(BuildContext context, String typeId) {
  showCupertinoDialog(
    context: context,
    builder: (ctx) => CupertinoAlertDialog(
      title: Text('Delete product type?'.tr()),
      content: Text('It is cannot be undone'.tr()),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Cancel'.tr()),
        ),
        CupertinoDialogAction(
          isDestructiveAction: true, // Делает текст красным
          onPressed: () {
            Navigator.pop(ctx);

            // Вызов события BLoC или функции удаления:
            context.read<ProductTypesBloc>().add(DeleteProductsTypeEvent(typeId));
          },
          child: Text('Delete'.tr()),
        ),
      ],
    ),
  );
}
