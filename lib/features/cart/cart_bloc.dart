import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qde_eco_bahor/core/utils/app_constants.dart';
import 'package:qde_eco_bahor/features/admin/moderate_order/order_model.dart';
import 'package:qde_eco_bahor/features/auth/presentation/bloc/auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/di/injection_container.dart';
import '../admin/models/product_model.dart';
import '../admin/models/product_variant.dart';
import '../auth/presentation/bloc/auth_bloc.dart';
import 'cart_item.dart';

enum CartStatus { initial, loading, success, error }

class CartState {
  final List<CartItem> items;
  final CartStatus status;
  final String? errorMessage;

  CartState({
    required this.items,
    this.status = CartStatus.initial,
    this.errorMessage,
  });

  double get totalAmount => items.fold(0, (sum, item) => sum + item.totalPrice);

  int get totalCount => items.fold(0, (sum, item) => sum + item.quantity);

  CartState copyWith({
    List<CartItem>? items,
    CartStatus? status,
    String? errorMessage,
  }) {
    return CartState(
      items: items ?? this.items,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartState(items: []));

  Future<void> addOrder(OrderModel order) async {
    emit(state.copyWith(status: CartStatus.loading));
    try {
      final db = FirebaseFirestore.instance;
      final ref = db.collection(AppConstants.orders).doc();
      final updatedOrder = order.copyWith(id: ref.id);
      await ref.set(updatedOrder.toJson());

      await clearCart();
      emit(state.copyWith(status: CartStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> loadCart(String? id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = id ?? 'guest';
      final cartKey = 'cart_items_$userId';
      final jsonString = prefs.getString(cartKey);

      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decodedList = jsonDecode(jsonString);

        try {
          final items = decodedList.map((item) {
            final map = Map<String, dynamic>.from(item as Map);
            return CartItem.fromJson(map);
          }).toList();

          emit(state.copyWith(items: items, status: CartStatus.initial));
        } catch (e) {
          print('ERROR ------------------------------ ${e.toString()}');
        }
      }
    } catch (_) {
      emit(state.copyWith(items: [], status: CartStatus.initial));
    }
  }

  Future<void> _saveCart(List<CartItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawData = items.map((e) => e.toJson()).toList();
      final jsonString = jsonEncode(
        rawData,
        toEncodable: (item) {
          if (item is Timestamp) {
            return item.toString();
          }
          return item.toString();
        },
      );

      final authState = getIt<AuthBloc>().state;
      final userId = (authState is AuthAuthenticatedState) ? authState.user.id : 'guest';
      final cartKey = 'cart_items_$userId';

      await prefs.setString(cartKey, jsonString);
    } catch (e) {}
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

    emit(state.copyWith(items: currentItems, status: CartStatus.initial));
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
      emit(state.copyWith(items: currentItems, status: CartStatus.initial));
      _saveCart(currentItems);
    }
  }

  Future<void> clearCart() async {
    emit(state.copyWith(items: [], status: CartStatus.initial));
    await _saveCart([]);
  }
}
