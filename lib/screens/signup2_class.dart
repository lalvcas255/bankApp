import 'dart:math';
import 'package:flutter/material.dart';
import 'database_helper.dart'; // <--- IMPORTANTE: Conexión a BD
import 'deposit_page.dart';    // Para ir al ingreso inicial al terminar

class Signup2Page extends StatefulWidget {
  final String formNo;

  const Signup2Page({super.key, required this.formNo});

  @override
  State<Signup2Page> createState() => _Signup2PageState();
}

class _Signup2PageState extends State<Signup2Page> {
  // Tipo de Cuenta
  String? accountType;

  // Servicios
  bool atm = false;
  bool internet = false;
  bool mobile = false;
  bool emailAlert = false;
  bool cheque = false;
  bool eStatement = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD7FCFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Cabecera
            Row(
              children: [
                Image.asset(
                  "assets/bank.png",
                  width: 100,
                  height: 100,
                ),
                const SizedBox(width: 30),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Paso Final:",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Datos de la Cuenta",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            Align(
              alignment: Alignment.centerRight,
              child: Text("Solicitud Nº: ${widget.formNo}", style: const TextStyle(fontWeight: FontWeight.bold)),
            ),

            const SizedBox(height: 30),

            const Text("Tipo de Cuenta:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _radio("Cuenta Ahorro"),
            _radio("Depósito Fijo"),
            _radio("Cuenta Corriente"),
            _radio("Depósito Recurrente"),

            const SizedBox(height: 25),

            const Text("Número de Tarjeta:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("(Se generará automáticamente)", style: TextStyle(fontSize: 12)),
            const SizedBox(height: 5),
            const Text("XXXX-XXXX-XXXX-????", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            const SizedBox(height: 25),

            const Text("PIN / Clave:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("????", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("(4 dígitos)", style: TextStyle(fontSize: 12)),

            const SizedBox(height: 25),

            const Text("Servicios Requeridos:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _check("Tarjeta Débito", (v) => setState(() => atm = v)),
            _check("Banca Online", (v) => setState(() => internet = v)),
            _check("Banca Móvil", (v) => setState(() => mobile = v)),
            _check("Alertas Email", (v) => setState(() => emailAlert = v)),
            _check("Talonario", (v) => setState(() => cheque = v)),
            _check("Extracto Digital", (v) => setState(() => eStatement = v)),

            const SizedBox(height: 20),

            Row(
              children: [
                const Checkbox(value: true, onChanged: null),
                const Expanded(
                  child: Text(
                    "Declaro que los datos son correctos.",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // BOTONES
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      fixedSize: const Size(120, 40)
                  ),
                  onPressed: _submit,
                  child: const Text("FINALIZAR"),
                ),
                const SizedBox(width: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      fixedSize: const Size(120, 40)
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("CANCELAR"),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // -----------------------------
  // Componentes UI
  // -----------------------------

  Widget _radio(String label) {
    return Row(
      children: [
        Radio(value: label, groupValue: accountType, onChanged: (v) => setState(() => accountType = v)),
        Text(label),
      ],
    );
  }

  Widget _check(String label, Function(bool) onChanged) {
    bool val = false;
    if (label == "Tarjeta Débito") val = atm;
    else if (label == "Banca Online") val = internet;
    else if (label == "Banca Móvil") val = mobile;
    else if (label == "Alertas Email") val = emailAlert;
    else if (label == "Talonario") val = cheque;
    else if (label == "Extracto Digital") val = eStatement;

    return Row(
      children: [
        Checkbox(value: val, onChanged: (v) => onChanged(v!)),
        Text(label),
      ],
    );
  }

  // -----------------------------
  // LÓGICA FINAL DE REGISTRO
  // -----------------------------

  void _submit() async { // <--- ASYNC
    if (accountType == null) {
      _alert("Por favor, seleccione un tipo de cuenta.");
      return;
    }

    // 1. Generar número de tarjeta y PIN aleatorios
    final random = Random();
    // Genera un número de 16 dígitos que empieza por 5040
    String cardNo = "5040" + (random.nextInt(90000000) + 10000000).toString() + (random.nextInt(9000) + 1000).toString();
    String pin = (random.nextInt(9000) + 1000).toString();

    // 2. GUARDAR EN BASE DE DATOS SQLITE
    // Esto crea el usuario real para que puedas hacer login después
    await DatabaseHelper.instance.initUser(pin, cardNo);

    if (!mounted) return;

    // 3. Mostrar credenciales y navegar
    _alert(
      "Cuenta creada con éxito.\n\n"
      "Tarjeta: $cardNo\n"
      "PIN: $pin\n\n"
      "Anote estos datos para entrar.",
      onOk: () {
        // Al dar OK, vamos a la pantalla de Depósito para ingresar el primer dinero
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DepositPage(pin: pin)),
        );
      }
    );
  }

  void _alert(String text, {VoidCallback? onOk}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Información"),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onOk != null) onOk();
            },
            child: const Text("ACEPTAR"),
          )
        ],
      ),
    );
  }
}