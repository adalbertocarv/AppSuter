import 'package:flutter/material.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:frontend/providers/ponto_parada_provider.dart';
import 'package:frontend/widgets/consulta_endereco_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_tela.dart';
import 'screens/tela_inicio.dart';
import 'services/login_service.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialização do backend de cache (ObjectBox)
  await FMTCObjectBoxBackend().initialise();

  // Criação de um store de tiles chamado 'mapStore'
  await FMTCStore('mapStore').manage.create();

  // Limpar o token ao iniciar o app
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('token'); // Remove o token armazenado
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PointProvider()..loadPoints()), // Garante que as paradas sejam carregadas
      ],
      child: PontoParada(),
    ),
  );
}

class PontoParada extends StatelessWidget {
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
            return  TelaInicio();
          } else {
            return  TelaInicio();
          }
        },
      ),
    );
  }
}
