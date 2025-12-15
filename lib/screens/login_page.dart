import 'package:flutter/material.dart';
import 'main_class.dart';
import 'signup_class.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController cardController = TextEditingController();
  final TextEditingController pinController = TextEditingController();

  void signIn() {
    String card = cardController.text.trim();
    String pin = pinController.text.trim();

    if (card == "1234" && pin == "0000") {
      // CORRECTO: LoginPage SÍ debe usar pushReplacement porque es la pantalla inicial
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainClass(pin: pin)),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: const Text("Incorrect Card Number or PIN"),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Fondo
          SizedBox.expand(
            child: Image.asset(
              "assets/backbg.png",
              fit: BoxFit.cover,
            ),
          ),

          /// Contenido
          Center(
            child: SizedBox(
              width: 850,
              height: 480,
              child: Stack(
                children: [
                  /// Imagen banco
                  Positioned(
                    top: 10,
                    left: 350,
                    child: Image.asset(
                      "assets/bank.png",
                      width: 100,
                      height: 100,
                    ),
                  ),

                  /// Imagen tarjeta
                  Positioned(
                    bottom: 10,
                    right: 20,
                    child: Image.asset(
                      "assets/card.png",
                      width: 100,
                      height: 100,
                    ),
                  ),

                  /// Texto principal
                  const Positioned(
                    top: 125,
                    left: 230,
                    child: Text(
                      "WELCOME TO ATM",
                      style: TextStyle(
                        fontSize: 38,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  /// Card number
                  Positioned(
                    top: 190,
                    left: 150,
                    child: Row(
                      children: [
                        const Text(
                          "Card No:",
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 230,
                          child: TextField(
                            controller: cardController,
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// PIN
                  Positioned(
                    top: 250,
                    left: 150,
                    child: Row(
                      children: [
                        const Text(
                          "PIN:",
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 68),
                        SizedBox(
                          width: 230,
                          child: TextField(
                            controller: pinController,
                            obscureText: true,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// Botón SIGN IN
                  Positioned(
                    top: 300,
                    left: 300,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        fixedSize: const Size(100, 30),
                      ),
                      onPressed: signIn,
                      child: const Text("SIGN IN"),
                    ),
                  ),

                  /// Botón CLEAR
                  Positioned(
                    top: 300,
                    left: 430,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        fixedSize: const Size(100, 30),
                      ),
                      onPressed: () {
                        cardController.clear();
                        pinController.clear();
                      },
                      child: const Text("CLEAR"),
                    ),
                  ),

                  /// Botón SIGN UP
                  Positioned(
                    top: 350,
                    left: 300,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        fixedSize: const Size(230, 30),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SignupPage()),
                        );
                      },
                      child: const Text("SIGN UP"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cardController.dispose();
    pinController.dispose();
    super.dispose();
  }
}