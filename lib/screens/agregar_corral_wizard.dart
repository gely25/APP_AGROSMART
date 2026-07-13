import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/farm_provider.dart';
import '../models/farm_state.dart';

class AgregarCorralWizard extends StatefulWidget {
  const AgregarCorralWizard({super.key});

  @override
  State<AgregarCorralWizard> createState() => _AgregarCorralWizardState();
}

class _AgregarCorralWizardState extends State<AgregarCorralWizard>
    with TickerProviderStateMixin {
  int _step = 0;
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  // Simulated ESP32 discovery
  bool _scanning = false;
  bool _found = false;
  double _scanProgress = 0.0;
  Timer? _scanTimer;

  // Simulated connection test
  bool _testing = false;
  bool _testDone = false;
  bool _testOk = false;
  double _testProgress = 0.0;
  Timer? _testTimer;

  final _simulatedMAC = 'A4:CF:12:${Random().nextInt(255).toRadixString(16).padLeft(2, '0').toUpperCase()}:${Random().nextInt(255).toRadixString(16).padLeft(2, '0').toUpperCase()}:02';
  final _simulatedIP = '192.168.1.${100 + Random().nextInt(100)}';
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _scanTimer?.cancel();
    _testTimer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _startScan() {
    setState(() { _scanning = true; _found = false; _scanProgress = 0; });
    _scanTimer = Timer.periodic(const Duration(milliseconds: 80), (t) {
      setState(() => _scanProgress = (_scanProgress + 0.025).clamp(0.0, 1.0));
      if (_scanProgress >= 1.0) {
        t.cancel();
        setState(() { _scanning = false; _found = true; });
      }
    });
  }

  void _startTest() {
    setState(() { _testing = true; _testDone = false; _testOk = false; _testProgress = 0; });
    _testTimer = Timer.periodic(const Duration(milliseconds: 60), (t) {
      setState(() => _testProgress = (_testProgress + 0.02).clamp(0.0, 1.0));
      if (_testProgress >= 1.0) {
        t.cancel();
        setState(() { _testing = false; _testDone = true; _testOk = true; });
      }
    });
  }

  void _save() {
    final provider = context.read<FarmProvider>();
    final id = 'corral_${DateTime.now().millisecondsSinceEpoch}';
    provider.addCorral(CorralInfo(
      id: id,
      name: _nameCtrl.text.trim().isEmpty ? 'Nuevo corral' : _nameCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? 'Sin descripción' : _descCtrl.text.trim(),
      macAddress: _simulatedMAC,
      ip: _simulatedIP,
      firmware: 'v1.0.0',
      rssi: -60 - Random().nextInt(20),
      availability: 99.0,
      connected: true,
      lastSyncAt: DateTime.now(),
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Agregar corral'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(5),
          child: _StepProgressBar(step: _step, total: 5),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(anim),
            child: child,
          ),
        ),
        child: KeyedSubtree(
          key: ValueKey(_step),
          child: _buildStep(),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _StepDatos(nameCtrl: _nameCtrl, descCtrl: _descCtrl, onNext: () => setState(() => _step = 1));
      case 1:
        return _StepScan(
          scanning: _scanning,
          found: _found,
          progress: _scanProgress,
          pulseAnim: _pulseAnim,
          onScan: _startScan,
          onNext: () => setState(() => _step = 2),
        );
      case 2:
        return _StepEsp32Info(
          mac: _simulatedMAC,
          ip: _simulatedIP,
          onNext: () => setState(() => _step = 3),
        );
      case 3:
        return _StepTest(
          testing: _testing,
          done: _testDone,
          ok: _testOk,
          progress: _testProgress,
          onTest: _startTest,
          onNext: () => setState(() => _step = 4),
        );
      case 4:
        return _StepSave(
          name: _nameCtrl.text.trim().isEmpty ? 'Nuevo corral' : _nameCtrl.text.trim(),
          desc: _descCtrl.text.trim(),
          mac: _simulatedMAC,
          ip: _simulatedIP,
          onSave: _save,
        );
      default:
        return const SizedBox();
    }
  }
}

// ── Step Progress Bar ────────────────────────────────────────────────────────

