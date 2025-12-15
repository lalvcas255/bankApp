import 'package:flutter/material.dart';

class DepositPage extends StatefulWidget {
  final String pin;

  const DepositPage({super.key, required this.pin});

  @override
  State<DepositPage> createState() => _DepositPageState();
}

class _DepositPageState extends State<DepositPage> {
  final TextEditingController amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Background ATM
          SizedBox.expand(
            child: Image.asset(
              "assets/atm2.png",
              fit: BoxFit.cover,
            ),
          ),

          /// Título
          const Positioned(
            top: 180,
            left: 460,
            child: Text(
              "INTRODUZCA LA CANTIDAD A INGRESAR",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          /// Campo de Entrada (Amount)
          Positioned(
            top: 230,
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
                  suffixText: '€', 
                  suffixStyle: TextStyle(color: Colors.white, fontSize: 22),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
              ),
            ),
          ),

          /// Botón INGRESAR (DEPOSIT)
          Positioned(
            top: 362,
            left: 700,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF417D80),
                foregroundColor: Colors.white,
                fixedSize: const Size(150, 35),
              ),
              onPressed: depositMoney,
              child: const Text("INGRESAR"),
            ),
          ),

          /// Botón VOLVER (BACK)
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

  // Lógica de Depósito

  void depositMoney() {
    String amount = amountController.text.trim();

    if (amount.isEmpty) {
      showAlert("Por favor, introduzca la cantidad a ingresar.");
      return;
    }

    // Validar que sea un número válido
    double? parsedAmount = double.tryParse(amount);
    if (parsedAmount == null || parsedAmount <= 0) {
      showAlert("Por favor, introduzca una cantidad válida.");
      return;
    }

    // Lógica de base de datos simulada
    // INSERT INTO bank ...

    showAlert("$amount € Ingresados Correctamente", onOk: () {
      // Cambiado a Navigator.pop()
      Navigator.pop(context);
    });
  }

 // Mensaje

  void showAlert(String msg, {VoidCallback? onOk}) {
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
              Navigator.pop(context); // Cierra el diálogo
              if (onOk != null) onOk(); // Ejecuta acción extra si existe
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