import 'package:flutter/material.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:frontend/providers/ponto_parada_provider.dart';
import 'package:frontend/screens/login_tela.dart';
import 'package:frontend/screens/tela_inicio.dart';
import 'package:frontend/services/login_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';

import 'models/ponto_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialização do backend de cache (ObjectBox)
  await FMTCObjectBoxBackend().initialise();
  await const FMTCStore('mapStore').manage.create();

  // Inicialização do Isar
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [PontoModelSchema],
    directory: dir.path,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PontoProvider(isar)),
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
      debugShowCheckedModeBanner: false,
      title: 'SEMOB - Ponto Certo',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.blue.shade900,
          secondary: Colors.blue.shade700,
        ),
      ),
      home: FutureBuilder<int?>(
        future: LoginService.getUsuarioId(),
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
