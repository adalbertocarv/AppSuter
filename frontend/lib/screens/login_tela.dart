import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/login_service.dart';
import 'tela_inicio.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nomeController = TextEditingController();
  final _matriculaController = TextEditingController();
  bool _isLoading = false;
  bool? isChecked = false; // Checkbox state
  final _matriculaFormatter = MaskTextInputFormatter(
    mask: '###.###-#',
    filter: {"#": RegExp(r'[0-9]')},
  );

  // Function for login
  void _login() async {
    setState(() {
      _isLoading = true;
    });

    final nome = _nomeController.text.trim();
    final matricula = _matriculaFormatter.getUnmaskedText();

    final result = await LoginService.login(nome, matricula);

    setState(() {
      _isLoading = false;
    });

    if (result.idUsuario != null) {
      _showSnackBar(context, 'Autenticado com sucesso!', Colors.green);
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TelaInicio()),
        );
      });
    } else if (result.timeout) {
      _showSnackBar(context, 'Tempo limite. Verifique sua conexão.', Colors.orange);
    } else {
      _showSnackBar(context, 'Login falhou. Verifique suas credenciais.', Colors.red);
    }
  }

  void _showSnackBar(BuildContext context, String message, Color backgroundColor) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller,
      bool isPassword, {
        TextInputType? keyboardType,
        List<TextInputFormatter>? inputFormatters,
      }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType ?? TextInputType.text,
      inputFormatters: inputFormatters,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: screenWidth > 600 ? 550 : screenWidth * 0.9,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(50),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset('assets/images/imagessemob.png'),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Entrar',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField('Nome completo', _nomeController, false),
                      const SizedBox(height: 25),
                      _buildTextField(
                        'Matrícula',
                        _matriculaController,
                        false,
                        keyboardType: TextInputType.number,
                        inputFormatters: [_matriculaFormatter],
                      ),
                      const SizedBox(height: 15),
                      //_LembreDeMimAgora(),
                      //const SizedBox(height: 30),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : _buildLoginButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
/*
  Widget _LembreDeMimAgora() {
    return Wrap(
      spacing: 10, // Space between widgets
      runSpacing: 5, // Space between lines when wrapping
      alignment: WrapAlignment.spaceBetween, // Align items within the space
      children: [
        Row(
          mainAxisSize: MainAxisSize.min, // Take only necessary space
          children: [
            Checkbox(
              value: isChecked,
              activeColor: Colors.blue,
              onChanged: (newBool) {
                setState(() {
                  isChecked = newBool ?? false;
                });
              },
            ),
            const Text(
              'Lembre-se de mim',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const recSenha()),
            );
          },
          child: const Text(
            'Esqueceu sua senha?',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }
*/

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _login,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.all(15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      child: const Text(
        'Entrar',
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}

