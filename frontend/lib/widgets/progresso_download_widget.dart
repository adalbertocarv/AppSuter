import 'package:flutter/material.dart';

class ProgressoDownloadWidget extends StatelessWidget {
  final double progresso; // De 0.0 a 100.0

  const ProgressoDownloadWidget({Key? key, required this.progresso}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LinearProgressIndicator(
          value: progresso,
          minHeight: 10,
          backgroundColor: Colors.grey[300],
          color: Colors.lightGreenAccent,
        ),
        const SizedBox(height: 10),
        Text(
          'Progresso: ${(progresso * 100).toStringAsFixed(2)}%',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
