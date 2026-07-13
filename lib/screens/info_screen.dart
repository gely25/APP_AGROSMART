import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  static const _tech = [
    (Icons.phone_android_outlined, 'Flutter'),
    (Icons.memory_outlined, 'ESP32'),
    (Icons.sensors_rounded, 'HTTP'),
    (Icons.wifi_rounded, 'WiFi'),
    (Icons.code_outlined, 'Arduino IDE'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo + version card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Column(
              children: [
                // Logo
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 16)],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset('assets/images/smartfarm_logo.png', fit: BoxFit.cover),
                ),
                const SizedBox(height: 16),
                const Text('SmartFarm',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.foreground)),
                const SizedBox(height: 4),
                const Text('Corral Pecuario Inteligente',
                  style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text('Versión 1.0.0',
                    style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary,
                    )),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Acerca de SmartFarm
          _InfoBlock(
            title: 'Acerca de SmartFarm',
            child: const Text(
              'Plataforma profesional de monitoreo y control en tiempo real para la automatización '
              'de corrales pecuarios. Permite gestionar de forma remota y local el estado de puertas, '
              'bebederos y sensores de movimiento, mejorando la eficiencia y el bienestar animal.',
              style: TextStyle(fontSize: 13, height: 1.6, color: AppColors.mutedForeground),
            ),
          ),

          const SizedBox(height: 12),

          // Firmware ESP32
          _InfoBlock(
            title: 'Firmware ESP32',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Versión del Firmware: v1.0.0',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.foreground)),
                SizedBox(height: 4),
                Text('Protocolo de comunicación: HTTP REST API sobre red WiFi local. '
                    'Para sincronizar el dispositivo, asegúrese de que el ESP32 esté en la misma subred '
                    'y configure la dirección IP de conexión en los ajustes de red.',
                  style: TextStyle(fontSize: 12, height: 1.5, color: AppColors.mutedForeground)),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Información del sistema
          _InfoBlock(
            title: 'Información del sistema',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _InfoRow(label: 'Arquitectura', value: 'Flutter (Dart) / C++ ESP32'),
                SizedBox(height: 8),
                _InfoRow(label: 'Gestor de Estado', value: 'Provider ^6.1.2'),
                SizedBox(height: 8),
                _InfoRow(label: 'Estilo visual', value: 'Material Design 3'),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Licencia
          _InfoBlock(
            title: 'Licencia',
            child: const Text(
              'Software bajo licencia comercial propietaria de SmartFarm. '
              'Todos los derechos reservados. Queda prohibida la reproducción, distribución o '
              'modificación no autorizada de este código fuente.',
              style: TextStyle(fontSize: 12, height: 1.5, color: AppColors.mutedForeground),
            ),
          ),

          const SizedBox(height: 12),

          // Política de privacidad
          _InfoBlock(
            title: 'Política de privacidad',
            child: const Text(
              'Esta aplicación no recopila ni transmite datos personales fuera de la red local. '
              'Todas las lecturas y comandos se procesan en tiempo real entre el dispositivo móvil '
              'y el microcontrolador ESP32 de forma directa y cifrada en su red privada local.',
              style: TextStyle(fontSize: 12, height: 1.5, color: AppColors.mutedForeground),
            ),
          ),

          const SizedBox(height: 12),

          // Technologies
          _InfoBlock(
            title: 'Tecnologías utilizadas',
            child: Wrap(
              spacing: 8, runSpacing: 8,
              children: _tech.map((t) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(t.$1, size: 14, color: AppColors.secondaryForeground),
                    const SizedBox(width: 6),
                    Text(t.$2,
                      style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500,
                        color: AppColors.secondaryForeground,
                      )),
                  ],
                ),
              )).toList(),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoBlock({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600,
              letterSpacing: 1.2, color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.foreground)),
      ],
    );
  }
}
