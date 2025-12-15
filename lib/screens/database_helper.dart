import 'dart:io'; // Necesario para detectar si es PC
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Necesario para base de datos en PC

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    // --- 1. CONFIGURACIÓN PARA PC (LINUX / WINDOWS) ---
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    // --------------------------------------------------

    // Cambiamos el nombre para asegurar una base de datos limpia con la nueva estructura
    _database = await _initDB('bank_final_v3.db'); 
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
        // Activar claves foráneas
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future _createDB(Database db, int version) async {
    // --- TABLA ÚNICA DE USUARIOS ---
    // Aquí guardamos TODO: Login, Saldo y Datos Personales
    await db.execute('''
    CREATE TABLE users (
      -- Credenciales (Clave Primaria)
      pin TEXT PRIMARY KEY,
      card_number TEXT,
      balance REAL,
      
      -- Datos del Registro (Paso 1)
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

      -- Datos de la Cuenta (Paso 2)
      account_type TEXT,
      services TEXT -- Guardaremos los servicios como texto separado por comas
    )
    ''');

    // --- TABLA DE TRANSACCIONES ---
    await db.execute('''
    CREATE TABLE transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      pin TEXT,
      type TEXT, -- 'Deposit' o 'Withdrawal'
      amount REAL,
      date TEXT,
      FOREIGN KEY (pin) REFERENCES users (pin) ON DELETE CASCADE ON UPDATE CASCADE
    )
    ''');
  }

  // ============================================================
  // MÉTODOS DE GESTIÓN DE USUARIOS
  // ============================================================

  /// REGISTRO COMPLETO: Guarda todos los datos de golpe al finalizar el Paso 2
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
    required String services, // Ej: "ATM, Mobile, Internet"
  }) async {
    final db = await instance.database;
    
    // Verificamos si el PIN ya existe para evitar errores
    final result = await db.query('users', where: 'pin = ?', whereArgs: [pin]);
    
    if (result.isEmpty) {
      await db.insert('users', {
        'pin': pin,
        'card_number': card,
        'balance': 0.0, // Saldo inicial 0
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

  /// Método simple para crear usuario solo con tarjeta y PIN (Útil para pruebas rápidas)
  Future<void> initUser(String pin, String card) async {
    final db = await instance.database;
    final result = await db.query('users', where: 'pin = ?', whereArgs: [pin]);
    
    if (result.isEmpty) {
      // Insertamos con datos vacíos en los campos opcionales para que no falle
      await db.insert('users', {
        'pin': pin,
        'card_number': card,
        'balance': 0.0,
        'name': 'Usuario Pruebas'
      });
    }
  }

  // ============================================================
  // MÉTODOS OPERATIVOS (CAJERO)
  // ============================================================

  /// Obtener Saldo
  Future<double> getBalance(String pin) async {
    final db = await instance.database;
    final result = await db.query('users', where: 'pin = ?', whereArgs: [pin]);

    if (result.isNotEmpty) {
      return (result.first['balance'] as num).toDouble();
    }
    return 0.0;
  }

  /// Realizar Transacción (Ingreso o Retiro)
  Future<void> addTransaction(String pin, String type, double amount) async {
    final db = await instance.database;
    
    // Usamos transacción para asegurar que si falla algo, no se descuadre el dinero
    await db.transaction((txn) async {
      // 1. Registrar el movimiento en el historial
      await txn.insert('transactions', {
        'pin': pin,
        'type': type,
        'amount': amount,
        'date': DateTime.now().toString(),
      });

      // 2. Actualizar el saldo del usuario
      final userResult = await txn.query('users', where: 'pin = ?', whereArgs: [pin]);
      if (userResult.isNotEmpty) {
        double currentBalance = (userResult.first['balance'] as num).toDouble();
        
        double newBalance = (type == 'Deposit') 
            ? currentBalance + amount 
            : currentBalance - amount;

        await txn.update(
          'users', 
          {'balance': newBalance},
          where: 'pin = ?',
          whereArgs: [pin],
        );
      }
    });
  }

  /// Obtener Historial de Movimientos (Últimos 10)
  Future<List<Map<String, dynamic>>> getTransactions(String pin) async {
    final db = await instance.database;
    return await db.query(
      'transactions',
      where: 'pin = ?',
      whereArgs: [pin],
      orderBy: 'id DESC', // Del más nuevo al más antiguo
      limit: 10,
    );
  }

  /// Cambiar PIN
  Future<void> updatePin(String oldPin, String newPin) async {
    final db = await instance.database;
    
    await db.transaction((txn) async {
      // Copiamos el usuario con el nuevo PIN
      final userResult = await txn.query('users', where: 'pin = ?', whereArgs: [oldPin]);
      if (userResult.isNotEmpty) {
        var userData = Map<String, dynamic>.from(userResult.first);
        userData['pin'] = newPin; // Cambiamos solo el PIN

        // Insertamos nuevo registro
        await txn.insert('users', userData);

        // Actualizamos las transacciones para que apunten al nuevo PIN
        await txn.update(
          'transactions',
          {'pin': newPin},
          where: 'pin = ?',
          whereArgs: [oldPin],
        );

        // Borramos el registro viejo
        await txn.delete('users', where: 'pin = ?', whereArgs: [oldPin]);
      }
    });
  }
}