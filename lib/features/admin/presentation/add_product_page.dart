import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qde_eco_bahor/core/theme/theme_dimensions.dart';
import 'package:qde_eco_bahor/features/admin/add_product/add_product_bloc.dart';
import 'package:qde_eco_bahor/features/admin/add_product/add_product_state.dart';
import 'package:qde_eco_bahor/features/admin/models/product_model.dart';

import '../add_product/add_product_event.dart';
import '../manage_products/manage_products_state.dart';
import '../manage_products/product_types_bloc.dart';
import '../models/product_type_model.dart';
import '../models/product_variant.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key, this.product});

  final ProductModel? product;

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  ProductTypeModel? selectedProductType;
  Uint8List? selectedImageBytes;
  List<ProductVariant> variants = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;

    // Заполняем контроллеры и состояние данными редактируемого товара
    nameController.text = p?.name ?? '';
    descController.text = p?.description ?? '';
    selectedProductType = p?.productType;
    variants = p?.variants != null ? List.from(p!.variants) : [];
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final List<PlatformFile> files = await FilePicker.pickFiles(
        type: FileType.image,
      );

      if (files.isNotEmpty) {
        final PlatformFile file = files.first;
        final Uint8List bytes = await file.readAsBytes();

        setState(() {
          selectedImageBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint('Pick image error: $e');
    }
  }

  void openTypePicker(BuildContext context) async {
    final state = context.read<ProductTypesBloc>().state;

    // Проверяем, что типы успешно загружены в стор
    if (state is ManageProductsTypeSuccess) {
      final result = await SelectProductTypeDialog.show(
        context,
        types: state.types, // Передаем полученный список из BLoC
        selected: selectedProductType,
      );

      if (result != null) {
        setState(() {
          selectedProductType = result;
        });
      }
    } else {
      // Если типы еще не загружены, можно триггернуть загрузку или показать SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Типы еще не загрузились, подождите...')),
      );
    }
  }

  Future<void> _addOrEditVariant([ProductVariant? variant, int? index]) async {
    final result = await VariantEditBottomSheet.show(context, variant: variant);

    if (result != null) {
      setState(() {
        if (index != null) {
          // Редактирование
          variants[index] = result;
        } else {
          // Добавление нового
          variants.add(result);
        }
      });
    }
  }

  InputDecoration _customInputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      // filled: true,
      // fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        // borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        // borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product' : 'Add Product'),
        elevation: 0,
      ),
      body: BlocConsumer<AddProductBloc, AddProductState>(
        listener: (context, state) {
          if (state is AddProductError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.failure.message)),
            );
          }
          if (state is AddProductSuccess) {
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          if (state is AddProductLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Name',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: nameController,
                            decoration: _customInputDecoration('Enter product name'),
                          ),
                          SizedBox(height: ThemeDimensions.paddingM),
                          const Text(
                            'Description',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: descController,
                            maxLines: 3,
                            decoration: _customInputDecoration('Enter description'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Photo',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          if (selectedImageBytes != null)
                            Stack(
                              alignment: Alignment.topRight,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    selectedImageBytes!,
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.cancel, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        selectedImageBytes = null;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            )
                          else if (isEditing && (widget.product?.photoUrl.isNotEmpty ?? false))
                            Stack(
                              alignment: Alignment.topRight,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    widget.product!.photoUrl,
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton.icon(
                                    onPressed: _pickImage,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Change photo'),
                                  ),
                                ),
                              ],
                            )
                          else
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                minimumSize: const Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _pickImage,
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Pick photo'),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ProductType',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              openTypePicker(context);
                            },
                            child: const Text('Select type'),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Selected type : ${selectedProductType != null ? selectedProductType?.name : 'not selected'}',
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Variants', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              TextButton.icon(
                                onPressed: () => _addOrEditVariant(),
                                icon: const Icon(Icons.add),
                                label: const Text('Add'),
                              ),
                            ],
                          ),
                          if (variants.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text('No variants', style: TextStyle(color: Colors.grey)),
                            ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: variants.length,
                            itemBuilder: (context, index) {
                              final item = variants[index];
                              return Card(
                                elevation: 0,
                                // color: Colors.grey.shade50,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.grey.shade200),
                                ),
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                    'Price: ${item.price} | Netto: ${item.netWeight} кг | Brutto: ${item.grossWeight} кг',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => _addOrEditVariant(item, index),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          setState(() => variants.removeAt(index));
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: ThemeDimensions.paddingL),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        if (isEditing) {
                          // 1. При редактировании обновляем существующий товар
                          final updatedModel = ProductModel(
                            id: widget.product!.id,
                            date: widget.product!.date,
                            productType: selectedProductType!,
                            name: nameController.text.trim(),
                            description: descController.text.trim(),
                            photoUrl: widget.product!.photoUrl,
                            // Оставляем текущую ссылку, если новую картинку не выбирали
                            variants: variants,
                          );

                          // Отправляем EditEvent (selectedImageBytes может быть null, если фото не меняли)
                          context.read<AddProductBloc>().add(EditEvent(updatedModel, selectedImageBytes));
                        } else {
                          // 2. При создании добавляем новый товар
                          if (selectedImageBytes == null) return;

                          final newModel = ProductModel(
                            productType: selectedProductType!,
                            name: nameController.text.trim(),
                            description: descController.text.trim(),
                            photoUrl: '',
                            variants: variants,
                          );

                          context.read<AddProductBloc>().add(AddEvent(newModel, selectedImageBytes!));
                        }
                      },
                      child: const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class SelectProductTypeDialog extends StatelessWidget {
  final List<ProductTypeModel> types;
  final ProductTypeModel? initialType;

  const SelectProductTypeDialog({
    super.key,
    required this.types,
    this.initialType,
  });

  // Вспомогательный метод для вызова диалога
  static Future<ProductTypeModel?> show(
    BuildContext context, {
    required List<ProductTypeModel> types,
    ProductTypeModel? selected,
  }) {
    return showDialog<ProductTypeModel>(
      context: context,
      builder: (context) => SelectProductTypeDialog(
        types: types,
        initialType: selected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Получаем текущий код языка приложения (например, 'ru' или 'uz')
    final currentLang = Localizations.localeOf(context).languageCode;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Select type'),
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
      content: SizedBox(
        width: double.maxFinite,
        child: types.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No product types available',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: types.length,
                itemBuilder: (context, index) {
                  final type = types[index];
                  final isSelected = type.id == initialType?.id;

                  // Берем название на текущем языке или фолбэкнемся на RU/первый доступный
                  final displayName = type.getName(currentLang);

                  return ListTile(
                    title: Text(
                      displayName,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                      ),
                    ),
                    trailing: isSelected ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor) : null,
                    onTap: () => Navigator.of(context).pop(type), // Возвращаем выбранную модель
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class VariantEditBottomSheet extends StatefulWidget {
  final ProductVariant? variant; // Если передали — редактирование, если null — создание

  const VariantEditBottomSheet({super.key, this.variant});

  static Future<ProductVariant?> show(BuildContext context, {ProductVariant? variant}) {
    return showModalBottomSheet<ProductVariant>(
      context: context,
      isScrollControlled: true, // Важно, чтобы клавиатура не перекрывала поля
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => VariantEditBottomSheet(variant: variant),
    );
  }

  @override
  State<VariantEditBottomSheet> createState() => _VariantEditBottomSheetState();
}

class _VariantEditBottomSheetState extends State<VariantEditBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _valueController;
  late TextEditingController _netWeightController;
  late TextEditingController _grossWeightController;
  late TextEditingController _itemsInPackageController;

  UnitType _selectedUnit = UnitType.kg;

  @override
  void initState() {
    super.initState();
    final v = widget.variant;
    _nameController = TextEditingController(text: v?.name ?? '');
    _priceController = TextEditingController(text: v?.price.toString() ?? '');
    _valueController = TextEditingController(text: v?.value.toString() ?? '');
    _netWeightController = TextEditingController(text: v?.netWeight.toString() ?? '');
    _grossWeightController = TextEditingController(text: v?.grossWeight.toString() ?? '');
    _itemsInPackageController = TextEditingController(text: v?.itemsInPackage?.toString() ?? '');
    if (v != null) _selectedUnit = v.unit;
  }

  InputDecoration _dialogInputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      filled: true,
      // fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        // Отступ под клавиатуру
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 16,
          left: 16,
          right: 16,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  widget.variant == null ? 'Add variant' : 'Edit variant',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Название варианта
                TextFormField(
                  controller: _nameController,
                  decoration: _dialogInputDecoration('Name (example: Box 10 kg)'),
                  validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
                ),
                const SizedBox(height: 12),

                // Цена и Единица измерения
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: _dialogInputDecoration('Price'),
                        validator: (v) => v == null || v.isEmpty ? 'Enter price' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<UnitType>(
                        initialValue: _selectedUnit,
                        decoration: _dialogInputDecoration('Unit'),
                        items: UnitType.values.map((unit) {
                          return DropdownMenuItem(
                            value: unit,
                            child: Text(unit.name.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedUnit = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Вес Нетто и Вес Брутто
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _netWeightController,
                        keyboardType: TextInputType.number,
                        decoration: _dialogInputDecoration('Netto (kg)'),
                        validator: (v) => v == null || v.isEmpty ? 'Enter netto' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _grossWeightController,
                        keyboardType: TextInputType.number,
                        decoration: _dialogInputDecoration('Brutto (kg)'),
                        validator: (v) => v == null || v.isEmpty ? 'Enter brutto' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Значение объема/количества и Шт в упаковке
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _valueController,
                        keyboardType: TextInputType.number,
                        decoration: _dialogInputDecoration('Vol / Qty'),
                        validator: (v) => v == null || v.isEmpty ? 'Specify volume' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _itemsInPackageController,
                        keyboardType: TextInputType.number,
                        decoration: _dialogInputDecoration('Items per pack (opt.)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Кнопка Сохранить
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _submit,
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newVariant = ProductVariant(
        id: widget.variant?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text.replaceAll(',', '.')),
        value: double.parse(_valueController.text.replaceAll(',', '.')),
        unit: _selectedUnit,
        netWeight: double.parse(_netWeightController.text.replaceAll(',', '.')),
        grossWeight: double.parse(_grossWeightController.text.replaceAll(',', '.')),
        itemsInPackage: int.tryParse(_itemsInPackageController.text),
      );

      Navigator.of(context).pop(newVariant);
    }
  }
}
