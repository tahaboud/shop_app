import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import 'dart:convert';

import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  // var _showFavoritesOnly = false;
  final String? authToken;
  final String? userId;
  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    // if (_showFavoritesOnly)
    //   return _items.where((item) => item.isFavorite).toList();
    return [..._items];
  }

  List<Product> get favoritesItems {
    return _items.where((item) => item.isFavorite).toList();
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  Future<void> fetchAndSetProducts({bool filterByUser = false}) async {
    final filterString =
        filterByUser ? '&orderBy="creatorId"&equalTo="$userId"' : "";
    final url = Uri.parse(
        'https://fluttershopapp-c3ffb-default-rtdb.firebaseio.com/products.json?auth=$authToken$filterString');
    try {
      final response = await http.get(url);
      final extractedData = jsonDecode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      final favoritesUrl = Uri.parse(
          "https://fluttershopapp-c3ffb-default-rtdb.firebaseio.com/userFavourites/$userId.json?auth=$authToken");
      final favoriteResponse = await http.get(favoritesUrl);
      final favoriteData = jsonDecode(favoriteResponse.body);
      extractedData.forEach((key, value) {
        loadedProducts.add(Product(
          id: key,
          title: value["title"],
          description: value["description"],
          price: value["price"],
          imageUrl: value["imageUrl"],
          isFavorite: favoriteData == null
              ? false
              : favoriteData[key]["isFavorite"] ?? false,
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Product findById(String id) {
    return _items.firstWhere((item) => item.id == id);
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://fluttershopapp-c3ffb-default-rtdb.firebaseio.com/products.json?auth=$authToken');
    try {
      final response = await http.post(url,
          body: json.encode({
            "title": product.title,
            "description": product.description,
            "price": product.price,
            "imageUrl": product.imageUrl,
            "creatorId": userId,
          }));

      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)["name"],
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product updatedProduct) async {
    final prodIndex = _items.indexWhere((item) => item.id == id);
    final url = Uri.parse(
        "https://fluttershopapp-c3ffb-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken");
    await http.patch(url,
        body: jsonEncode({
          "title": updatedProduct.title,
          "description": updatedProduct.description,
          "imageUrl": updatedProduct.imageUrl,
          "price": updatedProduct.price,
        }));
    if (prodIndex >= 0) {
      _items[prodIndex] = updatedProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        "https://fluttershopapp-c3ffb-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken");
    int? existingProductIndex = _items.indexWhere((item) => item.id == id);
    Product? existingProduct = _items[existingProductIndex];
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException("Could not delete product");
    }
    existingProduct = null;
    existingProductIndex = null;
  }
}
