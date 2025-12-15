import 'package:flutter/material.dart';

class MiniStatementPage extends StatefulWidget {
  final String pin;

  const MiniStatementPage({super.key, required this.pin});

  @override
  State<MiniStatementPage> createState() => _MiniStatementPageState();
}

class _MiniStatementPageState extends State<MiniStatementPage> {
  String maskedCard = "";
  double balance = 0.0;

  /// Lista de transacciones
  List<Map<String, String>> transactions = [];

  @override
  void initState() {
    super.initState();
    loadMiniStatement();
  }

  // ============================================================
  // CARGAR MOVIMIENTOS
  // ============================================================

  void loadMiniStatement() async {
    // ---------------------------
    // MOCK 1: Obtener número de tarjeta
    // ---------------------------
    String cardNumber = "1234567890123456"; 
    // Enmascarar: 1234XXXXXXXX3456
    maskedCard = "${cardNumber.substring(0, 4)}XXXXXXXX${cardNumber.substring(12)}";

    // ---------------------------
    // MOCK 2: Obtener transacciones
    // ---------------------------
    transactions = [
      {
        "date": "2024-01-12",
        "type": "Deposit",
        "amount": "3000",
      },
      {
        "date": "2024-01-15",
        "type": "Withdrawal",
        "amount": "1000",
      },
      {
        "date": "2024-01-18",
        "type": "Deposit",
        "amount": "1500",
      },
      {
        "date": "2024-01-20",
        "type": "Withdrawal",
        "amount": "250",
      },
    ];

    // ---------------------------
    // Calcular balance
    // ---------------------------
    double bal = 0;
    for (var t in transactions) {
      double amount = double.parse(t["amount"]!);
      if (t["type"] == "Deposit") {
        bal += amount;
      } else {
        bal -= amount;
      }
    }

    setState(() {
      balance = bal;
    });
  }

  // Helper para formatear fecha de YYYY-MM-DD a DD/MM/YYYY
  String formatDate(String isoDate) {
    try {
      var parts = isoDate.split('-');
      if (parts.length == 3) {
        return "${parts[2]}/${parts[1]}/${parts[0]}";
      }
      return isoDate;
    } catch (e) {
      return isoDate;
    }
  }

  // Helper para formatear dinero (1000.0 -> 1.000,00 €) sin librerías
  String formatMoney(String amountStr) {
    double amount = double.parse(amountStr);
    return "${amount.toStringAsFixed(2).replaceAll('.', ',')} €";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFCCCC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              const Center(
                child: Text(
                  "Banco TechCoder S.A.",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Text(
                "Tarjeta: $maskedCard",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

              // ------------------------------
              // TÍTULO TABLA
              // ------------------------------
              const Text(
                "Últimos Movimientos:",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              // ------------------------------
              // LISTA DE MOVIMIENTOS
              // ------------------------------
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: transactions.isEmpty
                      ? const Center(child: Text("No hay movimientos recientes"))
                      : ListView.separated(
                          padding: const EdgeInsets.all(10),
                          itemCount: transactions.length,
                          separatorBuilder: (ctx, i) => const Divider(),
                          itemBuilder: (context, index) {
                            final tr = transactions[index];
                            bool isDeposit = tr["type"] == "Deposit";

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Fecha
                                  Text(
                                    formatDate(tr["date"]!),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),

                                  // Tipo (Ingreso / Retirada)
                                  Text(
                                    isDeposit ? "Ingreso" : "Retirada",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: isDeposit ? Colors.green[700] : Colors.red[700],
                                    ),
                                  ),

                                  // Cantidad
                                  Text(
                                    formatMoney(tr["amount"]!),
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isDeposit ? Colors.black : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // ------------------------------
              // BALANCE TOTAL
              // ------------------------------
              Container(
                padding: const EdgeInsets.all(15),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Saldo Disponible:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      "${balance.toStringAsFixed(2).replaceAll('.', ',')} €",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF417D80),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // BOTÓN SALIR
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    fixedSize: const Size(150, 45),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("SALIR"),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}