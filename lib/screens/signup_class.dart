import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'signup2_class.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // Controladores
  final TextEditingController nameController = TextEditingController();
  final TextEditingController fnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final TextEditingController stateController = TextEditingController();

  // Variables de estado
  String? gender;
  String? maritalStatus;
  DateTime? selectedDate;

  // Generador de número de formulario
  final String formNo = (Random().nextInt(9000) + 1000).toString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDEFFE4), // Color verde claro

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Cabecera con Logo y Número
            Row(
              children: [
                Image.asset(
                  "assets/bank.png",
                  width: 100,
                  height: 100,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    "SOLICITUD Nº $formNo",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            const Text(
              "Pág. 1",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const Text(
              "Datos Personales",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // --- CAMPOS DE TEXTO ---

            _buildTitle("Nombre:"),
            _buildInput(nameController),

            _buildTitle("Sexo:"),
            Row(
              children: [
                _radio("Masc.", gender, (v) => setState(() => gender = v)),
                _radio("Fem.", gender, (v) => setState(() => gender = v)),
              ],
            ),

            _buildTitle("F. Nacimiento:"),
            InkWell(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                width: double.infinity, // Ocupar todo el ancho
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  color: Colors.white,
                ),
                child: Text(
                  selectedDate == null
                      ? "Seleccionar Fecha"
                      // Uso de intl para formato correcto (dd/MM/yyyy)
                      : DateFormat('dd/MM/yyyy').format(selectedDate!),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            _buildTitle("Email:"),
            _buildInput(emailController),

            _buildTitle("Est. Civil:"),
            Row(
              children: [
                _radio("Casado", maritalStatus, (v) => setState(() => maritalStatus = v)),
                _radio("Soltero", maritalStatus, (v) => setState(() => maritalStatus = v)),
              ],
            ),

            _buildTitle("Dirección:"),
            _buildInput(addressController),

            _buildTitle("Ciudad:"),
            _buildInput(cityController),

            _buildTitle("C.P.:"),
            _buildInput(pinController, keyboard: TextInputType.number),

            _buildTitle("Provincia:"),
            _buildInput(stateController),

            const SizedBox(height: 30),

            /// Botón SIGUIENTE
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  fixedSize: const Size(120, 40),
                ),
                onPressed: _next,
                child: const Text("SIG."),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ==========================
  // WIDGET HELPERS
  // ==========================

  Widget _buildTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 5),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, {TextInputType keyboard = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: const InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      ),
    );
  }

  Widget _radio(String label, String? group, Function(String?) onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio(
          value: label,
          groupValue: group,
          onChanged: onChanged,
        ),
        Text(label),
        const SizedBox(width: 10),
      ],
    );
  }

  // ==========================
  // ACTIONS
  // ==========================

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: "SELECCIONAR FECHA",
      cancelText: "CANCELAR",
      confirmText: "ACEPTAR",
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.black),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  void _next() {
    // Validar campos obligatorios básicos
    if (nameController.text.isEmpty ||
        fnameController.text.isEmpty ||
        gender == null ||
        selectedDate == null ||
        addressController.text.isEmpty ||
        pinController.text.isEmpty) {
      
      _alert("Por favor, complete todos los campos obligatorios.");
      return;
    }

    // Navegar a la página 2
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Signup2Page(formNo: formNo),
      ),
    );
  }

  void _alert(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Aviso"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }
}