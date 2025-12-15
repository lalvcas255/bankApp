import 'package:flutter/material.dart';
import 'database_helper.dart'; 
import 'login_page.dart';

class Signup2Page extends StatefulWidget {
  // Recibir todos los datos de la Página 1
  final String formNo;
  final String name;
  final String dob;
  final String gender;
  final String email;
  final String marital;
  final String address;
  final String city;
  final String cp;
  final String state;

  const Signup2Page({
    super.key, 
    required this.formNo,
    required this.name,
    required this.dob,
    required this.gender,
    required this.email,
    required this.marital,
    required this.address,
    required this.city,
    required this.cp,
    required this.state,
  });

  @override
  State<Signup2Page> createState() => _Signup2PageState();
}

class _Signup2PageState extends State<Signup2Page> {
  final TextEditingController cardController = TextEditingController();
  final TextEditingController pinController = TextEditingController();

  String? accountType;
  bool isDeclared = false;
  
  // Servicios (solo visuales por ahora, se guardarán como texto)
  bool atm = false;
  bool internet = false;
  bool mobile = false;
  bool emailAlert = false;
  bool cheque = false;
  bool eStatement = false;

  @override
  Widget build(BuildContext context) {
    final Color bankPrimaryColor = Colors.blue.shade900;

    return Scaffold(
      backgroundColor: bankPrimaryColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 10))]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(child: Column(children: [Image.asset("assets/bank.png", width: 70, height: 70), const SizedBox(height: 10), Text("SOLICITUD Nº ${widget.formNo}", style: TextStyle(fontSize: 22, color: bankPrimaryColor, fontWeight: FontWeight.bold)), const SizedBox(height: 5), const Text("Pág. 2: Detalles de la Cuenta", style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold))])),
                const SizedBox(height: 25),

                _title("Tipo de Cuenta:"),
                Row(children: [_radio("Ahorro"), const SizedBox(width: 20), _radio("Corriente")]),
                const SizedBox(height: 20),

                _title("Nº Tarjeta (16 dígitos):"),
                TextField(controller: cardController, maxLength: 16, keyboardType: TextInputType.number, decoration: _dec("Ej. 1234567812345678", Icons.credit_card)),
                const SizedBox(height: 15),

                _title("PIN (4 dígitos):"),
                TextField(controller: pinController, maxLength: 4, obscureText: true, keyboardType: TextInputType.number, decoration: _dec("****", Icons.lock)),
                const SizedBox(height: 20),

                _title("Servicios:"),
                Column(children: [_chk("Tarjeta Débito", (v)=>atm=v), _chk("Banca Online", (v)=>internet=v), _chk("Banca Móvil", (v)=>mobile=v), _chk("Alertas Email", (v)=>emailAlert=v), _chk("Talonario", (v)=>cheque=v), _chk("Extracto Digital", (v)=>eStatement=v)]),
                
                const SizedBox(height: 20),
                const Divider(),
                Row(children: [Checkbox(value: isDeclared, activeColor: bankPrimaryColor, onChanged: (v) => setState(() => isDeclared = v!)), const Expanded(child: Text("Declaro que los datos son correctos.", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))]),
                const SizedBox(height: 30),

                Row(children: [
                  Expanded(child: OutlinedButton(style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15), side: const BorderSide(color: Colors.red), foregroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), onPressed: () => Navigator.pop(context), child: const Text("VOLVER"))),
                  const SizedBox(width: 15),
                  Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: bankPrimaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), onPressed: _submit, child: const Text("FINALIZAR"))),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- HELPERS ---
  Widget _title(String t) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)));
  InputDecoration _dec(String h, IconData i) => InputDecoration(hintText: h, counterText: "", prefixIcon: Icon(i, color: Colors.grey), filled: true, fillColor: Colors.grey.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.blue.shade900, width: 2)));
  Widget _radio(String l) => Row(children: [Radio(value: l, groupValue: accountType, activeColor: Colors.blue.shade900, onChanged: (v) => setState(() => accountType = v)), Text(l)]);
  Widget _chk(String l, Function(bool) f) { bool v = (l=="Tarjeta Débito"?atm:l=="Banca Online"?internet:l=="Banca Móvil"?mobile:l=="Alertas Email"?emailAlert:l=="Talonario"?cheque:eStatement); return Row(children: [Checkbox(value: v, activeColor: Colors.blue.shade900, onChanged: (val) { setState(() => f(val!)); }), Text(l)]); }

  void _submit() async {
    if (accountType == null) return _alert("Seleccione tipo de cuenta.");
    if (cardController.text.length != 16) return _alert("Tarjeta inválida (16 dígitos).");
    if (pinController.text.length != 4) return _alert("PIN inválido (4 dígitos).");
    if (!isDeclared) return _alert("Acepte la declaración.");

    // Recopilar servicios en un string
    String services = "";
    if (atm) services += "ATM,";
    if (internet) services += "Internet,";
    if (mobile) services += "Mobile,";
    if (emailAlert) services += "Email,";

    try {
      // LLAMADA A LA BASE DE DATOS (MÉTODO UNIFICADO)
      await DatabaseHelper.instance.registerUser(
        pin: pinController.text,
        card: cardController.text,
        formNo: widget.formNo,
        name: widget.name,
        dob: widget.dob,
        gender: widget.gender,
        email: widget.email,
        marital: widget.marital,
        address: widget.address,
        city: widget.city,
        cp: widget.cp,
        state: widget.state,
        accountType: accountType!,
        services: services,
      );

      if (!mounted) return;
      
      // Éxito
      showDialog(
        context: context, barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Column(children: [const Icon(Icons.check_circle, color: Colors.green, size: 50), const SizedBox(height: 10), Text("¡Cuenta Creada!", style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold))]),
          content: const Text("Su cuenta ha sido creada con éxito. Ya puede iniciar sesión.", textAlign: TextAlign.center),
          actions: [SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade900, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), onPressed: () { Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (r) => false); }, child: const Text("IR AL LOGIN")))],
        ),
      );

    } catch (e) {
      _alert("Error: ${e.toString()}");
    }
  }

  void _alert(String m) {
    showDialog(context: context, builder: (_) => AlertDialog(title: Text("Aviso", style: TextStyle(color: Colors.blue.shade900)), content: Text(m), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))]));
  }
}