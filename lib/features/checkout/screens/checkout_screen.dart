import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/services/notification_service.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../orders/models/order.dart';
import '../../orders/screens/order_tracking_screen.dart';
import '../../cart/models/cart_item.dart';
import '../../orders/controllers/order_controller.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  String _paymentMethod = 'cash';

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLocating = false;

  // clear controllers when screen closed
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Get current location
  Future<void> _useCurrentLocation() async {
    setState(() => _isLocating = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('location_disabled')),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('location_denied')),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('location_permanently_denied')),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Try getting the last known position first (fastest)
      Position? position = await Geolocator.getLastKnownPosition();

      // On Android emulators (especially Android 10 and below), the mock location
      // is fed through the GPS provider (high accuracy). Try high first, then fallback to low.
      if (position == null) {
        try {
          position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 6),
            ),
          );
        } catch (_) {
          position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.low,
              timeLimit: Duration(seconds: 6),
            ),
          );
        }
      }

      final Position finalPos = position;

      if (!mounted) return;
      setState(() {
        _addressController.text =
            'Location (${finalPos.latitude.toStringAsFixed(4)}, ${finalPos.longitude.toStringAsFixed(4)})';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('location_detected')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not fetch location. Please enter manually: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('checkout'))),

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('customer_details'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: context.tr('full_name'),
                        prefixIcon: const Icon(Icons.person_outline),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return context.tr('name_validation');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: context.tr('phone_number'),
                        prefixIcon: const Icon(Icons.phone_outlined),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return context.tr('phone_validation');
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: context.tr('delivery_address'),
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        suffixIcon: IconButton(
                          tooltip: context.tr('use_my_location'),
                          onPressed: _isLocating ? null : _useCurrentLocation,
                          icon: _isLocating
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  Icons.my_location,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                        ),
                        border: const OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return context.tr('address_validation');
                        }
                        return null;
                      },
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton.icon(
                        onPressed: _isLocating ? null : _useCurrentLocation,
                        icon: const Icon(Icons.my_location, size: 16),
                        label: Text(context.tr('use_my_location')),
                      ),
                    ),

                    const SizedBox(height: 24),
                    Text(
                      context.tr('payment_method'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Card(
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            value: 'cash',
                            groupValue: _paymentMethod,
                            onChanged: (value) {
                              setState(() {
                                _paymentMethod = value!;
                              });
                            },
                            title: Text(context.tr('cash_on_delivery')),
                            subtitle: Text(context.tr('pay_on_arrival')),
                            secondary: const Icon(Icons.money),
                          ),
                          const Divider(height: 1),
                          RadioListTile<String>(
                            value: 'card',
                            groupValue: _paymentMethod,
                            onChanged: (value) {
                              setState(() {
                                _paymentMethod = value!;
                              });
                            },
                            title: Text(context.tr('card_payment')),
                            subtitle: Text(context.tr('pay_online')),
                            secondary: const Icon(Icons.credit_card),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    Text(
                      context.tr('order_summary'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ...cart.items.map(
                      (item) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item.product.name),
                        subtitle: Text(
                          '${context.tr('quantity')}: ${item.quantity}',
                        ),
                        trailing: Text(
                          '\$${item.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const Divider(),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.tr('total'),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        Text(
                          '\$${cart.totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }
                          if (cart.items.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(context.tr('cart_empty_error')),
                              ),
                            );
                            return;
                          }

                          final currentLang = context
                              .read<LocaleController>()
                              .languageCode;

                          final order = CustomerOrder(
                            id: DateTime.now().millisecondsSinceEpoch
                                .toString(),
                            items: cart.items
                                .map(
                                  (item) => CartItem(
                                    product: item.product,
                                    quantity: item.quantity,
                                  ),
                                )
                                .toList(),
                            totalPrice: cart.totalPrice,
                            customerName: _nameController.text.trim(),
                            phoneNumber: _phoneController.text.trim(),
                            deliveryAddress: _addressController.text.trim(),
                            paymentMethod: _paymentMethod,
                          );

                          context.read<OrderController>().addOrder(
                            order,
                            langCode: currentLang,
                          );
                          cart.clearCart();

                          final shortId = order.id.substring(
                            order.id.length > 6 ? order.id.length - 6 : 0,
                          );
                          NotificationService().showNotification(
                            id: 1,
                            title: context.tr('order_placed_title'),
                            body:
                                '${context.tr('order_placed_body')} #$shortId',
                          );

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OrderTrackingScreen(order: order),
                            ),
                          );
                        },
                        child: Text(context.tr('place_order')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