class _StepProgressBar extends StatelessWidget {
  final int step;
  final int total;
  const _StepProgressBar({required this.step, required this.total});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final pct = i <= step ? 1.0 : 0.0;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            height: 4,
            margin: EdgeInsets.only(right: i < total - 1 ? 2 : 0),
            decoration: BoxDecoration(
              color: pct > 0 ? AppColors.primary : AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

// ── Step 1: Datos ────────────────────────────────────────────────────────────

class _StepDatos extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController descCtrl;
  final VoidCallback onNext;
  const _StepDatos({required this.nameCtrl, required this.descCtrl, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      icon: Icons.cabin_rounded,
      title: 'Información del corral',
      subtitle: 'Paso 1 de 5 — Datos generales',
      content: Column(
        children: [
          _WizardLabel('Nombre del corral *'),
          const SizedBox(height: 6),
          _WizardInput(ctrl: nameCtrl, hint: 'Ej: Corral Norte'),
          const SizedBox(height: 14),
          _WizardLabel('Descripción'),
          const SizedBox(height: 6),
          _WizardInput(ctrl: descCtrl, hint: 'Ej: Corral de bovinos — Zona norte', maxLines: 2),
          const SizedBox(height: 14),
          _InfoRow(icon: Icons.image_outlined, text: 'Fotografía opcional — disponible en próxima versión'),
        ],
      ),
      onNext: onNext,
      nextEnabled: true,
    );
  }
}

// ── Step 2: Buscar ESP32 ─────────────────────────────────────────────────────

class _StepScan extends StatelessWidget {
  final bool scanning;
  final bool found;
  final double progress;
  final Animation<double> pulseAnim;
  final VoidCallback onScan;
  final VoidCallback onNext;

  const _StepScan({
    required this.scanning,
    required this.found,
    required this.progress,
    required this.pulseAnim,
    required this.onScan,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      icon: Icons.radar_rounded,
      title: 'Buscar controlador',
      subtitle: 'Paso 2 de 5 — Escaneo de red',
      content: Column(
        children: [
          const SizedBox(height: 12),
          Center(
            child: AnimatedBuilder(
              animation: pulseAnim,
              builder: (_, child) {
                return Transform.scale(
                  scale: scanning ? pulseAnim.value : 1.0,
                  child: child,
                );
              },
              child: Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: found ? AppColors.successBg : AppColors.primaryLight,
                  border: Border.all(
                    color: found ? AppColors.success : AppColors.primary,
                    width: 2,
                  ),
                  boxShadow: scanning ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 24,
                      spreadRadius: 8,
                    ),
                  ] : [],
                ),
                child: Icon(
                  found ? Icons.check_circle_rounded : Icons.wifi_find_rounded,
                  size: 52,
                  color: found ? AppColors.success : AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (scanning) ...[
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 10),
            Text('Escaneando red WiFi... ${(progress * 100).toInt()}%',
                style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
          ] else if (found) ...[
            const Text('¡Controlador encontrado en la red!',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.success)),
          ] else ...[
            const Text('Presiona "Escanear" para buscar controladores en tu red WiFi local.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
          ],
          const SizedBox(height: 20),
          if (!found)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: scanning ? null : onScan,
                icon: Icon(scanning ? Icons.hourglass_empty_rounded : Icons.search_rounded, size: 16),
                label: Text(scanning ? 'Escaneando...' : 'Iniciar escaneo'),
              ),
            ),
        ],
      ),
      onNext: found ? onNext : null,
      nextEnabled: found,
    );
  }
}

// ── Step 3: Detalles ESP32 ───────────────────────────────────────────────────

class _StepEsp32Info extends StatelessWidget {
  final String mac;
  final String ip;
  final VoidCallback onNext;

  const _StepEsp32Info({required this.mac, required this.ip, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      icon: Icons.memory_rounded,
      title: 'Dispositivo encontrado',
      subtitle: 'Paso 3 de 5 — Información del controlador',
      content: Column(
        children: [
          _Esp32InfoRow(label: 'Dirección MAC', value: mac, icon: Icons.fingerprint_rounded),
          const SizedBox(height: 8),
          _Esp32InfoRow(label: 'Dirección IP', value: ip, icon: Icons.router_rounded),
          const SizedBox(height: 8),
          _Esp32InfoRow(label: 'Firmware', value: 'v1.0.0', icon: Icons.code_rounded),
          const SizedBox(height: 8),
          _Esp32InfoRow(label: 'RSSI', value: '−62 dBm (Buena señal)', icon: Icons.signal_wifi_4_bar_rounded),
          const SizedBox(height: 8),
          _Esp32InfoRow(label: 'Modelo', value: 'ESP32-WROOM-32D', icon: Icons.developer_board_rounded),
        ],
      ),
      onNext: onNext,
      nextEnabled: true,
    );
  }
}

