
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; 
import 'login_page.dart';

void main() {
runApp(const MyApp());
}

class MyApp extends StatelessWidget {
const MyApp({super.key});

@override
Widget build(BuildContext context) {
return MaterialApp(
debugShowCheckedModeBanner: false,
title: 'ATM App',

localizationsDelegates: const [
GlobalMaterialLocalizations.delegate,
GlobalWidgetsLocalizations.delegate,
GlobalCupertinoLocalizations.delegate,
],

supportedLocales: const [
Locale('es', 'ES'), // Español
Locale('en', 'US'), // Inglés
],

// Opcional: Forzar español si el móvil está en otro idioma

locale: const Locale('es', 'ES'), 

home: const LoginPage(),
);
}
}
