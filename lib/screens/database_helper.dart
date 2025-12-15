import 'dart:io'; // Para detectar si es PC
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Para base de datos en PC

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    // --- CONFIGURACIÓN PARA PC (WINDOWS/LINUX) ---
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    // ---------------------------------------------

    _database = await _initDB('bank_final_v4.db'); 
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path, 
      version: 1, 
      onCreate: _createDB,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future _createDB(Database db, int version) async {
    // 1. Tabla de Usuarios
    await db.execute('''
    CREATE TABLE users (
      pin TEXT PRIMARY KEY,
      card_number TEXT,
      balance REAL,
      
      -- Datos Personales
      form_no TEXT,
      name TEXT,
      dob TEXT,
      gender TEXT,
      email TEXT,
      marital_status TEXT,
      address TEXT,
      city TEXT,
      cp TEXT,
      state TEXT,
      
      -- Datos de Cuenta
      account_type TEXT,
      services TEXT
    )
    ''');

    // 2. Tabla de Transacciones
    await db.execute('''
    CREATE TABLE transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      pin TEXT,
      type TEXT,
      amount REAL,
      date TEXT,
      FOREIGN KEY (pin) REFERENCES users (pin) ON DELETE CASCADE ON UPDATE CASCADE
    )
    ''');
  }

  // ============================================================
  // MÉTODOS DE GESTIÓN DE USUARIOS
  // ============================================================

  /// Registro completo de usuario
  Future<void> registerUser({
    required String pin,
    required String card,
    required String formNo,
    required String name,
    required String dob,
    required String gender,
    required String email,
    required String marital,
    required String address,
    required String city,
    required String cp,
    required String state,
    required String accountType,
    required String services,
  }) async {
    final db = await instance.database;
    
    // Verificamos si el PIN ya existe
    final result = await db.query('users', where: 'pin = ?', whereArgs: [pin]);
    
    if (result.isEmpty) {
      await db.insert('users', {
        'pin': pin,
        'card_number': card,
        'balance': 0.0,
        'form_no': formNo,
        'name': name,
        'dob': dob,
        'gender': gender,
        'email': email,
        'marital_status': marital,
        'address': address,
        'city': city,
        'cp': cp,
        'state': state,
        'account_type': accountType,
        'services': services
      });
    } else {
      throw Exception("El PIN ya está registrado. Por favor elija otro.");
    }
  }

  /// Método simple (Legacy)
  Future<void> initUser(String pin, String card) async {
    final db = await instance.database;
    final result = await db.query('users', where: 'pin = ?', whereArgs: [pin]);
    if (result.isEmpty) {
      await db.insert('users', {'pin': pin, 'card_number': card, 'balance': 0.0, 'name': 'Usuario Test'});
    }
  }

  /// NUEVO: Eliminar cuenta validando credenciales
  Future<bool> deleteAccount(String cardNumber, String pin) async {
    final db = await instance.database;
    
    return await db.transaction((txn) async {
      // 1. Verificar credenciales
      final result = await txn.query(
        'users', 
        where: 'card_number = ? AND pin = ?', 
        whereArgs: [cardNumber, pin]
      );

      if (result.isNotEmpty) {
        // 2. Borrar transacciones (Si el ON DELETE CASCADE falla, esto lo asegura)
        await txn.delete('transactions', where: 'pin = ?', whereArgs: [pin]);
        
        // 3. Borrar usuario
        await txn.delete('users', where: 'pin = ?', whereArgs: [pin]);
        return true;
      } else {
        return false; // Credenciales incorrectas
      }
    });
  }

  // ============================================================
  // MÉTODOS OPERATIVOS (CAJERO)
  // ============================================================

  Future<double> getBalance(String pin) async {
    final db = await instance.database;
    final result = await db.query('users', where: 'pin = ?', whereArgs: [pin]);
    if (result.isNotEmpty) {
      return (result.first['balance'] as num).toDouble();
    }
    return 0.0;
  }

  Future<void> addTransaction(String pin, String type, double amount) async {
    final db = await instance.database;
    
    await db.transaction((txn) async {
      await txn.insert('transactions', {
        'pin': pin,
        'type': type,
        'amount': amount,
        'date': DateTime.now().toString(),
      });

      final userResult = await txn.query('users', where: 'pin = ?', whereArgs: [pin]);
      if (userResult.isNotEmpty) {
        double currentBalance = (userResult.first['balance'] as num).toDouble();
        double newBalance = (type == 'Deposit') ? currentBalance + amount : currentBalance - amount;

        await txn.update(
          'users', 
          {'balance': newBalance},
          where: 'pin = ?',
          whereArgs: [pin],
        );
      }
    });
  }

  Future<List<Map<String, dynamic>>> getTransactions(String pin) async {
    final db = await instance.database;
    return await db.query(
      'transactions',
      where: 'pin = ?',
      whereArgs: [pin],
      orderBy: 'id DESC', 
      limit: 10,
    );
  }

  Future<void> updatePin(String oldPin, String newPin) async {
    final db = await instance.database;
    
    await db.transaction((txn) async {
      final userResult = await txn.query('users', where: 'pin = ?', whereArgs: [oldPin]);
      if (userResult.isNotEmpty) {
        var userData = Map<String, dynamic>.from(userResult.first);
        userData['pin'] = newPin;

        await txn.insert('users', userData);

        await txn.update(
          'transactions',
          {'pin': newPin},
          where: 'pin = ?',
          whereArgs: [oldPin],
        );

        await txn.delete('users', where: 'pin = ?', whereArgs: [oldPin]);
      }
    });
  }
}