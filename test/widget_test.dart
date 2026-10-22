import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meridian_customer_app/core/localization/locale_controller.dart';
import 'package:meridian_customer_app/features/products/models/product.dart';
import 'package:meridian_customer_app/features/products/widgets/product_card.dart';
import 'package:meridian_customer_app/features/cart/controllers/cart_controller.dart';
import 'package:meridian_customer_app/features/orders/controllers/order_controller.dart';
import 'package:meridian_customer_app/features/cart/screens/cart_screen.dart';
import 'package:meridian_customer_app/features/orders/screens/order_tracking_screen.dart';
import 'package:meridian_customer_app/features/orders/models/order.dart';

void main() {
  group('Meridian Customer App Widget Tests', () {
    testWidgets('ProductCard displays title, price, and button',
        (WidgetTester tester) async {
      const mockProduct = Product(
        id: '1',
        name: 'Vitamin C 1000mg',
        description: 'Immunity booster dietary supplement',
        price: 9.99,
        category: 'Wellness',
        imageUrl: '',
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => LocaleController()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 300,
                width: 200,
                child: ProductCard(product: mockProduct),
              ),
            ),
          ),
        ),
      );

      // Verify product information is displayed
      expect(find.text('Vitamin C 1000mg'), findsOneWidget);
      expect(find.text('\$9.99'), findsOneWidget);
      expect(find.text('View Details'), findsOneWidget);
    });

    testWidgets('CartScreen displays empty state when cart has no items',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => LocaleController()),
            ChangeNotifierProvider(create: (_) => CartController()),
            ChangeNotifierProvider(create: (_) => OrderController()),
          ],
          child: const MaterialApp(
            home: CartScreen(),
          ),
        ),
      );

      // Verify empty cart message
      expect(find.text('Your cart is empty'), findsOneWidget);
      expect(find.text('Continue shopping'), findsOneWidget);
    });

    testWidgets('OrderTrackingScreen renders order timeline stages',
        (WidgetTester tester) async {
      final mockOrder = CustomerOrder(
        id: '1001',
        items: [],
        totalPrice: 19.98,
        customerName: 'Test User',
        phoneNumber: '1234567890',
        deliveryAddress: 'Main St 123',
        paymentMethod: 'cash',
        status: 'Placed',
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => LocaleController()),
            ChangeNotifierProvider(create: (_) => OrderController()),
          ],
          child: MaterialApp(
            home: OrderTrackingScreen(order: mockOrder),
          ),
        ),
      );

      // Verify initial order status and timeline
      expect(find.text('Order placed successfully!'), findsOneWidget);
      expect(find.text('Order ID: #1001'), findsOneWidget);
      expect(find.text('Placed'), findsOneWidget);
      expect(find.text('Preparing'), findsOneWidget);
      expect(find.text('Out for Delivery'), findsOneWidget);
      expect(find.text('Delivered'), findsOneWidget);
    });

    testWidgets('ProductCard displays Arabic name when locale is ar',
        (WidgetTester tester) async {
      const mockProduct = Product(
        id: '1',
        name: 'Vitamin C',
        nameAr: 'فيتامين سي',
        description: 'Immunity booster dietary supplement',
        descriptionAr: 'مكمل غذائي لتعزيز المناعة',
        price: 9.99,
        category: 'Wellness',
        imageUrl: '',
      );

      final arabicLocaleController = LocaleController()..setLocale(const Locale('ar'));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: arabicLocaleController),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 300,
                width: 200,
                child: ProductCard(product: mockProduct),
              ),
            ),
          ),
        ),
      );

      // Verify Arabic product name and details are displayed
      expect(find.text('فيتامين سي'), findsOneWidget);
      expect(find.text('مكمل غذائي لتعزيز المناعة'), findsOneWidget);
      expect(find.text('عرض التفاصيل'), findsOneWidget);
    });
  });
}
