import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/product.dart';

class ProductRepository {
  Future<List<Product>> loadProducts() async{
    final jsonString = await rootBundle.loadString(
      'assets/data/products.json',
    );

    final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;

    return jsonList.map((json)=>Product.fromJson(json as Map<String, dynamic>),
    ).toList();
  }
}