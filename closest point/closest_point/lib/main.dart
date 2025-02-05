import 'package:flutter/material.dart';
import 'screens/map_screen.dart';

void main() => runApp(const closestpoint());

class closestpoint extends StatelessWidget {
  const closestpoint({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapPage(),
    );
  }
}
