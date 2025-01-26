import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ponto_parada_provider.dart';

class RegistroTela extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final points = Provider.of<PointProvider>(context).points;

    return Scaffold(
      body: ListView.builder(
        itemCount: points.length,
        itemBuilder: (ctx, index) {
          final point = points[index];
          return ListTile(
            leading: point.imagePath != null
                ? Image.file(File(point.imagePath!), width: 50, height: 50, fit: BoxFit.cover)
                : const Icon(Icons.location_on),
            title: Text(point.address),
            subtitle: Text('Lat: ${point.latLng.latitude}, Lon: ${point.latLng.longitude}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                Provider.of<PointProvider>(context, listen: false).removePoint(index);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Provider.of<PointProvider>(context, listen: false).sendPointsToBackend();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Paradas enviadas ao backend!')),
          );
        },
        child: const Icon(Icons.cloud_upload),
      ),
    );
  }
}
