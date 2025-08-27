import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  
  List<CartItem> get cartItems => state;

  
  int get itemCount => state.fold(0, (sum, item) => sum + item.quantity);

  
  double get totalAmount => state.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));

  
  bool get isEmpty => state.isEmpty;

  
  bool get isNotEmpty => state.isNotEmpty;

  
  void addToCart(Product product, {int quantity = 1}) {
    final existingIndex = state.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      
      final updatedItems = [...state];
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + quantity,
      );
      state = updatedItems;
    } else {
      
      final newItem = CartItem(
        id: '${product.id}_${DateTime.now().millisecondsSinceEpoch}',
        product: product,
        quantity: quantity,
      );
      state = [...state, newItem];
    }
  }

  
  void updateQuantity(String itemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(itemId);
      return;
    }

    final updatedItems = state.map((item) {
      if (item.id == itemId) {
        return item.copyWith(quantity: newQuantity);
      }
      return item;
    }).toList();

    state = updatedItems;
  }

  
  void removeFromCart(String itemId) {
    state = state.where((item) => item.id != itemId).toList();
  }

  
  void clearCart() {
    state = [];
  }

  
  bool isInCart(String productId) {
    return state.any((item) => item.product.id == productId);
  }

  
  int getProductQuantity(String productId) {
    final item = state.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(
        id: '', 
        product: Product(
          id: '', 
          name: '', 
          description: '', 
          price: 0, 
          imageUrl: '', 
          category: '', 
          rating: 0, 
          reviewCount: 0, 
          isInStock: false
        ), 
        quantity: 0
      ),
    );
    return item.quantity;
  }

  
  void increaseQuantity(String productId) {
    final index = state.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      final updatedItems = [...state];
      updatedItems[index] = updatedItems[index].copyWith(
        quantity: updatedItems[index].quantity + 1,
      );
      state = updatedItems;
    }
  }

  
  void decreaseQuantity(String productId) {
    final index = state.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      final currentQuantity = state[index].quantity;
      if (currentQuantity > 1) {
        final updatedItems = [...state];
        updatedItems[index] = updatedItems[index].copyWith(
          quantity: currentQuantity - 1,
        );
        state = updatedItems;
      } else {
        state = state.where((item) => item.product.id != productId).toList();
      }
    }
  }

  
  CartItem? getCartItem(String productId) {
    try {
      return state.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }
}


final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});


final cartItemCountProvider = Provider<int>((ref) {
  final cartItems = ref.watch(cartProvider);
  return cartItems.fold(0, (sum, item) => sum + item.quantity);
});

final cartTotalAmountProvider = Provider<double>((ref) {
  final cartItems = ref.watch(cartProvider);
  return cartItems.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
});

final cartIsEmptyProvider = Provider<bool>((ref) {
  final cartItems = ref.watch(cartProvider);
  return cartItems.isEmpty;
});
