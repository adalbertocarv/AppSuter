import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'paradas_bd_tela.dart';
import 'registrar_paradas_tela.dart';
import 'registro_tela.dart';
import '../services/login_service.dart';
import 'login_tela.dart';

class TelaInicio extends StatefulWidget {
  const TelaInicio({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<TelaInicio> {
  int _currentIndex = 0;

  // Lista de telas associadas ao Bottom Navigation
  final List<Widget> _pages = [
    const RegistrarParadaTela(), // Tela de paradas com Flutter Map
    const RegistroTela(), // Tela de registro (vazia por enquanto)
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _logout(BuildContext context) async {
    await LoginService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Permite que o corpo do Scaffold se estenda atrás da Navigation Bar
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        centerTitle: true,
        title: const Text('Paradas e Registros'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue[900]),
              child: const Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.pin_drop),
              title: const Text('Paradas cadastradas'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ParadasBanco()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
      body: _pages[
          _currentIndex], // Exibe a tela selecionada no Bottom Navigation
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: Theme.of(context).colorScheme.primary,
        buttonBackgroundColor: Theme.of(context).colorScheme.secondary,
        animationDuration: const Duration(milliseconds: 300),
        height: 60,
        index: _currentIndex, // Define a aba inicial
        onTap: _onTabTapped, // Método para mudar de tela
        items: const [
          Icon(Icons.map, size: 30, color: Colors.white), // Ícone da tela "Cadastrar Parada"
          Icon(Icons.add_circle, size: 30, color: Colors.white), // Ícone da tela "Registros"
        ],
      ),
    );
  }
}
