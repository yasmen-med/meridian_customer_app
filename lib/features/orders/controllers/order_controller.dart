import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/services/notification_service.dart';
import '../models/order.dart';

class OrderController extends ChangeNotifier {
  final List<CustomerOrder> _orders = [];
  final Map<String, Timer> _orderTimers = {};

  static const List<String> _statuses = [
    'Placed',
    'Preparing',
    'Out for Delivery',
    'Delivered',
  ];

  List<CustomerOrder> get orders => List.unmodifiable(_orders);

  void addOrder(CustomerOrder order, {String langCode = 'en'}) {
    _orders.insert(0, order);
    notifyListeners();

    // Schedule OS-level notifications so they trigger even if the app is closed
    _scheduleOrderNotifications(order.id, langCode: langCode);

    // Start in-app timer to update UI state in real time across screens
    _startTrackingSimulation(order.id);
  }

  void _scheduleOrderNotifications(String orderId, {String langCode = 'en'}) {
    final baseId = (orderId.hashCode.abs() % 10000) * 10;

    // 1. Preparing (+10 seconds)
    NotificationService().scheduleNotification(
      id: baseId + 1,
      title: AppTranslations.tr('notif_preparing_title', langCode),
      body: AppTranslations.tr('notif_preparing_body', langCode),
      delay: const Duration(seconds: 10),
    );

    // 2. Out for Delivery (+20 seconds)
    NotificationService().scheduleNotification(
      id: baseId + 2,
      title: AppTranslations.tr('notif_delivery_title', langCode),
      body: AppTranslations.tr('notif_delivery_body', langCode),
      delay: const Duration(seconds: 20),
    );

    // 3. Delivered (+30 seconds)
    NotificationService().scheduleNotification(
      id: baseId + 3,
      title: AppTranslations.tr('notif_delivered_title', langCode),
      body: AppTranslations.tr('notif_delivered_body', langCode),
      delay: const Duration(seconds: 30),
    );
  }

  void _startTrackingSimulation(String orderId) {
    _orderTimers[orderId]?.cancel();

    _orderTimers[orderId] = Timer.periodic(const Duration(seconds: 10), (timer) {
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index == -1) {
        timer.cancel();
        _orderTimers.remove(orderId);
        return;
      }

      final currentStatus = _orders[index].status;
      final currentIndex = _statuses.indexOf(currentStatus);

      if (currentIndex < 0 || currentIndex >= _statuses.length - 1) {
        timer.cancel();
        _orderTimers.remove(orderId);
        return;
      }

      final nextStatus = _statuses[currentIndex + 1];
      updateOrderStatus(orderId, nextStatus);

      if (nextStatus == 'Delivered') {
        timer.cancel();
        _orderTimers.remove(orderId);
      }
    });
  }

  void updateOrderStatus(String orderId, String newStatus) {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      final old = _orders[index];
      _orders[index] = CustomerOrder(
        id: old.id,
        items: old.items,
        totalPrice: old.totalPrice,
        customerName: old.customerName,
        phoneNumber: old.phoneNumber,
        deliveryAddress: old.deliveryAddress,
        paymentMethod: old.paymentMethod,
        status: newStatus,
      );
      notifyListeners();
    }
  }

  @override
  void dispose() {
    for (final timer in _orderTimers.values) {
      timer.cancel();
    }
    _orderTimers.clear();
    super.dispose();
  }
}
