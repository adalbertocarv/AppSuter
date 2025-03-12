import 'package:flutter/material.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:frontend/providers/ponto_parada_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_tela.dart';
import 'screens/tela_inicio.dart';
import 'services/login_service.dart';
import 'package:provider/provider.dart';


final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialização do backend de cache (ObjectBox)
  await FMTCObjectBoxBackend().initialise();

  // Criação de um store de tiles chamado 'mapStore'
  await const FMTCStore('mapStore').manage.create();

  // Limpar o token ao iniciar o app
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('token'); // Remove o token armazenado
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PointProvider()..carregarPontos()), // Garante que as paradas sejam carregadas
      ],
      child: const PontoParada(),
    ),
  );
}

class PontoParada extends StatelessWidget {
  const PontoParada({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey, // chave global
      debugShowCheckedModeBanner: false, // Desativa o banner de debug
      title: 'App Suter',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
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
            return  const TelaInicio();
          } else {
            return  const TelaInicio(); //login
          }
        },
      ),
    );
  }
}
