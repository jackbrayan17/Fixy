import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/notification_service.dart';
import 'package:sqflite/sqflite.dart';

class AppProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  User? _currentUser;
  List<Product> _products = [];
  List<CartItem> _cartItems = [];
  List<OrderModel> _orders = [];
  bool _isDarkMode = false;

  User? get currentUser => _currentUser;
  List<Product> get products => _products;
  List<CartItem> get cartItems => _cartItems;
  List<OrderModel> get orders => _orders;
  bool get isDarkMode => _isDarkMode;

  double get cartTotal {
    return _cartItems.fold(0, (sum, item) => sum + (item.productPrice! * item.quantity));
  }

  Future<void> init() async {
    await loadProducts();
    await loadCart();
    await loadOrders();
    await _loadSession();
    await _loadTheme();
    await seedDatabase();
  }

  Future<void> seedDatabase() async {
    // Force clear all products and re-seed with authorized collection only
    Database db = await _dbHelper.database;
    await db.delete('products');
    await db.delete('product_images');
    
    
    final mockProducts = [
      {
        'title': 'Jumpsuit Chic',
        'description': 'Combinaison chic en noir et blanc.',
        'price': 25000.0,
        'category': 'Combinaisons',
        'images': ['assets/images/products/blackwhitejumpsuits.png']
      },
      {
        'title': 'Tenue Casual',
        'description': 'Vêtement décontracté marron.',
        'price': 15000.0,
        'category': 'Casual',
        'images': ['assets/images/products/brown-casual.png']
      },
      {
        'title': 'Blazer Premium',
        'description': 'Blazer professionnel soigné.',
        'price': 35000.0,
        'category': 'Blazers',
        'images': ['assets/images/products/darkbrown-blazer.png']
      },
      {
        'title': 'Robe Longue Beige',
        'description': 'Magnifique robe longue beige.',
        'price': 45000.0,
        'category': 'Robes',
        'images': ['assets/images/products/longgown-beige.png']
      },
      {
        'title': 'Robe Rose d\'été',
        'description': 'Robe fluide rose.',
        'price': 20000.0,
        'category': 'Robes',
        'images': ['assets/images/products/pink-robe.png']
      },
      {
        'title': 'Robe de Soirée Rouge',
        'description': 'Robe rouge éclatante.',
        'price': 50000.0,
        'category': 'Robes',
        'images': ['assets/images/products/red-gown.png']
      },
      {
        'title': 'Débardeur Rouge',
        'description': 'Débardeur simple en rouge.',
        'price': 8000.0,
        'category': 'Hauts',
        'images': ['assets/images/products/red-tanktop.png']
      },
      {
        'title': 'Robe Rose Pétale',
        'description': 'Douce robe rose pétale.',
        'price': 22000.0,
        'category': 'Robes',
        'images': ['assets/images/products/robe-petalpink.png']
      },
      {
        'title': 'Top Bleu',
        'description': 'Haut bleu à manches courtes.',
        'price': 12000.0,
        'category': 'Hauts',
        'images': ['assets/images/products/shortsleeve-blue.png']
      },
      {
        'title': 'T-Shirt Blanc',
        'description': 'T-shirt blanc essentiel.',
        'price': 5000.0,
        'category': 'Hauts',
        'images': ['assets/images/products/tshirts (1).png']
      },
      {
        'title': 'Robe Jaune',
        'description': 'Robe jaune lumineuse.',
        'price': 18000.0,
        'category': 'Robes',
        'images': ['assets/images/products/yello.png']
      },
      {
        'title': 'Robe Elégante Jaune',
        'description': 'Version élégante de la robe jaune.',
        'price': 25000.0,
        'category': 'Robes',
        'images': ['assets/images/products/yellow-robe.png']
      },
    ];

    for (var p in mockProducts) {
      String title = p['title'] as String;
      String description = p['description'] as String;
      double price = p['price'] as double;
      String category = p['category'] as String;
      List<String> images = p['images'] as List<String>;
      
      await _dbHelper.insertProduct({
        'title': title,
        'description': description,
        'price': price,
        'category': category,
      }, images);
    }
    await loadProducts();
  }

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  // --- Auth ---
  Future<bool> signUp(User user) async {
    int id = await _dbHelper.insertUser(user.toMap());
    if (id > 0) {
      user.id = id;
      _currentUser = user;
      await _saveSession(id);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> login(String username, String password) async {
    var userMap = await _dbHelper.getUser(username, password);
    if (userMap != null) {
      _currentUser = User.fromMap(userMap);
      await _saveSession(_currentUser!.id!);
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() async {
    _currentUser = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    notifyListeners();
  }

  Future<void> _saveSession(int userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId);
  }

  Future<void> _loadSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    if (userId != null) {
      Database db = await _dbHelper.database;
      List<Map<String, dynamic>> maps = await db.query('users', where: 'id = ?', whereArgs: [userId]);
      if (maps.isNotEmpty) {
        _currentUser = User.fromMap(maps.first);
        notifyListeners();
      }
    }
  }

  Future<void> updateUserProfile(User user) async {
    await _dbHelper.updateUser(user.toMap());
    _currentUser = user;
    notifyListeners();
  }

  // --- Products ---
  Future<void> loadProducts() async {
    var productMaps = await _dbHelper.getProducts();
    _products = productMaps.map((m) => Product.fromMap(m, List<String>.from(m['images']))).toList();
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    await _dbHelper.insertProduct(product.toMap(), product.images);
    await loadProducts();
  }

  Future<void> deleteProduct(int id) async {
    await _dbHelper.deleteProduct(id);
    await loadProducts();
  }

  Future<void> editProduct(Product product) async {
    await _dbHelper.updateProduct(product.toMap(), product.images);
    await loadProducts();
  }

  // --- Cart ---
  Future<void> loadCart() async {
    var cartMaps = await _dbHelper.getCartItems();
    _cartItems = cartMaps.map((m) => CartItem.fromMap(m)).toList();
    notifyListeners();
  }

  Future<void> addToCart(Product product) async {
    final existingItem = _cartItems.where((item) => item.productId == product.id).toList();
    if (existingItem.isNotEmpty) {
      await removeFromCart(existingItem.first.id!);
    } else {
      await _dbHelper.insertCart({'productId': product.id, 'quantity': 1});
      await loadCart();
    }
  }

  Future<void> removeFromCart(int id) async {
    await _dbHelper.deleteCartItem(id);
    await loadCart();
  }

  Future<void> clearCart() async {
    await _dbHelper.clearCart();
    await loadCart();
  }

  // --- Orders ---
  Future<void> loadOrders() async {
    var orderMaps = await _dbHelper.getOrders();
    _orders = orderMaps.map((m) => OrderModel.fromMap(m)).toList();
    notifyListeners();
  }

  Future<void> placeOrder() async {
    if (_currentUser == null) return;
    for (var item in _cartItems) {
      await _dbHelper.insertOrder({
        'userId': _currentUser!.id,
        'productId': item.productId,
        'quantity': item.quantity,
        'status': 'Pending',
        'orderDate': DateTime.now().toString(),
      });
    }
    // Notify Admin
    NotificationService.showNotification(
      'Nouvelle Commande - Fixy',
      'Une nouvelle commande a été passée par ${_currentUser!.fullName}.',
    );
    await clearCart();
    await loadOrders();
  }

  Future<void> updateOrderStatus(int id, String status) async {
    await _dbHelper.updateOrderStatus(id, status);
    await loadOrders();
  }
}
