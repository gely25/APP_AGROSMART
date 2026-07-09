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

  static const _team = [
    'Integrante 1',
    'Integrante 2',
    'Integrante 3',
    'Integrante 4',
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

          // Description
          _InfoBlock(
            title: 'Descripción',
            child: const Text(
              'Aplicación de monitoreo y control en tiempo real de un corral pecuario automatizado. '
              'Permite operar la puerta, el comedero y el bebedero, y recibir alertas del sistema '
              'mediante un ESP32 conectado por WiFi.',
              style: TextStyle(fontSize: 13, height: 1.6, color: AppColors.mutedForeground),
            ),
          ),

          const SizedBox(height: 12),

          // University
          _InfoBlock(
            title: 'Universidad',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Universidad — Ingeniería',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.foreground)),
                SizedBox(height: 2),
                Text('Proyecto académico IoT',
                  style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Team
          _InfoBlock(
            title: 'Integrantes',
            child: Column(
              children: _team.map((name) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        name[name.length - 1],
                        style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(name,
                      style: const TextStyle(fontSize: 14, color: AppColors.foreground)),
                  ],
                ),
              )).toList(),
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
