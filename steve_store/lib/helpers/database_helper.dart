import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      // Sqflite doesn't support web out of the box. 
      // For a real web app, use sqflite_common_ffi_web or drift.
      throw UnsupportedError("SQLite is not supported on Web with the current configuration. Please run on Android, iOS, or Windows.");
    }

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String path = join(await getDatabasesPath(), 'steve_store.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT,
        username TEXT,
        email TEXT,
        password TEXT,
        profilePhoto TEXT,
        categories TEXT
      )
    ''');

    // Products table
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        price REAL,
        category TEXT
      )
    ''');

    // Product Images table (One-to-Many)
    await db.execute('''
      CREATE TABLE product_images (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER,
        imagePath TEXT,
        FOREIGN KEY (productId) REFERENCES products (id) ON DELETE CASCADE
      )
    ''');

    // Cart table
    await db.execute('''
      CREATE TABLE cart (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER,
        quantity INTEGER,
        FOREIGN KEY (productId) REFERENCES products (id) ON DELETE CASCADE
      )
    ''');

    // Orders table
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        productId INTEGER,
        quantity INTEGER,
        status TEXT,
        orderDate TEXT,
        FOREIGN KEY (userId) REFERENCES users (id),
        FOREIGN KEY (productId) REFERENCES products (id)
      )
    ''');
  }

  // --- User Operations ---
  Future<int> insertUser(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('users', row);
  }

  Future<Map<String, dynamic>?> getUser(String username, String password) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('users',
        where: 'username = ? AND password = ?', whereArgs: [username, password]);
    if (maps.isNotEmpty) return maps.first;
    return null;
  }

  Future<int> updateUser(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.update('users', row, where: 'id = ?', whereArgs: [row['id']]);
  }

  // --- Product Operations ---
  Future<int> insertProduct(Map<String, dynamic> row, List<String> images) async {
    Database db = await database;
    int productId = await db.insert('products', row);
    for (String imagePath in images) {
      await db.insert('product_images', {'productId': productId, 'imagePath': imagePath});
    }
    return productId;
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    Database db = await database;
    List<Map<String, dynamic>> products = await db.query('products');
    List<Map<String, dynamic>> result = [];
    for (var product in products) {
      var prod = Map<String, dynamic>.from(product);
      List<Map<String, dynamic>> images = await db.query('product_images',
          where: 'productId = ?', whereArgs: [product['id']]);
      prod['images'] = images.map((e) => e['imagePath']).toList();
      result.add(prod);
    }
    return result;
  }

  Future<int> deleteProduct(int id) async {
    Database db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateProduct(Map<String, dynamic> row, List<String> images) async {
    Database db = await database;
    int productId = row['id'];
    await db.update('products', row, where: 'id = ?', whereArgs: [productId]);
    await db.delete('product_images', where: 'productId = ?', whereArgs: [productId]);
    for (String imagePath in images) {
      await db.insert('product_images', {'productId': productId, 'imagePath': imagePath});
    }
    return productId;
  }

  // --- Cart Operations ---
  Future<int> insertCart(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('cart', row);
  }

  Future<List<Map<String, dynamic>>> getCartItems() async {
    Database db = await database;
    return await db.rawQuery('''
      SELECT cart.*, products.title, products.price, product_images.imagePath 
      FROM cart 
      JOIN products ON cart.productId = products.id
      LEFT JOIN product_images ON products.id = product_images.productId
      GROUP BY cart.id
    ''');
  }

  Future<int> deleteCartItem(int id) async {
    Database db = await database;
    return await db.delete('cart', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearCart() async {
    Database db = await database;
    await db.delete('cart');
  }

  // --- Order Operations ---
  Future<int> insertOrder(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('orders', row);
  }

  Future<List<Map<String, dynamic>>> getOrders() async {
    Database db = await database;
    return await db.rawQuery('''
      SELECT orders.*, products.title as productTitle, products.price as productPrice, users.fullName 
      FROM orders 
      JOIN products ON orders.productId = products.id
      JOIN users ON orders.userId = users.id
    ''');
  }

  Future<int> updateOrderStatus(int id, String status) async {
    Database db = await database;
    return await db.update('orders', {'status': status}, where: 'id = ?', whereArgs: [id]);
  }
}
