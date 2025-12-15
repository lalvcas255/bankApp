import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'signup2_class.dart'; // <--- IMPORTANTE: Esto dará error hasta que hagas el paso 2

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pinController = TextEditingController(); // CP
  final TextEditingController stateController = TextEditingController();

  String gender = "Masc.";
  String maritalStatus = "Casado";
  String formNo = "";
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    formNo = (1000 + DateTime.now().millisecondsSinceEpoch % 9000).toString();
  }

  @override
  Widget build(BuildContext context) {
    final Color bankPrimaryColor = Colors.blue.shade900;

    return Scaffold(
      backgroundColor: bankPrimaryColor, // Fondo azul sólido
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 10)),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Image.asset("assets/bank.png", width: 70, height: 70),
                        const SizedBox(height: 10),
                        Text("SOLICITUD Nº $formNo", style: TextStyle(fontSize: 22, color: bankPrimaryColor, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        const Text("Pág. 1: Datos Personales", style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  _buildLabel("Nombre Completo:"),
                  _buildTextField(nameController, "Ej. Juan Pérez", Icons.person),
                  const SizedBox(height: 15),

                  _buildLabel("Sexo:"),
                  Row(children: [_radioOption("Masc."), const SizedBox(width: 20), _radioOption("Fem.")]),
                  const SizedBox(height: 15),

                  _buildLabel("Fecha de Nacimiento:"),
                  TextFormField(
                    controller: dobController,
                    readOnly: true,
                    validator: (v) => v!.isEmpty ? "Seleccione fecha" : null,
                    decoration: _inputDecoration("Seleccionar Fecha").copyWith(suffixIcon: const Icon(Icons.calendar_month)),
                    onTap: _pickDate,
                  ),
                  const SizedBox(height: 15),

                  _buildLabel("Email:"),
                  _buildTextField(emailController, "nombre@correo.com", Icons.email, TextInputType.emailAddress),
                  const SizedBox(height: 15),

                  _buildLabel("Estado Civil:"),
                  Row(children: [_radioOptionMarital("Casado"), const SizedBox(width: 20), _radioOptionMarital("Soltero")]),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),

                  const Text("Dirección", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 10),
                  _buildLabel("Calle y Número:"),
                  _buildTextField(addressController, "Ej. Av. Principal 123", Icons.home),
                  const SizedBox(height: 15),

                  _buildLabel("Ciudad:"),
                  _buildTextField(cityController, "Ciudad", Icons.location_city),
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel("C.P.:"), _buildTextField(pinController, "00000", Icons.map, TextInputType.number)])),
                      const SizedBox(width: 15),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel("Provincia:"), _buildTextField(stateController, "Provincia", Icons.terrain)])),
                    ],
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: bankPrimaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      onPressed: _next,
                      child: const Text("SIGUIENTE", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(child: TextButton(onPressed: () => Navigator.pop(context), child: Text("CANCELAR", style: TextStyle(color: Colors.grey[600])))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- HELPERS ---
  Widget _buildLabel(String t) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)));
  Widget _buildTextField(TextEditingController c, String h, IconData i, [TextInputType t = TextInputType.text]) => TextFormField(controller: c, keyboardType: t, validator: (v) => (v == null || v.isEmpty) ? 'Campo obligatorio' : null, decoration: _inputDecoration(h).copyWith(prefixIcon: Icon(i, color: Colors.grey)));
  InputDecoration _inputDecoration(String h) => InputDecoration(hintText: h, filled: true, fillColor: Colors.grey.shade50, contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.blue.shade900, width: 2)));
  Widget _radioOption(String v) => Row(children: [Radio(value: v, groupValue: gender, activeColor: Colors.blue.shade900, onChanged: (val) => setState(() => gender = val.toString())), Text(v)]);
  Widget _radioOptionMarital(String v) => Row(children: [Radio(value: v, groupValue: maritalStatus, activeColor: Colors.blue.shade900, onChanged: (val) => setState(() => maritalStatus = val.toString())), Text(v)]);
  
  Future<void> _pickDate() async {
    final p = await showDatePicker(context: context, initialDate: DateTime(2000), firstDate: DateTime(1900), lastDate: DateTime.now(), locale: const Locale('es', 'ES'));
    if (p != null) setState(() { selectedDate = p; dobController.text = DateFormat('dd/MM/yyyy').format(p); });
  }

  void _next() {
    if (_formKey.currentState!.validate()) {
      // AQUÍ ESTÁ EL CAMBIO: NO LLAMAMOS A LA BD, PASAMOS DATOS A LA SIGUIENTE PÁGINA
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Signup2Page(
            formNo: formNo,
            // Pasamos todos los datos recopilados
            name: nameController.text,
            dob: dobController.text,
            gender: gender,
            email: emailController.text,
            marital: maritalStatus,
            address: addressController.text,
            city: cityController.text,
            cp: pinController.text,
            state: stateController.text,
          ),
        ),
      );
    }
  }
}