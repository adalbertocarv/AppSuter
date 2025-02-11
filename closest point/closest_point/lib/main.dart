import 'package:closest_point/screens/vias.dart';
import 'package:flutter/material.dart';
import 'screens/interpolado_tela.dart';

void main() => runApp(const closestpoint());

class closestpoint extends StatelessWidget {
  const closestpoint({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapaViasInterpoladas(),
    );
  }
}
