import 'dart:math';
import 'package:flutter/material.dart';
import 'database_helper.dart'; 
import 'deposit_page.dart';    

class Signup3Page extends StatefulWidget {
  final String formNo;

  const Signup3Page({super.key, required this.formNo});

  @override
  State<Signup3Page> createState() => _Signup3PageState();
}

class _Signup3PageState extends State<Signup3Page> {
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
    // Color corporativo (mismo que usamos en las otras pantallas)
    final Color bankPrimaryColor = Colors.blue.shade900;

    return Scaffold(
      backgroundColor: Colors.blueGrey[50], // Fondo suave consistente
      body: Stack(
        children: [
          // Fondo de imagen (opcional, para mantener consistencia)
          SizedBox.expand(
            child: Image.asset(
              "assets/backbg.png",
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300]),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.1)),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: 500,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// Cabecera
                    Center(
                      child: Column(
                        children: [
                          Image.asset(
                            "assets/bank.png",
                            width: 70,
                            height: 70,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "SOLICITUD Nº ${widget.formNo}",
                            style: TextStyle(
                              fontSize: 22,
                              color: bankPrimaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "Paso Final: Datos de la Cuenta",
                            style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // --- SECCIÓN CORREGIDA: TIPO DE CUENTA ---
                    const Text(
                      "Tipo de Cuenta:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    
                    // AQUI ESTÁ EL CAMBIO: Usamos Row para ponerlos en horizontal
                    Row(
                      children: [
                        // Usamos Expanded para que ocupen el mismo espacio
                        Expanded(child: _radio("Cuenta Ahorro")),
                        const SizedBox(width: 10), // Espacio entre opciones
                        Expanded(child: _radio("Cuenta Corriente")),
                      ],
                    ),
                    // Si quieres la tercera opción, puedes ponerla debajo o en la misma fila si cabe
                    // _radio("Depósito Fijo"), 

                    const SizedBox(height: 25),

                    const Text(
                      "Número de Tarjeta:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Text("XXXX-XXXX-XXXX-???? (Automático)", style: TextStyle(fontSize: 14, color: Colors.grey)),
                    
                    const SizedBox(height: 20),

                    const Text(
                      "PIN / Clave:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Text("**** (Se generará al finalizar)", style: TextStyle(fontSize: 14, color: Colors.grey)),

                    const SizedBox(height: 25),

                    const Text(
                      "Servicios Requeridos:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    // Organizamos los checkbox en dos columnas para ahorrar espacio
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              _check("Tarjeta Débito", (v) => setState(() => atm = v)),
                              _check("Banca Online", (v) => setState(() => internet = v)),
                              _check("Banca Móvil", (v) => setState(() => mobile = v)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              _check("Alertas Email", (v) => setState(() => emailAlert = v)),
                              _check("Talonario", (v) => setState(() => cheque = v)),
                              _check("Extracto Digital", (v) => setState(() => eStatement = v)),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Checkbox(value: true, onChanged: null, activeColor: Colors.grey),
                        const Expanded(
                          child: Text(
                            "Declaro que los datos introducidos son correctos.",
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // BOTONES
                    Row(
                      children: [
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
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: bankPrimaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: _submit,
                            child: const Text("FINALIZAR"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------
  // Componentes UI
  // -----------------------------

  Widget _radio(String label) {
    // Quitamos el Row interno para que el Row principal controle la alineación
    return Row(
      mainAxisSize: MainAxisSize.min, // Ocupar solo lo necesario
      children: [
        Radio(
          value: label,
          groupValue: accountType,
          activeColor: Colors.blue.shade900,
          onChanged: (v) => setState(() => accountType = v),
        ),
        // Usamos Flexible para que el texto no rompa el diseño si es muy largo
        Flexible(child: Text(label, style: const TextStyle(fontSize: 14))),
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
        Checkbox(
          value: val, 
          activeColor: Colors.blue.shade900,
          onChanged: (v) => onChanged(v!)
        ),
        Flexible(child: Text(label, style: const TextStyle(fontSize: 13))),
      ],
    );
  }

  // -----------------------------
  // LÓGICA DE REGISTRO
  // -----------------------------

  void _submit() async {
    if (accountType == null) {
      _alert("Por favor, seleccione un tipo de cuenta.");
      return;
    }

    final random = Random();
    String cardNo = "5040"; 
    for (int i = 0; i < 12; i++) {
      cardNo += random.nextInt(10).toString();
    }
    
    String pin = (random.nextInt(9000) + 1000).toString();

    try {
      // AQUÍ DEBERÍAS USAR EL MÉTODO registerUser SI QUIERES GUARDAR TODO EL FORMULARIO
      // Por ahora usamos initUser (simple) como en tu código original
      await DatabaseHelper.instance.initUser(pin, cardNo);
      
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Column(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 50),
              const SizedBox(height: 10),
              Text("¡Bienvenido!", style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Cuenta creada correctamente.", textAlign: TextAlign.center),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    Text("Tarjeta: $cardNo", style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text("PIN: $pin", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 18)),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              const Text("Vamos a realizar su primer ingreso.", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade900,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => DepositPage(pin: pin)),
                    (route) => false,
                  );
                },
                child: const Text("IR A INGRESAR SALDO"),
              ),
            )
          ],
        ),
      );

    } catch (e) {
      _alert("Error de sistema: $e");
    }
  }

  void _alert(String text) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Aviso", style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold)),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ENTENDIDO"),
          )
        ],
      ),
    );
  }
}