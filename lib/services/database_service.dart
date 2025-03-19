import 'dart:io';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi; // Alias for sqflite_common_ffi
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/product_model.dart';
import '../models/transaction_model.dart'; // Uses your Transaction class
import '../models/user_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static sqflite.Database? _database;

  Future<sqflite.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<sqflite.Database> _initDatabase() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, 'ukay_ukay.db');
      debugPrint('Database path: $path');

      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        // Desktop: Use sqflite_common_ffi with alias
        return await ffi.databaseFactoryFfi.openDatabase(
          path,
          options: ffi.OpenDatabaseOptions(
            version: 1,
            onCreate: _onCreate,
          ),
        );
      } else {
        // Android/iOS: Use sqflite natively
        return await sqflite.openDatabase(
          path,
          version: 1,
          onCreate: _onCreate,
        );
      }
    } catch (e) {
      debugPrint('Database initialization error: $e');
      rethrow;
    }
  }

  Future<void> _onCreate(sqflite.Database db, int version) async {
    debugPrint('Creating database tables...');
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        password TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        stock INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT NOT NULL,
        total REAL NOT NULL,
        payment_method TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE transaction_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cash_enabled INTEGER NOT NULL DEFAULT 1,
        card_enabled INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.insert('users', {'username': 'admin', 'password': 'admin123'});
    await db.insert('products', {'name': 'Shirt', 'price': 50.0, 'stock': 10});
    await db.insert('products', {'name': 'Pants', 'price': 100.0, 'stock': 5});
    await db.insert('settings', {'cash_enabled': 1, 'card_enabled': 0});
    debugPrint('Database initialized with default data');
  }

  Future<void> init() async {
    await database; // Ensure database is initialized
  }

  Future<List<User>> login(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.map((map) => User.fromMap(map)).toList();
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final result = await db.query('products');
    return result.map((map) => Product.fromMap(map)).toList();
  }

  Future<void> insertProduct(String name, double price, int stock) async {
    if (name.isEmpty || price < 0 || stock < 0) {
      throw Exception('Invalid product data: name must not be empty, price and stock must be non-negative');
    }
    final db = await database;
    await db.insert('products', {'name': name, 'price': price, 'stock': stock});
  }

  Future<void> updateProduct(int id, String name, double price, int stock) async {
    if (name.isEmpty || price < 0 || stock < 0) {
      throw Exception('Invalid product data: name must not be empty, price and stock must be non-negative');
    }
    final db = await database;
    final rowsAffected = await db.update(
      'products',
      {'name': name, 'price': price, 'stock': stock},
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rowsAffected == 0) {
      throw Exception('Product with ID $id not found');
    }
  }

  Future<void> deleteProduct(int id) async {
    final db = await database;
    final rowsAffected = await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rowsAffected == 0) {
      throw Exception('Product with ID $id not found');
    }
  }

  Future<void> updateProductStock(int productId, int newStock) async {
    if (newStock < 0) {
      throw Exception('Stock cannot be negative');
    }
    final db = await database;
    final rowsAffected = await db.update(
      'products',
      {'stock': newStock},
      where: 'id = ?',
      whereArgs: [productId],
    );
    if (rowsAffected == 0) {
      throw Exception('Product with ID $productId not found');
    }
  }

  Future<Map<String, dynamic>> insertTransaction(
      double total,
      String paymentMethod,
      List<Map<String, dynamic>> cartItems) async {
    if (total < 0 || paymentMethod.isEmpty || cartItems.isEmpty) {
      throw Exception('Invalid transaction data: total must be non-negative, payment method and cart required');
    }

    final db = await database;
    return await db.transaction((txn) async {
      final transactionId = await txn.insert('transactions', {
        'timestamp': DateTime.now().toIso8601String(),
        'total': total,
        'payment_method': paymentMethod,
      });

      for (var item in cartItems) {
        final product = item['product'] as Product;
        final quantity = item['quantity'] as int;
        await txn.insert('transaction_items', {
          'transaction_id': transactionId,
          'product_id': product.id,
          'quantity': quantity,
          'price': product.price,
        });
        await txn.update(
          'products',
          {'stock': product.stock - quantity},
          where: 'id = ?',
          whereArgs: [product.id],
        );
      }

      return {
        'transactionId': transactionId,
        'total': total,
        'cart': cartItems,
        'paymentMethod': paymentMethod,
      };
    });
  }

  Future<List<Transaction>> getTransactions() async {
    final db = await database;
    final result = await db.query('transactions');
    return result.map((map) => Transaction.fromMap(map)).toList();
  }

  Future<List<Transaction>> getTransactionsByPeriod(DateTime start, DateTime end) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'timestamp >= ? AND timestamp <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
    );
    return result.map((map) => Transaction.fromMap(map)).toList();
  }

  Future<List<Map<String, dynamic>>> getTopSellingProducts([DateTime? start, DateTime? end]) async {
    final db = await database;
    String query = '''
      SELECT p.name, SUM(ti.quantity) as quantity, SUM(ti.quantity * ti.price) as total_sales
      FROM transaction_items ti
      JOIN products p ON ti.product_id = p.id
      JOIN transactions t ON ti.transaction_id = t.id
    ''';
    List<Object?>? whereArgs;
    if (start != null && end != null) {
      query += ' WHERE t.timestamp >= ? AND t.timestamp <= ?';
      whereArgs = [start.toIso8601String(), end.toIso8601String()];
    }
    query += ' GROUP BY p.id, p.name ORDER BY total_sales DESC LIMIT 5';
    final result = await db.rawQuery(query, whereArgs);
    return result;
  }

  Future<Map<String, dynamic>> getSettings() async {
    final db = await database;
    final result = await db.query('settings', limit: 1);
    if (result.isEmpty) {
      await db.insert('settings', {'cash_enabled': 1, 'card_enabled': 0});
      return {'cash_enabled': 1, 'card_enabled': 0};
    }
    return result.first;
  }

  Future<void> updateSettings(bool cashEnabled, bool cardEnabled) async {
    final db = await database;
    final existingSettings = await db.query('settings', limit: 1);
    final data = {
      'cash_enabled': cashEnabled ? 1 : 0,
      'card_enabled': cardEnabled ? 1 : 0,
    };
    if (existingSettings.isEmpty) {
      await db.insert('settings', data);
    } else {
      final rowsAffected = await db.update(
        'settings',
        data,
        where: 'id = ?',
        whereArgs: [existingSettings.first['id']],
      );
      if (rowsAffected == 0) {
        throw Exception('Failed to update settings');
      }
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}