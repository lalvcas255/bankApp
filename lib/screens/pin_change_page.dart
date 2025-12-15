import 'package:flutter/material.dart';
import 'database_helper.dart'; // <--- IMPORTANTE: Conexión a BD

class PinChangePage extends StatefulWidget {
  final String pin;

  const PinChangePage({super.key, required this.pin});

  @override
  State<PinChangePage> createState() => _PinChangePageState();
}

class _PinChangePageState extends State<PinChangePage> {
  final TextEditingController pin1Controller = TextEditingController();
  final TextEditingController pin2Controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Background image
          SizedBox.expand(
            child: Image.asset(
              "assets/atm2.png",
              fit: BoxFit.cover,
            ),
          ),

          /// Título Principal
          const Positioned(
            top: 180,
            left: 430,
            child: Text(
              "CAMBIO DE PIN",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          /// Etiqueta 1: Nuevo PIN
          const Positioned(
            top: 225,
            left: 430,
            child: Text(
              "Nuevo PIN:",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),

          /// Campo 1
          Positioned(
            top: 225,
            left: 600,
            child: SizedBox(
              width: 180,
              child: TextField(
                controller: pin1Controller,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                style: const TextStyle(color: Colors.white, fontSize: 22),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color(0xFF417D80),
                  border: InputBorder.none,
                  counterText: "",
                ),
              ),
            ),
          ),

          /// Etiqueta 2: Confirmar
          const Positioned(
            top: 260,
            left: 430,
            child: Text(
              "Confirmar PIN:",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),

          /// Campo 2
          Positioned(
            top: 260,
            left: 600,
            child: SizedBox(
              width: 180,
              child: TextField(
                controller: pin2Controller,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                style: const TextStyle(color: Colors.white, fontSize: 22),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color(0xFF417D80),
                  border: InputBorder.none,
                  counterText: "",
                ),
              ),
            ),
          ),

          /// Botón CAMBIAR (CHANGE)
          Positioned(
            top: 362,
            left: 700,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF417D80),
                foregroundColor: Colors.white,
                fixedSize: const Size(150, 35),
              ),
              onPressed: changePin,
              child: const Text("CAMBIAR"),
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
  // LÓGICA CAMBIO DE PIN CON BASE DE DATOS
  // ==========================================

  void changePin() async { // <--- ASYNC
    String p1 = pin1Controller.text.trim();
    String p2 = pin2Controller.text.trim();

    // Validaciones básicas
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
      showAlert("El PIN debe contener solo dígitos.");
      return;
    }

    // --- GUARDAR EN BASE DE DATOS ---
    // Actualizamos el PIN antiguo (widget.pin) por el nuevo (p1)
    await DatabaseHelper.instance.updatePin(widget.pin, p1);
    // --------------------------------

    if (!mounted) return;

    showAlert("PIN cambiado correctamente.\nPor favor, inicie sesión de nuevo.", onOk: () {
      // Al cambiar el PIN, la sesión actual ya no es válida.
      // Volvemos a la pantalla de Login (la primera ruta).
      Navigator.popUntil(context, (route) => route.isFirst);
    });
  }

  void showAlert(String message, {VoidCallback? onOk}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Aviso"),
        content: Text(message),
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
    pin1Controller.dispose();
    pin2Controller.dispose();
    super.dispose();
  }
}