import 'package:flutter/material.dart';
import 'database_helper.dart';

class FastCashPage extends StatefulWidget {
  final String pin;

  const FastCashPage({super.key, required this.pin});

  @override
  State<FastCashPage> createState() => _FastCashPageState();
}

class _FastCashPageState extends State<FastCashPage> {
  bool isProcessing = false;

  // Cantidades rápidas
  final List<double> quickAmounts = [20, 50, 100, 200, 500, 1000];

  @override
  Widget build(BuildContext context) {
    // Color corporativo
    final Color bankPrimaryColor = Colors.blue.shade900;

    return Scaffold(
      // 1. Fondo sólido azul
      backgroundColor: bankPrimaryColor,

      body: AbsorbPointer(
        absorbing: isProcessing,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: 550, // Un poco más ancho para que quepan bien los botones
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
                  /// Icono decorativo (Rayo o Billete)
                  Icon(Icons.flash_on_rounded, size: 60, color: bankPrimaryColor),
                  const SizedBox(height: 15),

                  /// Título
                  Text(
                    "EFECTIVO RÁPIDO",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: bankPrimaryColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Seleccione una cantidad para retirar al instante",
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 30),

                  /// GRID DE BOTONES DE CANTIDAD
                  Wrap(
                    spacing: 15, // Espacio horizontal entre botones
                    runSpacing: 15, // Espacio vertical entre filas
                    alignment: WrapAlignment.center,
                    children: quickAmounts.map((amount) {
                      return SizedBox(
                        width: 140, // Ancho fijo por botón
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: bankPrimaryColor,
                            foregroundColor: Colors.white,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: isProcessing ? null : () => withdrawQuickCash(amount),
                          child: Text(
                            "${amount.toStringAsFixed(0)} €",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 40),

                  /// Botón VOLVER
                  SizedBox(
                    width: double.infinity,
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

                  // Indicador de carga integrado visualmente (opcional)
                  if (isProcessing)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: CircularProgressIndicator(color: bankPrimaryColor),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // LÓGICA DE RETIRADA
  // ==========================================

  Future<void> withdrawQuickCash(double amount) async {
    setState(() {
      isProcessing = true;
    });

    try {
      // 1. Verificar saldo
      double currentBalance = await DatabaseHelper.instance.getBalance(widget.pin);

      if (!mounted) return;

      if (amount > currentBalance) {
        // Error de saldo
        showAlert("Saldo insuficiente.\n\nSu saldo actual es: ${currentBalance.toStringAsFixed(2)} €");
      } else {
        // 2. Realizar transacción
        await DatabaseHelper.instance.addTransaction(
          widget.pin,
          'Withdrawal', // Usamos Withdrawal para que cuente como retiro
          amount,
        );

        if (!mounted) return;

        // Éxito
        showSuccessAlert("Retirada rápida de ${amount.toStringAsFixed(0)} € realizada con éxito.");
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

  // ==========================================
  // ALERTAS DE DISEÑO
  // ==========================================

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
}