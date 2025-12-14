import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Patrón Singleton
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('bank_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Tabla Usuarios
    await db.execute('''
    CREATE TABLE users (
      pin TEXT PRIMARY KEY,
      card_number TEXT,
      balance REAL
    )
    ''');

    // Tabla Transacciones
    await db.execute('''
    CREATE TABLE transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      pin TEXT,
      type TEXT,
      amount REAL,
      date TEXT
    )
    ''');
  }

  // --- MÉTODOS ---

  // 1. Crear usuario si no existe
  Future<void> initUser(String pin, String card) async {
    final db = await instance.database;
    final result = await db.query('users', where: 'pin = ?', whereArgs: [pin]);
    
    if (result.isEmpty) {
      await db.insert('users', {
        'pin': pin,
        'card_number': card,
        'balance': 0.0,
      });
    }
  }

  // 2. Obtener saldo
  Future<double> getBalance(String pin) async {
    final db = await instance.database;
    final result = await db.query('users', where: 'pin = ?', whereArgs: [pin]);

    if (result.isNotEmpty) {
      return result.first['balance'] as double;
    }
    return 0.0;
  }

  // 3. Añadir transacción
  Future<void> addTransaction(String pin, String type, double amount) async {
    final db = await instance.database;
    
    await db.insert('transactions', {
      'pin': pin,
      'type': type,
      'amount': amount,
      'date': DateTime.now().toString(),
    });

    double currentBalance = await getBalance(pin);
    double newBalance = (type == 'Deposit') 
        ? currentBalance + amount 
        : currentBalance - amount;

    await db.update(
      'users', 
      {'balance': newBalance},
      where: 'pin = ?',
      whereArgs: [pin],
    );
  }

  // 4. Obtener movimientos
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

  // 5. CAMBIAR PIN (ESTA ES LA QUE TE FALTABA)
  Future<int> updatePin(String oldPin, String newPin) async {
    final db = await instance.database;
    
    // Actualizamos el PIN en la tabla de usuarios
    int result = await db.update(
      'users',
      {'pin': newPin},
      where: 'pin = ?',
      whereArgs: [oldPin],
    );

    // Actualizamos el PIN en el historial para no perder los datos
    await db.update(
      'transactions',
      {'pin': newPin},
      where: 'pin = ?',
      whereArgs: [oldPin],
    );

    return result;
  }
}