class _Esp32InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _Esp32InfoRow({required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 15, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: AppColors.mutedForeground, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.foreground)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 4: Test de conexión ─────────────────────────────────────────────────

class _StepTest extends StatelessWidget {
  final bool testing;
  final bool done;
  final bool ok;
  final double progress;
  final VoidCallback onTest;
  final VoidCallback onNext;

  const _StepTest({
    required this.testing,
    required this.done,
    required this.ok,
    required this.progress,
    required this.onTest,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      icon: Icons.network_check_rounded,
      title: 'Probar conexión',
      subtitle: 'Paso 4 de 5 — Verificación de enlace',
      content: Column(
        children: [
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            height: 8,
            child: LinearProgressIndicator(
              value: done ? 1.0 : (testing ? progress : 0.0),
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(done && ok ? AppColors.success : AppColors.primary),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          ..._testItems(done, ok),
          const SizedBox(height: 16),
          if (!done)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: testing ? null : onTest,
                icon: Icon(testing ? Icons.hourglass_empty_rounded : Icons.play_arrow_rounded, size: 16),
                label: Text(testing ? 'Probando conexión...' : 'Iniciar prueba'),
              ),
            ),
          if (done && ok) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.successBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                  SizedBox(width: 10),
                  Expanded(child: Text('Conexión exitosa. El corral está listo para registrarse.',
                      style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w500))),
                ],
              ),
            ),
          ],
        ],
      ),
      onNext: done && ok ? onNext : null,
      nextEnabled: done && ok,
    );
  }

  List<Widget> _testItems(bool done, bool ok) {
    final items = [
      ('Ping al dispositivo', done),
      ('Verificar endpoints API', done),
      ('Leer estado de sensores', done),
      ('Latencia aceptable', done),
    ];
    return items.map((item) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: item.$2
                ? const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success, key: ValueKey('ok'))
                : const Icon(Icons.radio_button_unchecked_rounded, size: 16, color: AppColors.mutedForeground, key: ValueKey('pending')),
          ),
          const SizedBox(width: 10),
          Text(item.$1, style: const TextStyle(fontSize: 13, color: AppColors.foreground)),
        ],
      ),
    )).toList();
  }
}

// ── Step 5: Guardar ──────────────────────────────────────────────────────────

class _StepSave extends StatelessWidget {
  final String name;
  final String desc;
  final String mac;
  final String ip;
  final VoidCallback onSave;

  const _StepSave({
    required this.name,
    required this.desc,
    required this.mac,
    required this.ip,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      icon: Icons.save_rounded,
      title: 'Confirmar y guardar',
      subtitle: 'Paso 5 de 5 — Resumen',
      content: Column(
        children: [
          _SummaryRow('Nombre', name),
          const SizedBox(height: 8),
          if (desc.isNotEmpty) ...[_SummaryRow('Descripción', desc), const SizedBox(height: 8)],
          _SummaryRow('MAC', mac),
          const SizedBox(height: 8),
          _SummaryRow('IP', ip),
          const SizedBox(height: 8),
          _SummaryRow('Firmware', 'v1.0.0'),
          const SizedBox(height: 8),
          _SummaryRow('Estado', 'Conectado ✓'),
        ],
      ),
      onNext: onSave,
      nextEnabled: true,
      nextLabel: 'Guardar corral',
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Row(
    children: [
      SizedBox(
        width: 90,
        child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground, fontWeight: FontWeight.w500)),
      ),
      Expanded(
        child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.foreground)),
      ),
    ],
  );
}

// ── Reusable Step Scaffold ───────────────────────────────────────────────────

class _StepScaffold extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget content;
  final VoidCallback? onNext;
  final bool nextEnabled;
  final String nextLabel;

  const _StepScaffold({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.content,
    this.onNext,
    required this.nextEnabled,
    this.nextLabel = 'Continuar',
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: content,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: nextEnabled ? onNext : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(nextLabel),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Wizard Helpers ───────────────────────────────────────────────────────────

class _WizardLabel extends StatelessWidget {
  final String text;
  const _WizardLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.foreground));
}

class _WizardInput extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final int maxLines;
  const _WizardInput({required this.ctrl, required this.hint, this.maxLines = 1});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14, color: AppColors.foreground),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.mutedForeground, fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 14, color: AppColors.mutedForeground),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground))),
    ],
  );
}