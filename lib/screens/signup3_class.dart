import 'dart:math';
import 'package:flutter/material.dart';
import 'database_helper.dart'; // <--- IMPORTANTE: Para guardar el usuario
import 'deposit_page.dart';    // Para ir al ingreso inicial

class Signup3Page extends StatefulWidget {
  final String formNo;

  const Signup3Page({super.key, required this.formNo});

  @override
  State<Signup3Page> createState() => _Signup2PageState();
}

class _Signup2PageState extends State<Signup3Page> {
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

            /// Cabecera + Imagen
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
                        "Pág. 3:",
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
            
            // Número de formulario alineado a la derecha
            Align(
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("Solicitud Nº:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(widget.formNo, style: const TextStyle(fontWeight: FontWeight.bold))
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Tipo de Cuenta:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            _radio("Cuenta Ahorro"),
            _radio("Depósito Fijo"),
            _radio("Cuenta Corriente"),
            _radio("Depósito Recurrente"),

            const SizedBox(height: 25),

            const Text(
              "Número de Tarjeta:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text("(Generado automáticamente)", style: TextStyle(fontSize: 12)),
            const SizedBox(height: 5),
            const Text("XXXX-XXXX-XXXX-4184",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("(Aparecerá en su tarjeta y extractos)",
                style: TextStyle(fontSize: 12)),

            const SizedBox(height: 25),

            const Text(
              "PIN / Clave:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text("XXXX", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("(Clave de 4 dígitos)", style: TextStyle(fontSize: 12)),

            const SizedBox(height: 25),

            const Text(
              "Servicios Requeridos:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

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
                    "Declaro que los datos introducidos son correctos según mi leal saber y entender.",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

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
        Radio(
          value: label,
          groupValue: accountType,
          onChanged: (v) => setState(() => accountType = v),
        ),
        Text(label),
      ],
    );
  }

  Widget _check(String label, Function(bool) onChanged) {
    // Mapeo manual para saber qué variable booleana usar
    bool val = false;
    if (label == "Tarjeta Débito") val = atm;
    else if (label == "Banca Online") val = internet;
    else if (label == "Banca Móvil") val = mobile;
    else if (label == "Alertas Email") val = emailAlert;
    else if (label == "Talonario") val = cheque;
    else if (label == "Extracto Digital") val = eStatement;

    return Row(
      children: [
        Checkbox(
          value: val,
          onChanged: (v) => onChanged(v!),
        ),
        Text(label),
      ],
    );
  }

  // -----------------------------
  // LÓGICA DE REGISTRO
  // -----------------------------

  void _submit() async { // <--- ASYNC AÑADIDO
    if (accountType == null) {
      _alert("Por favor, seleccione un tipo de cuenta.");
      return;
    }

    // 1. Generar Tarjeta y PIN
    final random = Random();
    String cardNo = (random.nextInt(90000000) + 1409963000000000).toString();
    String pin = (random.nextInt(9000) + 1000).toString();

    // 2. GUARDAR EN BASE DE DATOS
    // Esto crea el usuario real en SQLite con saldo 0
    await DatabaseHelper.instance.initUser(pin, cardNo);

    // 3. Recopilar servicios (solo para mostrar)
    List<String> activeServices = [];
    if (atm) activeServices.add("Tarjeta Débito");
    if (internet) activeServices.add("Banca Online");
    if (mobile) activeServices.add("Banca Móvil");
    if (emailAlert) activeServices.add("Alertas Email");
    if (cheque) activeServices.add("Talonario");
    if (eStatement) activeServices.add("Extracto Digital");

    String servicesSummary = activeServices.isEmpty 
        ? "Ninguno" 
        : activeServices.join(", ");

    if (!mounted) return;

    // 4. Mostrar credenciales y navegar
    _alert(
      "Cuenta creada con éxito.\n\n"
      "Tarjeta: $cardNo\n"
      "PIN: $pin\n"
      "Servicios: $servicesSummary\n\n"
      "Anote estos datos para entrar.",
      onOk: () {
        // Redirigimos a DepositPage para que haga su primer ingreso
        // O podrías mandarlo al Login si prefieres.
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