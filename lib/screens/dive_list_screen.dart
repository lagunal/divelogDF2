import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:divelogtest/providers/dive_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:divelogtest/models/dive_session.dart';
import 'package:divelogtest/services/dive_service.dart';
import 'package:divelogtest/services/export_service.dart';
import 'package:divelogtest/theme.dart';
import 'package:divelogtest/widgets/dive_card.dart';
import 'package:divelogtest/widgets/empty_state_card.dart';
import 'package:divelogtest/screens/add_edit_dive_screen.dart';
import 'package:intl/intl.dart';

class DiveListScreen extends StatefulWidget {
  final DiveService? diveService;

  const DiveListScreen({super.key, this.diveService});

  @override
  State<DiveListScreen> createState() => _DiveListScreenState();
}

class _DiveListScreenState extends State<DiveListScreen> {
  late final DiveService _diveService;
  final ExportService _exportService = ExportService();
  bool _isLoading = false;

  // Filter & Sort states
  String _searchQuery = '';
  String? _selectedLocation;
  String? _selectedOperator;
  DateTimeRange? _dateRange;
  String _sortBy = 'date'; // date, depth, duration

  @override
  void initState() {
    super.initState();
    _diveService = widget.diveService ?? DiveService();
  }

  Future<void> _loadDives() async {
    final userId = _getUserId();
    if (userId != null) {
      await context.read<DiveProvider>().refreshData(userId);
    }
  }

