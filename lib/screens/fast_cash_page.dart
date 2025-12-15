import 'package:flutter/material.dart';

class WithdrawPage extends StatefulWidget {
  final String pin;

  const WithdrawPage({super.key, required this.pin});

  @override
  State<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  final TextEditingController amountController = TextEditingController();

  // Balance simulado en Euros
  int mockBalance = 50000; 
  // ⚠️ IMPORTANTE:
  // En producción, esto debe venir de tu base de datos (MySQL/Firebase).

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Background
          SizedBox.expand(
            child: Image.asset(
              "assets/atm2.png",
              fit: BoxFit.cover,
            ),
          ),

          /// Foreground content
          const Positioned(
            top: 180,
            left: 460,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "LÍMITE MÁXIMO DE RETIRADA: 10.000 €",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  "POR FAVOR, INTRODUZCA LA CANTIDAD",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          /// Input Field
          Positioned(
            top: 260,
            left: 460,
            child: SizedBox(
              width: 320,
              child: TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 22),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color(0xFF417D80),
                  border: InputBorder.none,
                  hintText: "Cantidad",
                  hintStyle: TextStyle(color: Colors.white70),
                  suffixText: '€',
                  suffixStyle: TextStyle(color: Colors.white, fontSize: 22),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
              ),
            ),
          ),

          /// Buttons
          // Botón RETIRAR
          Positioned(
            top: 362,
            left: 700,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF417D80),
                foregroundColor: Colors.white,
                fixedSize: const Size(150, 35),
              ),
              onPressed: withdrawMoney,
              child: const Text("RETIRAR"),
            ),
          ),

          // Botón VOLVER
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
                // Cambiado a Navigator.pop()
                Navigator.pop(context);
              },
              child: const Text("VOLVER"),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // LÓGICA DE RETIRADA
  // ==========================================

  void withdrawMoney() {
    String text = amountController.text.trim();

    if (text.isEmpty) {
      alert("Por favor, introduzca la cantidad a retirar.");
      return;
    }

    int amount = int.tryParse(text) ?? 0;

    if (amount <= 0) {
      alert("Cantidad no válida.");
      return;
    }

    if (amount > 10000) {
      alert("El retiro máximo permitido es de 10.000 €");
      return;
    }

    if (amount > mockBalance) {
      alert("Saldo insuficiente.");
      return;
    }

    // Simulación de retirada
    // UPDATE bank SET balance = balance - amount WHERE pin = ...
    setState(() {
      mockBalance -= amount;
    });

    alert("Retirada de $amount € realizada con éxito.", onOk: () {
      // Cambiado a Navigator.pop()
      Navigator.pop(context);
    });
  }

  // ==========================================
  // Alert Dialog
  // ==========================================

  void alert(String msg, {VoidCallback? onOk}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Aviso"),
        content: Text(msg),
        actions: [
          TextButton(
            child: const Text("ACEPTAR"),
            onPressed: () {
              Navigator.pop(context);
              if (onOk != null) onOk();
            },
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }
}