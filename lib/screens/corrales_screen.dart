import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/farm_provider.dart';
import '../models/farm_state.dart';
import 'home_screen.dart';
import 'agregar_corral_wizard.dart';

class CorralesScreen extends StatefulWidget {
  const CorralesScreen({super.key});

  @override
  State<CorralesScreen> createState() => _CorralesScreenState();
}

class _CorralesScreenState extends State<CorralesScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _activeCategory = 'Todos';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmProvider>(
      builder: (_, provider, __) {
        // Active count calculation
        final totalCorrales = provider.corrales.length;
        final activeCorrales = provider.corrales.where((c) => c.connected).length;

        // Apply search & category filter
        final filteredCorrales = provider.corrales.where((c) {
          final matchesSearch = c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              c.description.toLowerCase().contains(_searchQuery.toLowerCase());
          
          if (!matchesSearch) return false;

          if (_activeCategory == 'Operativos') {
            return c.connected && c.availability >= 90.0;
          } else if (_activeCategory == 'Atención') {
            return c.connected && c.availability < 90.0;
          } else if (_activeCategory == 'Sin conexión') {
            return !c.connected;
          }
          return true;
        }).toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primary,
                        child: const Icon(Icons.eco_rounded, size: 20, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('SMARTFARM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.mutedForeground, letterSpacing: 0.8)),
                          Text('Mis Corrales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.foreground)),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('$activeCorrales/$totalCorrales', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.foreground)),
                          const Text('activos', style: TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Top summary boxes
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      _SummaryBox(
                        label: 'Corrales',
                        value: '$totalCorrales',
                        isSelected: false,
                      ),
                      const SizedBox(width: 8),
                      _SummaryBox(
                        label: 'Eventos hoy',
                        value: '${provider.state.pirEventsToday + 16}', // simulating accumulated events across corrales
                        isSelected: true,
                      ),
                      const SizedBox(width: 8),
                      _SummaryBox(
                        label: 'Animales',
                        value: '39',
                        isSelected: false,
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Buscar corral o ubicación',
                        hintStyle: TextStyle(color: AppColors.mutedForeground, fontSize: 13),
                        prefixIcon: Icon(Icons.search_rounded, size: 18, color: AppColors.mutedForeground),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 13),
                      ),
                    ),
                  ),
                ),

                // Filter Category Chips
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Todos', 'Operativos', 'Atención', 'Sin conexión'].map((cat) {
                        final isSelected = _activeCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _activeCategory = cat),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : AppColors.mutedForeground,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Corrales List
                Expanded(
                  child: filteredCorrales.isEmpty
                      ? _EmptyState(onAdd: () => _openWizard(context))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                          itemCount: filteredCorrales.length,
                          itemBuilder: (_, i) {
                            final corral = filteredCorrales[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _CorralCard(
                                corral: corral,
                                state: provider.state,
                                onEnter: () {
                                  provider.selectCorral(corral.id);
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                                  );
                                },
                                onDelete: () => _confirmDelete(context, provider, corral.id),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openWizard(context),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add, color: Colors.white, size: 16),
            label: const Text('Agregar corral', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
        );
      },
    );
  }

  void _openWizard(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AgregarCorralWizard()),
    );
  }

  void _confirmDelete(BuildContext context, FarmProvider provider, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.card,
        title: const Text('Eliminar corral', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        content: const Text('¿Estás seguro de eliminar este corral? Esta acción no se puede deshacer.',
            style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.destructive),
            onPressed: () {
              provider.deleteCorral(id);
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;

  const _SummaryBox({required this.label, required this.value, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected ? const Color(0xFFE2F3E7) : AppColors.card;
    final textColor = isSelected ? AppColors.primary : AppColors.foreground;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary.withOpacity(0.3) : AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textColor)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.mutedForeground, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _CorralCard extends StatelessWidget {
  final CorralInfo corral;
  final FarmState state;
  final VoidCallback onEnter;
  final VoidCallback onDelete;

  const _CorralCard({
    required this.corral,
    required this.state,
    required this.onEnter,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Mode text
    String modeText = 'Manual';
    if (corral.availability >= 90.0) {
      modeText = 'Automático';
    } else if (corral.availability >= 60.0) {
      modeText = 'Human in the Loop';
    }

    // Determine status tag and color
    Color accentColor = AppColors.primary;
    String statusTag = 'Operativo';
    Color tagBgColor = const Color(0xFFE2F3E7);

    if (!corral.connected) {
      accentColor = Colors.grey.shade400;
      statusTag = 'Sin conexión';
      tagBgColor = Colors.grey.shade100;
    } else if (corral.availability < 90.0) {
      accentColor = const Color(0xFFE5A842);
      statusTag = 'Atención';
      tagBgColor = const Color(0xFFFFF7EA);
    }

    // Dynamic fake time ago
    final timeStr = corral.connected ? 'hace ${corral.rssi.abs() - 40} s' : 'hace 3 h';

    return GestureDetector(
      onTap: onEnter,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Left accent bar
              Positioned(
                left: 0, top: 0, bottom: 0,
                child: Container(width: 5, color: accentColor),
              ),

              // Card content
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      children: [
                        Text(corral.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.foreground)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: tagBgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5, height: 5,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: accentColor),
                              ),
                              const SizedBox(width: 4),
                              Text(statusTag, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: accentColor)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Metadata row 1
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 13, color: AppColors.mutedForeground),
                        const SizedBox(width: 4),
                        Text(corral.description, style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Metadata row 2
                    Row(
                      children: [
                        const Icon(Icons.memory_outlined, size: 13, color: AppColors.mutedForeground),
                        const SizedBox(width: 4),
                        Text(modeText, style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                        const SizedBox(width: 12),
                        const Icon(Icons.wifi_tethering_rounded, size: 13, color: AppColors.mutedForeground),
                        const SizedBox(width: 4),
                        Text(timeStr, style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                      ],
                    ),

                    const SizedBox(height: 12),
                    Container(height: 1, color: AppColors.border),
                    const SizedBox(height: 12),

                    // Footer row
                    Row(
                      children: [
                        Text('${corral.availability < 50 ? 0 : 17}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.foreground)),
                        const SizedBox(width: 3),
                        const Text('eventos', style: TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
                        const SizedBox(width: 16),
                        Text('${corral.availability < 50 ? 3 : corral.availability < 90 ? 24 : 12}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.foreground)),
                        const SizedBox(width: 3),
                        const Text('animales', style: TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
                        const Spacer(),
                        Row(
                          children: const [
                            Text('Abrir', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                            SizedBox(width: 2),
                            Icon(Icons.chevron_right_rounded, size: 15, color: AppColors.primary),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Delete button (can be triggered by long press or small gesture if needed, let's allow it in a small corner or long press to keep clean mockup look)
              Positioned(
                right: 0, bottom: 44,
                child: GestureDetector(
                  onLongPress: onDelete,
                  child: Container(width: 20, height: 20, color: Colors.transparent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(color: AppColors.muted, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.cabin_rounded, size: 28, color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 14),
          const Text('Sin corrales registrados', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text('Comienza agregando tu primer corral IoT', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Agregar corral'),
          ),
        ],
      ),
    );
  }
}