import 'package:flutter/material.dart';
import 'package:frontend/providers/ponto_parada_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_tela.dart';
import 'screens/tela_inicio.dart';
import 'services/login_service.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Limpar o token ao iniciar o app
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('token'); // Remove o token armazenado
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PointProvider()..loadPoints()), // Garante que as paradas sejam carregadas
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Desativa o banner de debug
      title: 'App Suter',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.blue, // Cor primária
          secondary: Colors.blueAccent, // Cor de destaque
        ),
      ),
      home: FutureBuilder<String?>(
        future: LoginService.getToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data != null) {
            return const TelaInicio();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
