import 'package:flutter/material.dart';

class BalanceEnquiryPage extends StatefulWidget {
  final String pin;

  const BalanceEnquiryPage({super.key, required this.pin});

  @override
  State<BalanceEnquiryPage> createState() => _BalanceEnquiryPageState();
}

class _BalanceEnquiryPageState extends State<BalanceEnquiryPage> {
  double balance = 0.0;

  @override
  void initState() {
    super.initState();
    loadBalance();
  }

  void loadBalance() async {
    // Simulación de transacciones
    List<Map<String, dynamic>> mockTransactions = [
      {"type": "Deposit", "amount": 3000},
      {"type": "Withdrawal", "amount": 1200},
      {"type": "Deposit", "amount": 1500},
      {"type": "Withdrawal", "amount": 500},
    ];

    double bal = 0;

    for (var t in mockTransactions) {
      if (t["type"] == "Deposit") {
        bal += (t["amount"] as int).toDouble();
      } else {
        bal -= (t["amount"] as int).toDouble();
      }
    }

    setState(() {
      balance = bal;
    });
  }

  @override
  Widget build(BuildContext context) {
    String formattedBalance = "${balance.toStringAsFixed(2).replaceAll('.', ',')} €";

    return Scaffold(
      body: Stack(
        children: [
          /// Fondo ATM
          SizedBox.expand(
            child: Image.asset(
              "assets/atm2.png",
              fit: BoxFit.cover,
            ),
          ),

          /// Etiqueta
          Positioned(
            top: 180,
            left: 430, 
            child: const Text(
              "Su saldo disponible es:",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          /// Cantidad Saldo
          Positioned(
            top: 220,
            left: 430,
            child: Text(
              formattedBalance,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26, 
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          /// Botón Volver
          Positioned(
            top: 406,
            left: 700,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF417D80),
                foregroundColor: Colors.white,
                fixedSize: const Size(150, 35),
              ),
              onPressed: () {
                // Cambiado a Navigator.pop() para volver al menú principal
                Navigator.pop(context);
              },
              child: const Text("VOLVER"),
            ),
          ),
        ],
      ),
    );
  }
}