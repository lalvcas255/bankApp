import 'package:flutter/material.dart';

import 'deposit_page.dart';
import 'withdraw_page.dart';
import 'fast_cash_page.dart';
import 'mini_statement_page.dart';
import 'pin_change_page.dart';
import 'balance_enquiry_page.dart';

class MainClass extends StatelessWidget {
  final String pin;

  const MainClass({super.key, required this.pin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset("assets/atm2.png", fit: BoxFit.cover),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "SELECCIONE UNA OPERACIÓN",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    _buildButton(context, "INGRESAR", () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => DepositPage(pin: pin)));
                    }),
                    _buildButton(context, "RETIRAR EFECTIVO", () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => WithdrawPage(pin: pin)));
                    }),
                    _buildButton(context, "EFECTIVO RÁPIDO", () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => FastCashPage(pin: pin)));
                    }),
                    _buildButton(context, "MOVIMIENTOS", () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => MiniStatementPage(pin: pin)));
                    }),
                    _buildButton(context, "CAMBIAR PIN", () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => PinChangePage(pin: pin)));
                    }),
                    _buildButton(context, "CONSULTA SALDO", () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => BalanceEnquiryPage(pin: pin)));
                    }),
                    const SizedBox(height: 10),
                    _buildButton(context, "SALIR", () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    }, isExit: true),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, VoidCallback onPressed,
      {bool isExit = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isExit ? Colors.redAccent : const Color(0xFF417D80),
          foregroundColor: Colors.white,
          minimumSize: const Size(260, 45),
          shape: const BeveledRectangleBorder(),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}