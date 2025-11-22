// guide/presentation/pages/guide_list_page.dart (Ejemplo)
import 'package:flutter/material.dart';

class GuideListPage extends StatelessWidget {
  const GuideListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Aquí irá el listado de Guías/Rutas Favoritas.',
          style: TextStyle(fontSize: 18, color: Color(0xFF6B7280)),
        ),
      ),
    );
  }
}