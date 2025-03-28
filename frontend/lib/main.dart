import 'package:flutter/material.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:frontend/providers/ponto_parada_provider.dart';
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
  await const FMTCStore('mapStore').manage.create();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PointProvider()..carregarPontos()),
        ChangeNotifierProvider(create: (_) => EnvioStatus()),
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
      debugShowCheckedModeBanner: false, // Desativa o banner de debug
      title: 'SEMOB - Ponto Certo',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.blue.shade900,// Cor primária
          secondary: Colors.blue.shade700, // Cor de destaque
        ),
      ),
      home: FutureBuilder<int?>(
        future: LoginService.getUsuarioId(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data != null) {
            return const TelaInicio();// TelaInicio
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
