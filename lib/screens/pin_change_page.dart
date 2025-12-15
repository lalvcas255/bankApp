import 'package:flutter/material.dart';
import 'database_helper.dart';

class PinChangePage extends StatefulWidget {
  final String pin;

  const PinChangePage({super.key, required this.pin});

  @override
  State<PinChangePage> createState() => _PinChangePageState();
}

class _PinChangePageState extends State<PinChangePage> {
  final TextEditingController pin1Controller = TextEditingController();
  final TextEditingController pin2Controller = TextEditingController();
  
  bool isProcessing = false; // Para evitar doble clic

  @override
  Widget build(BuildContext context) {
    // Color corporativo
    final Color bankPrimaryColor = Colors.blue.shade900;

    return Scaffold(
      // 1. FONDO SÓLIDO AZUL
      backgroundColor: bankPrimaryColor,
      
      // Bloqueamos la interacción mientras se guarda
      body: AbsorbPointer(
        absorbing: isProcessing,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              // 2. TARJETA BLANCA CENTRAL
              width: 450,
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
                  
                  /// CABECERA
                  Image.asset(
                    "assets/bank.png",
                    width: 70,
                    height: 70,
                    errorBuilder: (c, e, s) => Icon(Icons.lock_reset, size: 70, color: bankPrimaryColor),
                  ),
                  const SizedBox(height: 15),
                  
                  Text(
                    "CAMBIO DE PIN",
                    style: TextStyle(
                      color: bankPrimaryColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Por seguridad, no comparta su clave",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),

                  const SizedBox(height: 30),

                  /// CAMPO 1: NUEVO PIN
                  TextField(
                    controller: pin1Controller,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    decoration: _inputDecoration("Nuevo PIN").copyWith(
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// CAMPO 2: CONFIRMAR PIN
                  TextField(
                    controller: pin2Controller,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    decoration: _inputDecoration("Confirmar Nuevo PIN").copyWith(
                      prefixIcon: const Icon(Icons.lock_reset),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// BOTONES DE ACCIÓN
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
                      
                      // Botón CAMBIAR
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: bankPrimaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: changePin,
                          child: isProcessing 
                             ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                             : const Text("CONFIRMAR"),
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

  // Helper para el estilo de los inputs
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade50,
      counterText: "", // Oculta el contador 0/4
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.blue.shade900, width: 2)),
    );
  }

  // ==========================================
  // LÓGICA DE CAMBIO DE PIN
  // ==========================================

  void changePin() async {
    FocusScope.of(context).unfocus();

    String p1 = pin1Controller.text.trim();
    String p2 = pin2Controller.text.trim();

    // Validaciones
    if (p1.isEmpty || p2.isEmpty) {
      showAlert("Por favor, rellene ambos campos.");
      return;
    }

    if (p1 != p2) {
      showAlert("Los PINs introducidos no coinciden.");
      return;
    }
    
    if (p1.length != 4) {
       showAlert("El PIN debe tener 4 dígitos.");
       return;
    }

    if (int.tryParse(p1) == null) {
      showAlert("El PIN debe contener solo números.");
      return;
    }

    if (p1 == widget.pin) {
      showAlert("El nuevo PIN no puede ser igual al actual.");
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      // Actualizar en BD
      await DatabaseHelper.instance.updatePin(widget.pin, p1);
      
      if (!mounted) return;

      // ÉXITO
      showSuccessAlert();

    } catch (e) {
      if (!mounted) return;
      if (e.toString().contains("UNIQUE constraint failed") || e.toString().contains("PRIMARY KEY")) {
        showAlert("Este PIN no está disponible. Por favor elija otro.");
      } else {
        showAlert("Error al cambiar el PIN: $e");
      }
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  // Alerta de Éxito
  void showSuccessAlert() {
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
            Text("¡PIN Actualizado!", style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          "Su clave ha sido modificada correctamente.\nPor seguridad, debe iniciar sesión de nuevo.",
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade900,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                // Volver al Login limpiando pila
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text("IR AL INICIO DE SESIÓN"),
            ),
          )
        ],
      ),
    );
  }

  // Alerta de Error Generico
  void showAlert(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.blue.shade900),
            const SizedBox(width: 10),
            Text("Aviso", style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("ENTENDIDO"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    pin1Controller.dispose();
    pin2Controller.dispose();
    super.dispose();
  }
}