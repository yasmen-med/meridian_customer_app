import 'package:flutter/foundation.dart';
import '../../products/models/product.dart';
import '../models/cart_item.dart';

class CartController extends ChangeNotifier{
  final List<CartItem> _items = [];

  List<CartItem> get items =>List.unmodifiable(_items);

  int get itemCount => _items.fold(0,(total, item) => total + item.quantity);
  double get totalPrice => _items.fold(0.0, (total, item) => total + item.totalPrice);
  void addProduct(Product product, {int quantity =1}){
    if (quantity<1) return;

    final index = _items.indexWhere(
      (item)=>item.product.id == product.id,
    );

    if(index >= 0){
      _items[index].quantity += quantity;
    } else{
      _items.add(
        CartItem(product: product, quantity: quantity)
      );
    }
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity){
    final index = _items.indexWhere(
      (item)=> item.product.id == productId,
    );
    if (index == -1) return;
    if (quantity<= 0){
      _items.removeAt(index);
    }else{
      _items[index].quantity = quantity;
    }
    notifyListeners();
  }

  void removeProduct(String productId){
    _items.removeWhere(
      (item)=> item.product.id == productId
    );
    notifyListeners();
  }

  void clearCart() {
  _items.clear();
  notifyListeners();
}
}