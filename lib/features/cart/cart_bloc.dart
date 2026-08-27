import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qde_eco_bahor/features/auth/presentation/bloc/auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/di/injection_container.dart';
import '../admin/models/product_model.dart';
import '../admin/models/product_variant.dart';
import '../auth/presentation/bloc/auth_bloc.dart';
import 'cart_item.dart';

class CartState {
  final List<CartItem> items;

  CartState({required this.items});

  double get totalAmount => items.fold(0, (sum, item) => sum + item.totalPrice);

  int get totalCount => items.fold(0, (sum, item) => sum + item.quantity);
}

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartState(items: []));

  Future<void> loadCart(String? id) async {
    print('!!!!!!!!!!!!!!!!!!!============================  LOAD CART');
    try {
      final prefs = await SharedPreferences.getInstance();

      // 2. Формируем userId
      final userId = id ?? 'guest';

      // 3. Формируем ключ локалки
      final cartKey = 'cart_items_$userId';

      print('key==================== ${cartKey}');
      final jsonString = prefs.getString(cartKey);
      print('==================== ${jsonString}');

      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decodedList = jsonDecode(jsonString);

        try {
          final items = decodedList.map((item) {
            final map = Map<String, dynamic>.from(item as Map);
            return CartItem.fromJson(map);
          }).toList();

          emit(CartState(items: items));
        } catch (e) {
          print('ERROR ------------------------------ ${e.toString()}');
        }
      }
    } catch (_) {
      // При ошибке декодирования сохраняем текущий стейт
      print('load error =========== ${_.toString()}');
      emit(CartState(items: []));
    }
  }

  Future<void> _saveCart(List<CartItem> items) async {
    print('💾 [SAVE CART CALLED] Key: э, Items count: ${items.length}');
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawData = items.map((e) => e.toJson()).toList();
      final jsonString = jsonEncode(
        rawData,
        toEncodable: (item) {
          if (item is Timestamp) {
            return item.toString(); // Превращает Timestamp внутри продукта в обычную строку
          }
          return item.toString();
        },
      );

      final authState = getIt<AuthBloc>().state;

      // 2. Формируем userId
      final userId = (authState is AuthAuthenticatedState) ? authState.user.id : 'guest';

      // 3. Формируем ключ локалки
      final cartKey = 'cart_items_$userId';
      print('ххххххххххххххххххх================data ${rawData}');
      await prefs.setString(cartKey, jsonString);
      print('хххххххххххххххххAFTER ====================');
      final test = prefs.get(cartKey);
      print('ххххххххххххххAFTER test key==================== ${cartKey}');
      print('ххххххххххххххххххAFTER test==================== ${test}');
    } catch (e) {
      print('хххххххххххххххххххх================[[[[[[[[[[[[[[[ERROR ===  ${e.toString()}');
    }
  }

  void addProduct(ProductModel product, ProductVariant variant, int qty) {
    final currentItems = List<CartItem>.from(state.items);
    final index = currentItems.indexWhere(
      (item) => item.product.id == product.id && item.variant.id == variant.id,
    );

    if (index >= 0) {
      currentItems[index].quantity += qty;
    } else {
      currentItems.add(CartItem(product: product, variant: variant, quantity: qty));
    }

    emit(CartState(items: currentItems));
    _saveCart(currentItems);
  }

  void updateQuantity(String variantId, int delta) {
    final currentItems = List<CartItem>.from(state.items);
    final index = currentItems.indexWhere((item) => item.variant.id == variantId);

    if (index >= 0) {
      currentItems[index].quantity += delta;
      if (currentItems[index].quantity <= 0) {
        currentItems.removeAt(index);
      }
      emit(CartState(items: currentItems));
      _saveCart(currentItems);
    }
  }

  void clearCart() {
    emit(CartState(items: []));
    _saveCart([]);
  }
}
