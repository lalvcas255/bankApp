import 'package:flutter/material.dart';
import 'database_helper.dart'; 

class DepositPage extends StatefulWidget {
  final String pin;

  const DepositPage({super.key, required this.pin});

  @override
  State<DepositPage> createState() => _DepositPageState();
}

class _DepositPageState extends State<DepositPage> {
  final TextEditingController amountController = TextEditingController();
  bool isProcessing = false; 

  @override
  Widget build(BuildContext context) {
    // Color corporativo
    final Color bankPrimaryColor = Colors.blue.shade900;

    return Scaffold(
      // 1. Fondo sólido azul (sin imagen de fondo para evitar errores visuales)
      backgroundColor: bankPrimaryColor,
      
      // Bloqueamos la pantalla si se está procesando
      body: AbsorbPointer(
        absorbing: isProcessing,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: 500, // Ancho máximo para mantener estética de tarjeta
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
                  /// Icono decorativo
                  Icon(Icons.arrow_circle_down_rounded, size: 60, color: bankPrimaryColor),
                  const SizedBox(height: 15),

                  /// Título
                  Text(
                    "INGRESO DE EFECTIVO",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: bankPrimaryColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Introduzca la cantidad a ingresar en su cuenta",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 30),

                  /// Campo de Entrada (Amount)
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

                  /// Botones de Acción
                  Row(
                    children: [
                      // Botón VOLVER
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            side: const BorderSide(color: Colors.red),
                            foregroundColor: Colors.red,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text("CANCELAR"),
                        ),
                      ),
                      const SizedBox(width: 15),
                      
                      // Botón INGRESAR
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: bankPrimaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: isProcessing ? null : depositMoney,
                          child: isProcessing 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                              : const Text("INGRESAR"),
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

  // --- LÓGICA DE DEPÓSITO ---

  Future<void> depositMoney() async {
    FocusScope.of(context).unfocus();

    String amountText = amountController.text.trim().replaceAll(',', '.');

    if (amountText.isEmpty) {
      showAlert("Por favor, introduzca una cantidad.");
      return;
    }

    double? parsedAmount = double.tryParse(amountText);
    
    if (parsedAmount == null || parsedAmount <= 0) {
      showAlert("Cantidad no válida. Inténtelo de nuevo.");
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      await DatabaseHelper.instance.addTransaction(
        widget.pin, 
        'Deposit', 
        parsedAmount
      );

      if (!mounted) return;

      // Éxito: Usamos un icono verde en la alerta
      showSuccessAlert("${parsedAmount.toStringAsFixed(2)} € ingresados correctamente.");

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

  // Alerta de Error / Aviso
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

  // Alerta de Éxito
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
                Navigator.pop(context); // Vuelve al menú principal
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