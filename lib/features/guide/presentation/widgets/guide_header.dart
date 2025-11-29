// guide/presentation/widgets/guide_header.dart (o el archivo donde lo tengas)

import 'package:flutter/material.dart';

// La clase principal del Header
class GuideHeader extends StatelessWidget {
  final String cafeteriaName;
  // Campo nuevo para mostrar la ubicación detectada por el sistema
  final String userLocationName; 
  
  const GuideHeader({
    required this.cafeteriaName, 
    required this.userLocationName, // Requerido para la ubicación actual
    super.key
  }); 

  @override
  Widget build(BuildContext context) {
    const Color grayColor = Color(0xFF6B7280);
    const Color lightGrayColor = Color(0xFFE5E7EB);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.35, color: lightGrayColor),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded( 
                // Expanded asegura que la columna ocupe todo el ancho disponible.
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ubicación Actual: usa la ubicación detectada
                    LocationField(
                      icon: Icons.my_location, 
                      text: userLocationName, // Usa el nombre dinámico
                    ),
                    const SizedBox(height: 5),
                    // Cafetería Destino: usa el nuevo icono de cafetería
                    LocationField(
                      icon: Icons.local_cafe, // ☕ Nuevo icono de cafetería
                      text: cafeteriaName, 
                    ),
                  ],
                ),
              ),

            ],
          ),
        ],
      ),
    );
  }
}

// --- CLASE AUXILIAR LocationField ---
class LocationField extends StatelessWidget {
  final IconData icon;
  final String text;
  
  const LocationField({
    required this.icon, 
    required this.text, 
    super.key
  });

  @override
  Widget build(BuildContext context) {
    const Color grayColor = Color(0xFF6B7280);
    const Color lightGrayColor = Color(0xFFE5E7EB);
    const Color backgroundGray = Color(0xFFF9FAFB);

    return Container(
      width: double.infinity, 
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: ShapeDecoration(
        color: backgroundGray,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1.35, color: lightGrayColor),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: grayColor),
          const SizedBox(width: 5), 
          Expanded( // Usamos Expanded en el texto para asegurar que ocupe el resto del espacio
            child: Text(
              text,
              overflow: TextOverflow.ellipsis, // Para manejar textos largos
              style: const TextStyle(
                color: grayColor,
                fontSize: 16,
                fontFamily: 'Arimo',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget auxiliar para el botón de Navegación (Salir ahora)
class _NavigationButton extends StatelessWidget {
  final String text;
  final IconData icon;

  const _NavigationButton({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    const Color grayColor = Color(0xFF6B7280);
    const Color lightGrayColor = Color(0xFFE5E7EB);
    const Color backgroundGray = Color(0xFFF9FAFB);

    return Container(
      width: 131,
      height: 37,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: ShapeDecoration(
        color: backgroundGray,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1.35, color: lightGrayColor),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: grayColor,
              fontSize: 16,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 5),
          Icon(icon, size: 18, color: grayColor),
        ],
      ),
    );
  }
}

// Widget auxiliar para el botón de Tiempo Estimado
class _TimeEstimateButton extends StatelessWidget {
  final String time;
  final String unit;

  const _TimeEstimateButton({required this.time, required this.unit});

  @override
  Widget build(BuildContext context) {
    const Color grayColor = Color(0xFF6B7280);
    const Color lightGrayColor = Color(0xFFE5E7EB);
    const Color backgroundGray = Color(0xFFF9FAFB);
    
    return Container(
      width: 116,
      height: 37,
      decoration: ShapeDecoration(
        color: backgroundGray,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1.35, color: lightGrayColor),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer, size: 20, color: grayColor),
          const SizedBox(width: 8),
          Text(
            time,
            style: const TextStyle(
              color: grayColor,
              fontSize: 16,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            unit,
            style: const TextStyle(
              color: grayColor,
              fontSize: 10,
              fontFamily: 'Arimo',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}