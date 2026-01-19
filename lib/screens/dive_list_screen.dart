import 'package:flutter/material.dart';
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
  List<DiveSession> _allDives = [];
  List<DiveSession> _filteredDives = [];
  bool _isLoading = true;

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
    _loadDives();
  }

  Future<void> _loadDives() async {
    setState(() => _isLoading = true);
    try {
      await _diveService.initialize();
      final userId = _getUserId();
      final dives = userId != null
          ? await _diveService.getDiveSessionsByUserId(userId)
          : await _diveService.getAllDiveSessions();
      setState(() {
        _allDives = dives;
        _filteredDives = dives;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _getUserId() {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      // Return a dummy ID for tests where Firebase is not initialized
      return 'test-user';
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredDives = _allDives.where((dive) {
        // Search filter
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          if (!dive.lugarBuceo.toLowerCase().contains(query) &&
              !dive.operadoraBuceo.toLowerCase().contains(query) &&
              !dive.descripcionTrabajo.toLowerCase().contains(query)) {
            return false;
          }
        }

        // Location filter
        if (_selectedLocation != null && dive.lugarBuceo != _selectedLocation) {
          return false;
        }

        // Operator filter
        if (_selectedOperator != null &&
            dive.operadoraBuceo != _selectedOperator) {
          return false;
        }

        // Date range filter
        if (_dateRange != null) {
          if (dive.horaEntrada.isBefore(_dateRange!.start) ||
              dive.horaEntrada
                  .isAfter(_dateRange!.end.add(const Duration(days: 1)))) {
            return false;
          }
        }

        return true;
      }).toList();

      // Apply sorting
      _filteredDives.sort((a, b) {
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
    });
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedLocation = null;
      _selectedOperator = null;
      _dateRange = null;
      _sortBy = 'date';
      _filteredDives = _allDives;
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
          _applyFilters();
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Todas las Inmersiones',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        actions: [
          if (_filteredDives.isNotEmpty && !_isLoading)
            PopupMenuButton<String>(
              icon: Icon(Icons.share, color: colorScheme.primary),
              tooltip: 'Exportar Lista',
              onSelected: (value) async {
                setState(() => _isLoading = true);
                try {
                  if (value == 'pdf') {
                    await _exportService.exportDivesListToPdf(_filteredDives);
                  } else if (value == 'csv') {
                    await _exportService.exportDivesListToCsv(_filteredDives);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al exportar: $value - $e')),
                    );
                  }
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AddEditDiveScreen()),
              );
              if (result == true) _loadDives();
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
            // Search and Filter Bar
            Padding(
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
                          _searchQuery = value;
                          _applyFilters();
                        },
                        decoration: InputDecoration(
                          hintText: 'Buscar inmersiones...',
                          hintStyle: theme.textTheme.bodyMedium?.withColor(
                            colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                          prefixIcon:
                              Icon(Icons.search, color: colorScheme.primary),
                          filled: true,
                          fillColor:
                              isDark ? colorScheme.surface : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            borderSide: BorderSide(
                              color: colorScheme.outline.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            borderSide: BorderSide(
                              color: colorScheme.outline.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            borderSide: BorderSide(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
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
                      border: Border.all(
                        color: _hasActiveFilters
                            ? colorScheme.primary
                            : colorScheme.outline.withValues(alpha: 0.1),
                        width: 1,
                      ),
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
            ),

            // Active Filters Chips
            if (_hasActiveFilters)
              Container(
                height: 40,
                padding: AppSpacing.horizontalMd,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    if (_selectedLocation != null)
                      FilterChip(
                        label: Text(_selectedLocation!),
                        icon: const Icon(Icons.location_on, size: 16),
                        onTap: () {
                          setState(() => _selectedLocation = null);
                          _applyFilters();
                        },
                      ),
                    if (_selectedOperator != null)
                      FilterChip(
                        label: Text(_selectedOperator!),
                        icon: const Icon(Icons.business, size: 16),
                        onTap: () {
                          setState(() => _selectedOperator = null);
                          _applyFilters();
                        },
                      ),
                    if (_dateRange != null)
                      FilterChip(
                        label: Text(
                          '${DateFormat('dd/MM').format(_dateRange!.start)} - ${DateFormat('dd/MM').format(_dateRange!.end)}',
                        ),
                        icon: const Icon(Icons.date_range, size: 16),
                        onTap: () {
                          setState(() => _dateRange = null);
                          _applyFilters();
                        },
                      ),
                  ],
                ),
              ),

            // Results Count
            Padding(
              padding: AppSpacing.horizontalMd.copyWith(top: 8, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_filteredDives.length} inmersiones',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_filteredDives.isNotEmpty)
                    TextButton.icon(
                      icon: const Icon(Icons.sort, size: 16),
                      label: Text(_getSortLabel()),
                      onPressed: _showFilterSheet,
                    ),
                ],
              ),
            ),

            // Dive List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredDives.isEmpty
                      ? Center(
                          child: EmptyStateCard(
                            icon: _hasActiveFilters
                                ? Icons.search_off
                                : Icons.scuba_diving,
                            title: _hasActiveFilters
                                ? 'No se encontraron inmersiones'
                                : 'No hay inmersiones registradas',
                            subtitle: _hasActiveFilters
                                ? 'Intenta con otros filtros'
                                : 'Registra tu primera inmersión para comenzar',
                            actionLabel: _hasActiveFilters
                                ? 'Limpiar filtros'
                                : 'Agregar Inmersión',
                            onAction: _hasActiveFilters
                                ? _clearFilters
                                : () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const AddEditDiveScreen()),
                                    );
                                    if (result == true) _loadDives();
                                  },
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadDives,
                          child: ListView.separated(
                            padding: AppSpacing.paddingMd,
                            itemCount: _filteredDives.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final dive = _filteredDives[index];
                              return DiveCard(
                                dive: dive,
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AddEditDiveScreen(existingDive: dive),
                                    ),
                                  );
                                  if (result == true) _loadDives();
                                },
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
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
                // Header
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

                // Sort By Section
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

                // Location Filter
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

                // Operator Filter
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

                // Date Range Filter
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

                // Apply Button
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
