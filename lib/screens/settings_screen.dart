import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/farm_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _motionNotif = true;
  bool _waterNotif = true;
  bool _connectionNotif = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
      builder: (_, provider, __) {
        final corral = provider.activeCorral;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Configuración'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: AppColors.border),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            children: [
              // Profile header
              _ProfileHeader(
                userName: provider.userName,
                corralName: corral?.name ?? 'Sin corral',
              ),
              const SizedBox(height: 20),

              // Corral info
              _SectionLabel('INFORMACIÓN DEL CORRAL'),
              const SizedBox(height: 10),
              _SettingsGroup(children: [
                _SettingsInfo(label: 'Nombre', value: corral?.name ?? '—'),
                _SettingsInfo(label: 'Dirección IP', value: corral?.ip ?? '—'),
                _SettingsInfo(label: 'MAC ESP32', value: corral?.macAddress ?? '—'),
                _SettingsInfo(label: 'Firmware', value: corral?.firmware ?? 'v1.0.0'),
                _SettingsInfo(label: 'Disponibilidad', value: '${corral?.availability.toStringAsFixed(1) ?? "—"}%'),
              ]),
              const SizedBox(height: 20),

              // Notifications
              _SectionLabel('NOTIFICACIONES'),
              const SizedBox(height: 10),
              _SettingsGroup(children: [
                _SettingsSwitch(
                  label: 'Sonido',
                  icon: Icons.volume_up_outlined,
                  value: _soundEnabled,
                  onChanged: (v) => setState(() => _soundEnabled = v),
                ),
                _SettingsSwitch(
                  label: 'Vibración',
                  icon: Icons.vibration_rounded,
                  value: _vibrationEnabled,
                  onChanged: (v) => setState(() => _vibrationEnabled = v),
                ),
                _SettingsSwitch(
                  label: 'Alertas de movimiento',
                  icon: Icons.sensors_rounded,
                  value: _motionNotif,
                  onChanged: (v) => setState(() => _motionNotif = v),
                ),
                _SettingsSwitch(
                  label: 'Alertas de agua baja',
                  icon: Icons.water_drop_outlined,
                  value: _waterNotif,
                  onChanged: (v) => setState(() => _waterNotif = v),
                ),
                _SettingsSwitch(
                  label: 'Alertas de conexión',
                  icon: Icons.wifi_rounded,
                  value: _connectionNotif,
                  onChanged: (v) => setState(() => _connectionNotif = v),
                ),
              ]),
              const SizedBox(height: 20),

              // ESP32 Actions
              _SectionLabel('SISTEMA ESP32'),
              const SizedBox(height: 10),
              _SettingsGroup(children: [
                _SettingsAction(
                  label: 'Actualizar firmware',
                  icon: Icons.system_update_alt_rounded,
                  color: AppColors.info,
                  onTap: () => _showConfirmDialog(
                    context, 'Actualizar firmware',
                    'Se verificará la disponibilidad de actualizaciones para el controlador.',
                    () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Firmware ya está actualizado (v1.0.0)'), behavior: SnackBarBehavior.floating),
                    ),
                  ),
                ),
                _SettingsAction(
                  label: 'Reiniciar controlador',
                  icon: Icons.restart_alt_rounded,
                  color: AppColors.warning,
                  onTap: () => _showConfirmDialog(
                    context, 'Reiniciar controlador',
                    '¿Deseas reiniciar el microcontrolador? La conexión se interrumpirá por unos segundos.',
                    () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Dispositivo reiniciado'), behavior: SnackBarBehavior.floating),
                    ),
                  ),
                ),
                _SettingsAction(
                  label: 'Restablecer configuración',
                  icon: Icons.restore_rounded,
                  color: AppColors.destructive,
                  onTap: () => _showConfirmDialog(
                    context, 'Restablecer configuración',
                    'Se borrarán todos los datos y configuraciones locales. Esta acción no se puede deshacer.',
                    () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Configuración restablecida'), behavior: SnackBarBehavior.floating),
                    ),
                    destructive: true,
                  ),
                ),
              ]),
              const SizedBox(height: 20),

              // Legal
              _SectionLabel('ACERCA DE'),
              const SizedBox(height: 10),
              _SettingsGroup(children: [
                _SettingsAction(
                  label: 'Acerca de SmartFarm',
                  icon: Icons.info_outline_rounded,
                  onTap: () => _showAbout(context),
                ),
                _SettingsAction(
                  label: 'Licencia comercial',
                  icon: Icons.shield_outlined,
                  onTap: () => _showLicense(context),
                ),
                _SettingsAction(
                  label: 'Política de privacidad',
                  icon: Icons.privacy_tip_outlined,
                  onTap: () => _showPrivacy(context),
                ),
              ]),
              const SizedBox(height: 20),

              // Version footer
              Center(
                child: Column(
                  children: const [
                    Text('SmartFarm v1.0.0',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.mutedForeground)),
                    SizedBox(height: 4),
                    Text('© 2025 SmartFarm Technologies · Todos los derechos reservados',
                        style: TextStyle(fontSize: 10, color: AppColors.mutedForeground), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showConfirmDialog(BuildContext ctx, String title, String msg, VoidCallback onConfirm, {bool destructive = false}) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.card,
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        content: Text(msg, style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: destructive ? ElevatedButton.styleFrom(backgroundColor: AppColors.destructive) : null,
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(destructive ? 'Confirmar' : 'Proceder'),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.card,
        title: const Text('Acerca de SmartFarm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        content: const Text(
          'SmartFarm es una plataforma IoT de gestión inteligente de corrales agropecuarios.\n\n'
          'Versión: 1.0.0\nFirmware ESP32: v1.0.0\nProtocolo: HTTP/REST\n\n'
          'Diseñado para operadores agrícolas que requieren monitoreo y control remoto de infraestructura pecuaria.',
          style: TextStyle(fontSize: 12, color: AppColors.mutedForeground, height: 1.5),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
      ),
    );
  }

  void _showLicense(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.card,
        title: const Text('Licencia Comercial', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        content: const Text(
          'SmartFarm está protegido por derechos de propiedad intelectual.\n\n'
          'Esta aplicación es software propietario. Queda prohibida su reproducción, distribución o ingeniería inversa sin autorización escrita del titular.\n\n'
          '© 2025 SmartFarm Technologies. Todos los derechos reservados.',
          style: TextStyle(fontSize: 12, color: AppColors.mutedForeground, height: 1.5),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Entendido'))],
      ),
    );
  }

  void _showPrivacy(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.card,
        title: const Text('Política de Privacidad', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        content: const Text(
          'SmartFarm no recopila ni transmite datos personales a servidores externos.\n\n'
          'Toda la comunicación ocurre exclusivamente en la red local (LAN) entre la aplicación y el dispositivo ESP32.\n\n'
          'Los registros de auditoría y eventos se almacenan localmente en el dispositivo móvil.',
          style: TextStyle(fontSize: 12, color: AppColors.mutedForeground, height: 1.5),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Entendido'))],
      ),
    );
  }
}

// ── Profile Header ────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final String userName;
  final String corralName;

  const _ProfileHeader({required this.userName, required this.corralName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : 'O',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const Text('Operador de corral', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.cabin_outlined, size: 11, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(corralName, style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Settings Components ───────────────────────────────────────────────────────

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: children.indexed.map((e) {
          final i = e.$1;
          return Column(
            children: [
              e.$2,
              if (i < children.length - 1)
                Padding(
                  padding: const EdgeInsets.only(left: 52),
                  child: Container(height: 1, color: AppColors.border),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SettingsInfo extends StatelessWidget {
  final String label;
  final String value;
  const _SettingsInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.foreground),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool value;
  final void Function(bool) onChanged;
  const _SettingsSwitch({required this.label, required this.icon, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.mutedForeground),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          Switch.adaptive(value: value, activeColor: AppColors.primary, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _SettingsAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;
  const _SettingsAction({required this.label, required this.icon, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.foreground;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 18, color: c),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: TextStyle(fontSize: 13, color: c))),
            Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.mutedForeground),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.1, color: AppColors.mutedForeground));
}