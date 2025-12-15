import 'package:flutter/material.dart';
// 1. Importamos el helper de base de datos
import 'database_helper.dart';

class MiniStatementPage extends StatefulWidget {
  final String pin;

  const MiniStatementPage({super.key, required this.pin});

  @override
  State<MiniStatementPage> createState() => _MiniStatementPageState();
}

class _MiniStatementPageState extends State<MiniStatementPage> {
  String maskedCard = "**** **** **** ****";
  double balance = 0.0;
  bool isLoading = true; 

  /// Lista de transacciones
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    loadMiniStatement();
  }

  // ============================================================
  // CARGAR MOVIMIENTOS
  // ============================================================
  void loadMiniStatement() async {
    try {
      final db = await DatabaseHelper.instance.database;

      // 1. Obtener datos del Usuario
      final userResult = await db.query(
        'users', 
        columns: ['card_number', 'balance'],
        where: 'pin = ?', 
        whereArgs: [widget.pin]
      );

      if (userResult.isNotEmpty) {
        String rawCard = userResult.first['card_number'] as String;
        double currentBalance = (userResult.first['balance'] as num).toDouble();

        // Enmascarar tarjeta
        if (rawCard.length >= 16) {
           maskedCard = "${rawCard.substring(0, 4)} **** **** ${rawCard.substring(12)}";
        } else {
           maskedCard = rawCard; 
        }

        balance = currentBalance;
      }

      // 2. Obtener historial
      final txList = await DatabaseHelper.instance.getTransactions(widget.pin);

      if (mounted) {
        setState(() {
          transactions = txList;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error cargando movimientos: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Helper Fecha
  String formatDate(String isoDate) {
    try {
      String datePart = isoDate.split(' ')[0]; 
      var parts = datePart.split('-');
      if (parts.length == 3) {
        return "${parts[2]}/${parts[1]}/${parts[0]}"; // DD/MM/AAAA
      }
      return datePart;
    } catch (e) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Color corporativo
    final Color bankPrimaryColor = Colors.blue.shade900;

    return Scaffold(
      // 1. FONDO AZUL SÓLIDO
      backgroundColor: bankPrimaryColor,
      
      body: isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.white)) 
        : Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                // 2. TARJETA CENTRAL BLANCA
                width: 500, 
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    
                    /// CABECERA CON LOGO
                    Row(
                      children: [
                        Image.asset(
                          "assets/bank.png", 
                          width: 60, 
                          height: 60,
                          errorBuilder: (c,e,s) => Icon(Icons.account_balance, size: 60, color: bankPrimaryColor),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "MOVIMIENTOS",
                                style: TextStyle(
                                  color: bankPrimaryColor,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Tarjeta: $maskedCard",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    /// TARJETA DE SALDO (GRADIENTE)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [bankPrimaryColor, Colors.blue.shade700],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Saldo Actual",
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "${balance.toStringAsFixed(2)} €",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      "Últimas Transacciones",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),

                    /// LISTA DE MOVIMIENTOS
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: transactions.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.receipt_long, size: 40, color: Colors.grey.shade400),
                                  const SizedBox(height: 10),
                                  Text("No hay movimientos", style: TextStyle(color: Colors.grey.shade500)),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true, // Importante para estar dentro de SingleScrollView
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: transactions.length,
                            separatorBuilder: (c, i) => Divider(height: 1, color: Colors.grey.shade300),
                            itemBuilder: (context, index) {
                              final tr = transactions[index];
                              String type = tr["type"] ?? "";
                              bool isDeposit = type == "Deposit";
                              double amount = (tr["amount"] as num).toDouble();

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isDeposit ? Colors.green.shade50 : Colors.red.shade50,
                                  child: Icon(
                                    isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
                                    color: isDeposit ? Colors.green : Colors.red,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  isDeposit ? "Ingreso" : "Retirada",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                subtitle: Text(
                                  formatDate(tr["date"] ?? ""),
                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                ),
                                trailing: Text(
                                  "${isDeposit ? '+' : '-'} ${amount.toStringAsFixed(2)} €",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDeposit ? Colors.green.shade700 : Colors.red.shade700,
                                    fontSize: 15,
                                  ),
                                ),
                              );
                            },
                          ),
                    ),

                    const SizedBox(height: 25),

                    /// BOTÓN VOLVER
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: BorderSide(color: bankPrimaryColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text("VOLVER", style: TextStyle(color: bankPrimaryColor, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}