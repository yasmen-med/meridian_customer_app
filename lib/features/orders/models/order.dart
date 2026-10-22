import '../../cart/models/cart_item.dart';

class CustomerOrder {
  final String id;
  final List<CartItem> items;
  final double totalPrice;
  final String customerName;
  final String phoneNumber;
  final String deliveryAddress;
  final String paymentMethod;
  final String status;

  CustomerOrder({
    required this.id,
    required this.items,
    required this.totalPrice,
    required this.customerName,
    required this.phoneNumber,
    required this.deliveryAddress,
    required this.paymentMethod,
    this.status = 'Placed',
  });
}