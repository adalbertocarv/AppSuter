import 'package:flutter/material.dart';
import 'paradas_tela.dart';
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
    RegistrarParadaTela(), // Tela de paradas com Flutter Map
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
      appBar: AppBar(
        title: const Text('Paradas e Registro'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
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
                  MaterialPageRoute(builder: (context) => const ParadasTela()),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Paradas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Registro',
          ),
        ],
      ),
    );
  }
}