  String? _getUserId() {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return 'test-user';
    }
  }

  List<DiveSession> _getFilteredDives(List<DiveSession> allDives) {
    List<DiveSession> filtered = allDives.where((dive) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!dive.lugarBuceo.toLowerCase().contains(query) &&
            !dive.operadoraBuceo.toLowerCase().contains(query) &&
            !dive.descripcionTrabajo.toLowerCase().contains(query)) {
          return false;
        }
      }

      if (_selectedLocation != null && dive.lugarBuceo != _selectedLocation) {
        return false;
      }

      if (_selectedOperator != null &&
          dive.operadoraBuceo != _selectedOperator) {
        return false;
      }

      if (_dateRange != null) {
        if (dive.horaEntrada.isBefore(_dateRange!.start) ||
            dive.horaEntrada
                .isAfter(_dateRange!.end.add(const Duration(days: 1)))) {
          return false;
        }
      }

      return true;
    }).toList();

    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'depth':
          return b.maximaProfundidad.compareTo(a.maximaProfundidad);
        case 'duration':
          return b.tiempoTotalInmersion.compareTo(a.tiempoTotalInmersion);
        case 'date':
        default:
          return b.horaEntrada.compareTo(a.horaEntrada);
      }
    });

    return filtered;
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedLocation = null;
      _selectedOperator = null;
      _dateRange = null;
      _sortBy = 'date';
    });
  }

  Future<void> _showFilterSheet() async {
    final userId = _getUserId();
    if (userId == null) return;

    final locations = await _diveService.getUniqueLocations(userId);
    final operators = await _diveService.getUniqueOperators(userId);

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        selectedLocation: _selectedLocation,
        selectedOperator: _selectedOperator,
        dateRange: _dateRange,
        sortBy: _sortBy,
        locations: locations,
        operators: operators,
        onApply: (location, operator, dateRange, sortBy) {
          setState(() {
            _selectedLocation = location;
            _selectedOperator = operator;
            _dateRange = dateRange;
            _sortBy = sortBy;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  bool get _hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _selectedLocation != null ||
      _selectedOperator != null ||
      _dateRange != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<DiveProvider>(
      builder: (context, diveProvider, child) {
        final filteredDives = _getFilteredDives(diveProvider.allDives);
        final isLoading = diveProvider.isLoading || _isLoading;

        return Scaffold(
          appBar: AppBar(
            title: Text('Todas las Inmersiones',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            actions: [
              if (filteredDives.isNotEmpty && !isLoading)
                PopupMenuButton<String>(
                  icon: Icon(Icons.share, color: colorScheme.primary),
                  tooltip: 'Exportar Lista',
                  onSelected: (value) async {
                    setState(() => _isLoading = true);
                    try {
                      if (value == 'pdf') {
                        await _exportService
                            .exportDivesListToPdf(filteredDives);
                      } else if (value == 'csv') {
                        await _exportService
                            .exportDivesListToCsv(filteredDives);
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Error al exportar: $value - $e')),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'pdf',
                      child: Row(
                        children: [
                          Icon(Icons.picture_as_pdf, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Exportar Lista PDF'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'csv',
                      child: Row(
                        children: [
                          Icon(Icons.table_chart, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Exportar Lista CSV'),
                        ],
                      ),
                    ),
                  ],
                ),
              IconButton(
                icon: Icon(Icons.add, color: colorScheme.primary),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddEditDiveScreen()),
                  );
                  _loadDives();
                },
                tooltip: 'Nueva Inmersión',
              ),
              if (_hasActiveFilters)
                IconButton(
                  icon: Icon(Icons.clear_all, color: colorScheme.primary),
                  onPressed: _clearFilters,
                  tooltip: 'Limpiar filtros',
                ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                _buildSearchBar(theme, colorScheme, isDark),
                if (_hasActiveFilters) _buildActiveFilters(colorScheme),
                _buildResultsCount(theme, colorScheme, filteredDives),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredDives.isEmpty
                          ? _buildEmptyState()
                          : _buildDiveList(filteredDives),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(
      ThemeData theme, ColorScheme colorScheme, bool isDark) {
    return Padding(
      padding: AppSpacing.paddingMd,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [AppEffects.softShadow],
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
                decoration: InputDecoration(
                  hintText: 'Buscar inmersiones...',
                  prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                  filled: true,
                  fillColor: isDark ? colorScheme.surface : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: AppSpacing.horizontalMd,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: _hasActiveFilters
                  ? colorScheme.primaryContainer
                  : (isDark ? colorScheme.surface : Colors.white),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: [AppEffects.softShadow],
            ),
            child: IconButton(
              icon: Icon(
                Icons.tune,
                color: _hasActiveFilters
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.primary,
              ),
              onPressed: _showFilterSheet,
              tooltip: 'Filtros',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters(ColorScheme colorScheme) {
    return Container(
      height: 44,
      padding: const EdgeInsets.only(bottom: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.horizontalMd,
        children: [
          if (_selectedLocation != null)
            FilterChip(
              label: Text(_selectedLocation!),
              icon: const Icon(Icons.location_on, size: 16),
              onTap: () => setState(() => _selectedLocation = null),
            ),
          if (_selectedOperator != null)
            FilterChip(
              label: Text(_selectedOperator!),
              icon: const Icon(Icons.business, size: 16),
              onTap: () => setState(() => _selectedOperator = null),
            ),
          if (_dateRange != null)
            FilterChip(
              label: Text(
                '${DateFormat('dd/MM').format(_dateRange!.start)} - ${DateFormat('dd/MM').format(_dateRange!.end)}',
              ),
              icon: const Icon(Icons.date_range, size: 16),
              onTap: () => setState(() => _dateRange = null),
            ),
        ],
      ),
    );
  }

  Widget _buildResultsCount(ThemeData theme, ColorScheme colorScheme,
      List<DiveSession> filteredDives) {
    return Padding(
      padding: AppSpacing.horizontalMd.copyWith(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${filteredDives.length} inmersiones',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (filteredDives.isNotEmpty)
            TextButton.icon(
              icon: const Icon(Icons.sort, size: 16),
              label: Text(_getSortLabel()),
              onPressed: _showFilterSheet,
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: EmptyStateCard(
        icon: _hasActiveFilters ? Icons.search_off : Icons.scuba_diving,
        title: _hasActiveFilters ? 'Sin resultados' : 'No hay inmersiones',
        subtitle: _hasActiveFilters
            ? 'Intenta con otros filtros'
            : 'Registra tu primera inmersión',
        actionLabel:
            _hasActiveFilters ? 'Limpiar filtros' : 'Agregar Inmersión',
        onAction: _hasActiveFilters
            ? _clearFilters
            : () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddEditDiveScreen()),
                );
                _loadDives();
              },
      ),
    );
  }

  Widget _buildDiveList(List<DiveSession> filteredDives) {
    return RefreshIndicator(
      onRefresh: _loadDives,
      child: ListView.separated(
        padding: AppSpacing.paddingMd,
        itemCount: filteredDives.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final dive = filteredDives[index];
          return DiveCard(
            dive: dive,
            contextId: 'list',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditDiveScreen(existingDive: dive),
                ),
              );
              _loadDives();
            },
          );
        },
      ),
    );
  }

  String _getSortLabel() {
    switch (_sortBy) {
      case 'depth':
        return 'Profundidad';
      case 'duration':
        return 'Duración';
      case 'date':
      default:
        return 'Fecha';
    }
  }
}

class FilterChip extends StatelessWidget {
  final Widget label;
  final Widget icon;
  final VoidCallback onTap;

  const FilterChip({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconTheme(
                  data: IconThemeData(color: colorScheme.onSecondaryContainer),
                  child: icon,
                ),
                const SizedBox(width: 6),
                DefaultTextStyle(
                  style: TextStyle(
                    color: colorScheme.onSecondaryContainer,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  child: label,
                ),
                const SizedBox(width: 6),
                Icon(Icons.close,
                    size: 16, color: colorScheme.onSecondaryContainer),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  final String? selectedLocation;
  final String? selectedOperator;
  final DateTimeRange? dateRange;
  final String sortBy;
  final List<String> locations;
  final List<String> operators;
  final Function(String?, String?, DateTimeRange?, String) onApply;

  const FilterBottomSheet({
    super.key,
    this.selectedLocation,
    this.selectedOperator,
    this.dateRange,
    required this.sortBy,
    required this.locations,
    required this.operators,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String? _location;
  late String? _operator;
  late DateTimeRange? _dateRange;
  late String _sortBy;

  @override
  void initState() {
    super.initState();
    _location = widget.selectedLocation;
    _operator = widget.selectedOperator;
    _dateRange = widget.dateRange;
    _sortBy = widget.sortBy;
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: AppSpacing.paddingLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Filtros y Orden',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Ordenar por',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Fecha'),
                      selected: _sortBy == 'date',
                      onSelected: (selected) =>
                          setState(() => _sortBy = 'date'),
                    ),
                    ChoiceChip(
                      label: const Text('Profundidad'),
                      selected: _sortBy == 'depth',
                      onSelected: (selected) =>
                          setState(() => _sortBy = 'depth'),
                    ),
                    ChoiceChip(
                      label: const Text('Duración'),
                      selected: _sortBy == 'duration',
                      onSelected: (selected) =>
                          setState(() => _sortBy = 'duration'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Lugar de buceo',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                if (widget.locations.isEmpty)
                  Text('No hay ubicaciones disponibles',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant))
                else
                  Wrap(
                    spacing: 8,
                    children: widget.locations.map((location) {
                      return ChoiceChip(
                        label: Text(location),
                        selected: _location == location,
                        onSelected: (selected) => setState(
                            () => _location = selected ? location : null),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 24),
                Text('Operadora',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                if (widget.operators.isEmpty)
                  Text('No hay operadoras disponibles',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant))
                else
                  Wrap(
                    spacing: 8,
                    children: widget.operators.map((operator) {
                      return ChoiceChip(
                        label: Text(operator),
                        selected: _operator == operator,
                        onSelected: (selected) => setState(
                            () => _operator = selected ? operator : null),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 24),
                Text('Rango de fechas',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    _dateRange == null
                        ? 'Seleccionar rango'
                        : '${DateFormat('dd/MM/yy').format(_dateRange!.start)} - ${DateFormat('dd/MM/yy').format(_dateRange!.end)}',
                  ),
                  onPressed: _pickDateRange,
                ),
                if (_dateRange != null)
                  TextButton.icon(
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Limpiar'),
                    onPressed: () => setState(() => _dateRange = null),
                  ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => widget.onApply(
                        _location, _operator, _dateRange, _sortBy),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('Aplicar Filtros'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
