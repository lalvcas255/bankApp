import 'package:flutter/material.dart';
import 'database_helper.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final TextEditingController cardController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final Color bankPrimaryColor = Colors.blue.shade900;

    return Scaffold(
      backgroundColor: bankPrimaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: 450,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 10)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 60, color: Colors.red),
                const SizedBox(height: 10),
                const Text(
                  "ELIMINAR CUENTA",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
                ),
                const SizedBox(height: 10),
                Text(
                  "Esta acción es irreversible.\nPor favor, confirme sus credenciales para proceder.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 30),

                // CAMPO TARJETA
                TextField(
                  controller: cardController,
                  keyboardType: TextInputType.number,
                  maxLength: 16,
                  decoration: _inputDecoration("Número de Tarjeta (16 dígitos)", Icons.credit_card),
                ),
                const SizedBox(height: 15),

                // CAMPO PIN
                TextField(
                  controller: pinController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: true,
                  decoration: _inputDecoration("PIN Actual (4 dígitos)", Icons.lock),
                ),
                const SizedBox(height: 30),

                // BOTÓN ELIMINAR
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Rojo para peligro
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: isProcessing ? null : _deleteAccount,
                    child: isProcessing 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                      : const Text("ELIMINAR DEFINITIVAMENTE", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      labelText: hint,
      counterText: "",
      prefixIcon: Icon(icon, color: Colors.grey),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.red, width: 2)),
    );
  }

  void _deleteAccount() async {
    if (cardController.text.length != 16 || pinController.text.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Credenciales incompletas")));
      return;
    }

    setState(() => isProcessing = true);

    try {
      bool success = await DatabaseHelper.instance.deleteAccount(cardController.text, pinController.text);
      
      if (!mounted) return;
      setState(() => isProcessing = false);

      if (success) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text("Cuenta Eliminada"),
            content: const Text("Sus datos han sido borrados correctamente del sistema."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Cierra dialogo
                  Navigator.pop(context); // Vuelve al login
                },
                child: const Text("OK"),
              )
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.red, content: Text("Error: Tarjeta o PIN incorrectos.")));
      }
    } catch (e) {
      setState(() => isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
}