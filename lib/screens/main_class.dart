import 'package:flutter/material.dart';

import 'deposit_page.dart';
import 'withdraw_page.dart';
import 'fast_cash_page.dart';
import 'mini_statement_page.dart';
import 'pin_change_page.dart';
import 'login_page.dart';

class MainClass extends StatelessWidget {
  final String pin;

  const MainClass({super.key, required this.pin});

  @override
  Widget build(BuildContext context) {
    // Color corporativo
    final Color bankPrimaryColor = Colors.blue.shade900;

    return Scaffold(
      // Fondo sólido azul
      backgroundColor: bankPrimaryColor,
      
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            // Tarjeta blanca central
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
                /// LOGO
                Image.asset(
                  "assets/bank.png",
                  width: 80,
                  height: 80,
                  errorBuilder: (c, e, s) => Icon(Icons.account_balance, size: 80, color: bankPrimaryColor),
                ),
                
                const SizedBox(height: 15),

                /// TÍTULO
                Text(
                  "MENÚ PRINCIPAL",
                  style: TextStyle(
                    color: bankPrimaryColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Seleccione una operación",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                
                const SizedBox(height: 30),

                /// BOTONES DE OPERACIONES
                /// 
                _buildButton(context, "INGRESAR DINERO", Icons.arrow_downward, bankPrimaryColor, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => DepositPage(pin: pin)));
                }),
                
                _buildButton(context, "RETIRAR EFECTIVO", Icons.money_off, bankPrimaryColor, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => WithdrawPage(pin: pin)));
                }),
                
                _buildButton(context, "EFECTIVO RÁPIDO", Icons.flash_on, bankPrimaryColor, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => FastCashPage(pin: pin)));
                }),
                
                _buildButton(context, "MOVIMIENTOS", Icons.receipt_long, bankPrimaryColor, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => MiniStatementPage(pin: pin)));
                }),
                
                _buildButton(context, "CAMBIAR PIN", Icons.lock_reset, bankPrimaryColor, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PinChangePage(pin: pin)));
                }),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),

                /// BOTÓN SALIR
                _buildButton(context, "CERRAR SESIÓN", Icons.logout, Colors.redAccent, () {
                  Navigator.pushAndRemoveUntil(
                    context, 
                    MaterialPageRoute(builder: (_) => const LoginPage()), 
                    (route) => false
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper para construir botones
  Widget _buildButton(BuildContext context, String text, IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
        ),
        icon: Icon(icon, size: 20),
        label: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        onPressed: onPressed,
      ),
    );
  }
}