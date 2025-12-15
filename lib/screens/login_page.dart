import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'main_class.dart';
import 'signup_class.dart';
import 'delete_account_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controladores
  final TextEditingController cardController = TextEditingController();
  final TextEditingController pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Color corporativo
    final Color bankPrimaryColor = Colors.blue.shade900;

    return Scaffold(
      backgroundColor: bankPrimaryColor, // Fondo Azul Sólido
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              
              // Tarjeta Blanca Central
              Container(
                width: 450, // Ancho limitado para PC
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
                  children: [
                    // Icono del Banco
                    Image.asset(
                      "assets/bank.png",
                      width: 80,
                      height: 80,
                      errorBuilder: (c, e, s) => Icon(Icons.account_balance, size: 80, color: bankPrimaryColor),
                    ),
                    const SizedBox(height: 10),
                    
                    Text(
                      "CAJERO AUTOMÁTICO",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: bankPrimaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Bienvenido, por favor identifíquese",
                      style: TextStyle(color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),

                    // CAMPO TARJETA (Máximo 16 dígitos)
                    TextField(
                      controller: cardController,
                      keyboardType: TextInputType.number,
                      maxLength: 16,
                      decoration: _inputDecoration("Nº de Tarjeta", Icons.credit_card),
                    ),
                    
                    const SizedBox(height: 20),

                    // CAMPO PIN (Máximo 4 dígitos)
                    TextField(
                      controller: pinController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 4,
                      decoration: _inputDecoration("Clave Personal (PIN)", Icons.lock),
                    ),

                    const SizedBox(height: 30),

                    // BOTONES DE ACCIÓN (INTERCAMBIADOS)
                    Row(
                      children: [
                        // 1. BOTÓN ACCEDER (Izquierda)
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: bankPrimaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              elevation: 5,
                            ),
                            onPressed: _login,
                            child: const Text("ACCEDER"),
                          ),
                        ),

                        const SizedBox(width: 15),

                        // 2. BOTÓN ELIMINAR CUENTA (Derecha)
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              side: const BorderSide(color: Colors.red), // Borde Rojo
                              foregroundColor: Colors.red,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => DeleteAccountPage()),
                              );
                            },
                            child: const Text("ELIMINAR"),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 10),

                    // Enlace Registro (CENTRADO)
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SignupPage()),
                          );
                        },
                        child: Text(
                          "¿No tiene cuenta? REGÍSTRESE AQUÍ",
                          textAlign: TextAlign.center, // Asegura centrado si hay 2 líneas
                          style: TextStyle(
                            color: bankPrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper para el diseño de los inputs
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      counterText: "",
      prefixIcon: Icon(icon, color: Colors.grey.shade600),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade600),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.blue.shade900, width: 2),
      ),
    );
  }

  // Lógica de Login
  void _login() async {
    String card = cardController.text.trim();
    String pin = pinController.text.trim();

    if (card.isEmpty || pin.isEmpty) {
      _showError("Por favor, rellene todos los campos.");
      return;
    }

    try {
      final db = DatabaseHelper.instance;
      final userList = await (await db.database).query(
        'users', 
        where: 'card_number = ? AND pin = ?', 
        whereArgs: [card, pin]
      );

      if (userList.isNotEmpty) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainClass(pin: pin)),
        );
      } else {
        _showError("Tarjeta o PIN incorrectos.");
      }
    } catch (e) {
      _showError("Error de conexión: $e");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}