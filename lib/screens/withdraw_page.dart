import 'package:flutter/material.dart';
import 'database_helper.dart';

class WithdrawPage extends StatefulWidget {
  final String pin;

  const WithdrawPage({super.key, required this.pin});

  @override
  State<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  final TextEditingController amountController = TextEditingController();
  bool isProcessing = false; // Control para evitar doble clic

  @override
  Widget build(BuildContext context) {
    // Color corporativo
    final Color bankPrimaryColor = Colors.blue.shade900;

    return Scaffold(
      // 1. Fondo sólido azul
      backgroundColor: bankPrimaryColor,
      
      body: AbsorbPointer(
        absorbing: isProcessing, // Bloquea la pantalla si está cargando
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: 500, // Ancho máximo de la tarjeta
              padding: const EdgeInsets.all(30),
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Icono decorativo (Flecha hacia arriba = Salida de dinero)
                  Icon(Icons.arrow_circle_up_rounded, size: 60, color: bankPrimaryColor),
                  const SizedBox(height: 15),

                  /// Título
                  Text(
                    "RETIRADA DE EFECTIVO",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: bankPrimaryColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Aviso de límite
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.orange.shade200)
                    ),
                    child: Text(
                      "Límite máximo diario: 10.000 €",
                      style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// Input Field
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: "0.00",
                      suffixText: '€',
                      suffixStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(vertical: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: bankPrimaryColor, width: 2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// Botones
                  Row(
                    children: [
                      // 1. Botón RETIRAR 
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: bankPrimaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: isProcessing ? null : withdrawMoney,
                          child: isProcessing
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text("RETIRAR"),
                        ),
                      ),
                      
                      const SizedBox(width: 15),

                      // 2. Botón CANCELAR 
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            side: const BorderSide(color: Colors.red),
                            foregroundColor: Colors.red,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("CANCELAR"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // LÓGICA DE RETIRADA

  Future<void> withdrawMoney() async {
    FocusScope.of(context).unfocus();

    String text = amountController.text.trim().replaceAll(',', '.');

    if (text.isEmpty) {
      showAlert("Por favor, introduzca la cantidad a retirar.");
      return;
    }

    double? amount = double.tryParse(text);

    if (amount == null || amount <= 0) {
      showAlert("Cantidad no válida.");
      return;
    }

    if (amount > 10000) {
      showAlert("El retiro máximo permitido es de 10.000 €");
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      // 1. Obtener el saldo REAL actual desde la BD
      double currentBalance = await DatabaseHelper.instance.getBalance(widget.pin);

      if (!mounted) return;

      // 2. Verificar si hay fondos suficientes
      if (amount > currentBalance) {
        showAlert("Saldo insuficiente.\n\nSu saldo actual es: ${currentBalance.toStringAsFixed(2)} €");
      } else {
        // 3. Si hay fondos, procedemos con la transacción
        await DatabaseHelper.instance.addTransaction(
          widget.pin, 
          'Withdrawal', 
          amount
        );

        if (!mounted) return;

        showSuccessAlert("Ha retirado ${amount.toStringAsFixed(2)} € correctamente.");
      }

    } catch (e) {
      if (!mounted) return;
      showAlert("Error del sistema: $e");
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  // ALERTAS DE DISEÑO

  void showAlert(String msg) {
    final Color bankPrimaryColor = Colors.blue.shade900;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: bankPrimaryColor, size: 28),
            const SizedBox(width: 10),
            Text("Aviso", style: TextStyle(color: bankPrimaryColor, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(msg, style: TextStyle(color: Colors.grey.shade700, fontSize: 16)),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: bankPrimaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("ENTENDIDO"),
            ),
          )
        ],
      ),
    );
  }

  void showSuccessAlert(String msg) {
    final Color bankPrimaryColor = Colors.blue.shade900;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 50),
            const SizedBox(height: 10),
            Text("Operación Exitosa", style: TextStyle(color: bankPrimaryColor, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(msg, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade700, fontSize: 16)),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: bankPrimaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(context); // Cierra alerta
                Navigator.pop(context); // Vuelve al menú
              },
              child: const Text("ACEPTAR"),
            ),
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