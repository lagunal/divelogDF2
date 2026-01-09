import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:divelogtest/models/dive_session.dart';
import 'package:divelogtest/services/dive_service.dart';
import 'package:divelogtest/services/user_service.dart';
import 'package:divelogtest/services/export_service.dart';
import 'package:divelogtest/theme.dart';

class AddEditDiveScreen extends StatefulWidget {
  final DiveSession? existingDive;

  const AddEditDiveScreen({super.key, this.existingDive});

  @override
  State<AddEditDiveScreen> createState() => _AddEditDiveScreenState();
}

class _AddEditDiveScreenState extends State<AddEditDiveScreen> {
  final _formKey = GlobalKey<FormState>();
  final _diveService = DiveService();
  final _userService = UserService();
  final _exportService = ExportService();

  bool _isLoading = false;
  bool get _isEditing => widget.existingDive != null;

  // Controllers for text fields
  late TextEditingController _clienteController;
  late TextEditingController _operadoraController;
  late TextEditingController _direccionController;
  late TextEditingController _lugarBuceoController;
  late TextEditingController _supervisorController;
  //late TextEditingController _tablaBuceoController;
  //late TextEditingController _aparatoController;
  //late TextEditingController _presionController;
  //late TextEditingController _tipoTrajeController;
  //late TextEditingController _mezclaController;
  late TextEditingController _visibilidadController;
  late TextEditingController _tempSuperiorController;
  late TextEditingController _tempAguaController;
  late TextEditingController _corrienteController;
  late TextEditingController _profundidadController;
  late TextEditingController _tiempoIntervalController;
  late TextEditingController _tiempoFondoController;
  late TextEditingController _tiempoTotalController;
  late TextEditingController _descripcionController;
  late TextEditingController _descompresionController;
  late TextEditingController _enfermedadController;
  late TextEditingController _tiempoSupervisionController;
  late TextEditingController _tiempoBuceoAcumController;

  // Dropdown values
  String _tipoBuceoSeleccionado = 'Scuba';
  int _estadoMarSeleccionado = 0;
  String _tipoAguaSeleccionado = 'Salada';

  // DateTime values
  DateTime _horaEntrada = DateTime.now();
  DateTime _horaSalida = DateTime.now().add(const Duration(hours: 1));
  DateTime? _inicioDescompresion;
  DateTime? _descompresionCompleta;

  // Divers list
  List<String> _nombreBuzos = [''];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    if (_isEditing) {
      _loadExistingData();
    }
  }

  void _initializeControllers() {
    _clienteController = TextEditingController();
    _operadoraController = TextEditingController();
    _direccionController = TextEditingController();
    _lugarBuceoController = TextEditingController();
    _supervisorController = TextEditingController();
    // _tablaBuceoController = TextEditingController();
    //_aparatoController = TextEditingController();
    //_presionController = TextEditingController();
    //_tipoTrajeController = TextEditingController();
    //_mezclaController = TextEditingController();
    _visibilidadController = TextEditingController();
    _tempSuperiorController = TextEditingController();
    _tempAguaController = TextEditingController();
    _corrienteController = TextEditingController();
    _profundidadController = TextEditingController();
    _tiempoIntervalController = TextEditingController();
    _tiempoFondoController = TextEditingController();
    _tiempoTotalController = TextEditingController();
    _descripcionController = TextEditingController();
    _descompresionController = TextEditingController();
    _enfermedadController = TextEditingController();
    _tiempoSupervisionController = TextEditingController();
    _tiempoBuceoAcumController = TextEditingController();
  }

  void _loadExistingData() {
    final dive = widget.existingDive!;
    _clienteController.text = dive.cliente;
    _operadoraController.text = dive.operadoraBuceo;
    _direccionController.text = dive.direccionOperadora;
    _lugarBuceoController.text = dive.lugarBuceo;
    _supervisorController.text = dive.supervisorBuceo;
   // _tablaBuceoController.text = dive.tablaBuceo;
    //_aparatoController.text = dive.aparatoRespiratorio;
    //_presionController.text = dive.presionCilindro.toString();
    //_tipoTrajeController.text = dive.tipoTraje;
    //_mezclaController.text = dive.mezclaUtilizada;
    _visibilidadController.text = dive.visibilidad.toString();
    _tempSuperiorController.text = dive.temperaturaSuperior.toString();
    _tempAguaController.text = dive.temperaturaAgua.toString();
    _corrienteController.text = dive.corrienteAgua;
    _profundidadController.text = dive.maximaProfundidad.toString();
    _tiempoIntervalController.text = dive.tiempoIntervaloSuperficie.toString();
    _tiempoFondoController.text = dive.tiempoFondo.toString();
    _tiempoTotalController.text = dive.tiempoTotalInmersion.toString();
    _descripcionController.text = dive.descripcionTrabajo;
    _descompresionController.text = dive.descompresionUtilizada;
    _enfermedadController.text = dive.enfermedadLesion ?? '';
    _tiempoSupervisionController.text =
        dive.tiempoSupervisionAcumulado.toString();
    _tiempoBuceoAcumController.text = dive.tiempoBuceoAcumulado.toString();

    _tipoBuceoSeleccionado = dive.tipoBuceo;
    _estadoMarSeleccionado = dive.estadoMar;
    _tipoAguaSeleccionado = dive.tipoAgua;
    _horaEntrada = dive.horaEntrada;
    _horaSalida = dive.horaSalida;
    _inicioDescompresion = dive.inicioDescompresion;
    _descompresionCompleta = dive.descompresionCompleta;
    _nombreBuzos = List.from(dive.nombreBuzos);
  }

  @override
  void dispose() {
    _clienteController.dispose();
    _operadoraController.dispose();
    _direccionController.dispose();
    _lugarBuceoController.dispose();
    _supervisorController.dispose();
   // _tablaBuceoController.dispose();
    //_aparatoController.dispose();
    //_presionController.dispose();
    //_tipoTrajeController.dispose();
    //_mezclaController.dispose();
    _visibilidadController.dispose();
    _tempSuperiorController.dispose();
    _tempAguaController.dispose();
    _corrienteController.dispose();
    _profundidadController.dispose();
    _tiempoIntervalController.dispose();
    _tiempoFondoController.dispose();
    _tiempoTotalController.dispose();
    _descripcionController.dispose();
    _descompresionController.dispose();
    _enfermedadController.dispose();
    _tiempoSupervisionController.dispose();
    _tiempoBuceoAcumController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context, DateTime initialDate,
      Function(DateTime) onDateSelected) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && context.mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (time != null) {
        onDateSelected(
            DateTime(date.year, date.month, date.day, time.hour, time.minute));
      }
    }
  }

  double _parseDouble(String value) {
    if (value.trim().isEmpty) return 0.0;
    return double.tryParse(value) ?? 0.0;
  }

  Future<void> _saveDive() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, completa todos los campos requeridos')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _userService.getUserProfile();
      if (user == null) throw Exception('Usuario no encontrado');

      // Filter out empty diver names
      final buzos =
          _nombreBuzos.where((name) => name.trim().isNotEmpty).toList();
      if (buzos.isEmpty) buzos.add('Sin nombre');

      final diveSession = DiveSession(
        id: _isEditing ? widget.existingDive!.id : '',
        userId: user.id,
        cliente: _clienteController.text,
        operadoraBuceo: _operadoraController.text,
        direccionOperadora: _direccionController.text,
        lugarBuceo: _lugarBuceoController.text,
        tipoBuceo: _tipoBuceoSeleccionado,
        nombreBuzos: buzos,
        supervisorBuceo: _supervisorController.text,
        //tablaBuceo: _tablaBuceoController.text,
        //aparatoRespiratorio: _aparatoController.text,
        //presionCilindro: double.parse(_presionController.text),
        //tipoTraje: _tipoTrajeController.text,
        //mezclaUtilizada: _mezclaController.text,
        estadoMar: _estadoMarSeleccionado,
        visibilidad: _parseDouble(_visibilidadController.text),
        temperaturaSuperior: _parseDouble(_tempSuperiorController.text),
        temperaturaAgua: _parseDouble(_tempAguaController.text),
        corrienteAgua: _corrienteController.text,
        tipoAgua: _tipoAguaSeleccionado,
        horaEntrada: _horaEntrada,
        maximaProfundidad: _parseDouble(_profundidadController.text),
        tiempoIntervaloSuperficie: _parseDouble(_tiempoIntervalController.text),
        tiempoFondo: _parseDouble(_tiempoFondoController.text),
        inicioDescompresion: _inicioDescompresion,
        descompresionCompleta: _descompresionCompleta,
        tiempoTotalInmersion: _parseDouble(_tiempoTotalController.text),
        horaSalida: _horaSalida,
        descripcionTrabajo: _descripcionController.text,
        descompresionUtilizada: _descompresionController.text,
        enfermedadLesion: _enfermedadController.text.isEmpty
            ? null
            : _enfermedadController.text,
        tiempoSupervisionAcumulado:
            _parseDouble(_tiempoSupervisionController.text),
        tiempoBuceoAcumulado: _parseDouble(_tiempoBuceoAcumController.text),
        createdAt: _isEditing ? widget.existingDive!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (_isEditing) {
        await _diveService.updateDiveSession(diveSession);
      } else {
        await _diveService.createDiveSession(diveSession);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  _isEditing ? 'Inmersión actualizada' : 'Inmersión guardada')),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error saving dive: $e\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Inmersión' : 'Nueva Inmersión'),
        actions: [
          if (_isEditing && !_isLoading)
            PopupMenuButton<String>(
              icon: const Icon(Icons.share),
              tooltip: 'Exportar',
              onSelected: (value) async {
                if (widget.existingDive == null) return;
                
                setState(() => _isLoading = true);
                try {
                  if (value == 'pdf') {
                    await _exportService.exportDiveToPdf(widget.existingDive!);
                  } else if (value == 'csv') {
                    await _exportService.exportDiveToCsv(widget.existingDive!);
                  }
                } catch (e) {
                   if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al exportar: $e')),
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
                      Text('Exportar PDF'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'csv',
                  child: Row(
                    children: [
                      Icon(Icons.table_chart, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Exportar CSV'),
                    ],
                  ),
                ),
              ],
            ),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveDive,
              tooltip: 'Guardar',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: AppSpacing.paddingMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(context, '📋 Información General'),
              _buildGeneralInfoSection(),
              const SizedBox(height: AppSpacing.lg),
              //_buildSectionHeader(context, '🤿 Equipo de Buceo'),
              //_buildEquipmentSection(),
              //const SizedBox(height: AppSpacing.lg),
              //_buildSectionHeader(context, '🌊 Condiciones del Agua'),
              //_buildWaterConditionsSection(),
              //const SizedBox(height: AppSpacing.lg),
              _buildSectionHeader(context, '⏱️ Detalles de la Inmersión'),
              _buildDiveDetailsSection(context),
              const SizedBox(height: AppSpacing.lg),
              _buildSectionHeader(context, '🔧 Trabajo y Seguridad'),
              _buildWorkSafetySection(),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        title,
        style: context.textStyles.titleLarge!.semiBold,
      ),
    );
  }

  Widget _buildGeneralInfoSection() {
    return Column(
      children: [
        _buildTextField(
          controller: _clienteController,
          label: 'Cliente',
          icon: Icons.person,
          required: true,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildTextField(
          controller: _operadoraController,
          label: 'Operadora de Buceo',
          icon: Icons.business,
          required: true,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildTextField(
          controller: _direccionController,
          label: 'Dirección de la Operadora',
          icon: Icons.location_on,
          required: true,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildTextField(
          controller: _lugarBuceoController,
          label: 'Lugar de Buceo',
          icon: Icons.place,
          required: true,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildDropdown(
          value: _tipoBuceoSeleccionado,
          label: 'Tipo de Buceo',
          icon: Icons.scuba_diving,
          items: [
            'Scuba',
            'Asist. Superficie',
            'Altura Geográfica',
            'Saturación'
          ],
          onChanged: (value) => setState(() => _tipoBuceoSeleccionado = value!),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildDiversSection(),
        const SizedBox(height: AppSpacing.md),
        _buildTextField(
          controller: _supervisorController,
          label: 'Supervisor de Buceo',
          icon: Icons.supervisor_account,
          required: true,
        ),
      ],
    );
  }

  Widget _buildDiversSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Buzos', style: Theme.of(context).textTheme.bodyLarge!.medium),
            TextButton.icon(
              onPressed: () => setState(() => _nombreBuzos.add('')),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Agregar'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ..._nombreBuzos.asMap().entries.map((entry) {
          final index = entry.key;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: entry.value,
                    decoration: InputDecoration(
                      labelText: 'Buzo ${index + 1}',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.3),
                    ),
                    onChanged: (value) => _nombreBuzos[index] = value,
                  ),
                ),
                if (_nombreBuzos.length > 1) ...[
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    color: Theme.of(context).colorScheme.error,
                    onPressed: () =>
                        setState(() => _nombreBuzos.removeAt(index)),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  // Widget _buildEquipmentSection() {
  //   return Column(
  //     children: [
  //       // _buildTextField(
  //       //   controller: _tablaBuceoController,
  //       //   label: 'Tabla de Buceo',
  //       //   icon: Icons.table_chart,
  //       //   required: true,
  //       // ),
  //       // const SizedBox(height: AppSpacing.md),
  //       // _buildTextField(
  //       //   controller: _aparatoController,
  //       //   label: 'Aparato Respiratorio',
  //       //   icon: Icons.masks,
  //       //   required: true,
  //       // ),
  //       // const SizedBox(height: AppSpacing.md),
  //       // _buildTextField(
  //       //   controller: _presionController,
  //       //   label: 'Presión Cilindro (bar)',
  //       //   icon: Icons.speed,
  //       //   keyboardType: TextInputType.number,
  //       //   required: true,
  //       // ),
  //       // const SizedBox(height: AppSpacing.md),
  //       // _buildTextField(
  //       //   controller: _tipoTrajeController,
  //       //   label: 'Tipo de Traje',
  //       //   icon: Icons.checkroom,
  //       //   required: true,
  //       // ),
  //       // const SizedBox(height: AppSpacing.md),
  //       // _buildTextField(
  //       //   controller: _mezclaController,
  //       //   label: 'Mezcla Utilizada',
  //       //   icon: Icons.air,
  //       //   required: true,
  //       // ),
  //    ],
  //  );
  //}

  Widget _buildWaterConditionsSection() {
    return Column(
      children: [
        _buildDropdown(
          value: _estadoMarSeleccionado,
          label: 'Estado del Mar (Escala Beaufort)',
          icon: Icons.waves,
          items: List.generate(13, (i) => i),
          itemLabels:
              List.generate(13, (i) => '$i - ${_getBeaufortDescription(i)}'),
          onChanged: (value) => setState(() => _estadoMarSeleccionado = value!),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildTextField(
          controller: _visibilidadController,
          label: 'Visibilidad (metros)',
          icon: Icons.visibility,
          keyboardType: TextInputType.number,
          required: true,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildTextField(
          controller: _tempSuperiorController,
          label: 'Temperatura Superior (°C)',
          icon: Icons.thermostat,
          keyboardType: TextInputType.number,
          required: true,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildTextField(
          controller: _tempAguaController,
          label: 'Temperatura Agua (°C)',
          icon: Icons.water,
          keyboardType: TextInputType.number,
          required: true,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildTextField(
          controller: _corrienteController,
          label: 'Corriente de Agua',
          icon: Icons.arrow_forward,
          required: true,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildDropdown(
          value: _tipoAguaSeleccionado,
          label: 'Tipo de Agua',
          icon: Icons.water_drop,
          items: ['Salada', 'Dulce', 'Salobre'],
          onChanged: (value) => setState(() => _tipoAguaSeleccionado = value!),
        ),
      ],
    );
  }

  Widget _buildDiveDetailsSection(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Column(
      children: [
        _buildDateTimeField(
          label: 'Hora de Entrada',
          icon: Icons.login,
          value: _horaEntrada,
          onTap: () => _selectDateTime(context, _horaEntrada, (date) {
            setState(() => _horaEntrada = date);
          }),
          dateFormat: dateFormat,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildDateTimeField(
          label: 'Hora de Salida',
          icon: Icons.logout,
          value: _horaSalida,
          onTap: () => _selectDateTime(context, _horaSalida, (date) {
            setState(() => _horaSalida = date);
          }),
          dateFormat: dateFormat,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildTextField(
          controller: _profundidadController,
          label: 'Máxima Profundidad (metros)',
          icon: Icons.arrow_downward,
          keyboardType: TextInputType.number,
          required: true,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildTextField(
          controller: _tiempoIntervalController,
          label: 'Tiempo de Intervalo en Superficie (min)',
          icon: Icons.timer,
          keyboardType: TextInputType.number,
          required: true,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildTextField(
          controller: _tiempoFondoController,
          label: 'Tiempo de Fondo (min)',
          icon: Icons.schedule,
          keyboardType: TextInputType.number,
          required: true,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildTextField(
          controller: _tiempoTotalController,
          label: 'Tiempo Total de Inmersión (min)',
          icon: Icons.hourglass_full,
          keyboardType: TextInputType.number,
          required: true,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildDateTimeField(
          label: 'Inicio de Descompresión (Opcional)',
          icon: Icons.access_time,
          value: _inicioDescompresion,
          onTap: () => _selectDateTime(
              context, _inicioDescompresion ?? DateTime.now(), (date) {
            setState(() => _inicioDescompresion = date);
          }),
          dateFormat: dateFormat,
          optional: true,
          onClear: () => setState(() => _inicioDescompresion = null),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildDateTimeField(
          label: 'Descompresión Completa (Opcional)',
          icon: Icons.check_circle_outline,
          value: _descompresionCompleta,
          onTap: () => _selectDateTime(
              context, _descompresionCompleta ?? DateTime.now(), (date) {
            setState(() => _descompresionCompleta = date);
          }),
          dateFormat: dateFormat,
          optional: true,
          onClear: () => setState(() => _descompresionCompleta = null),
        ),
      ],
    );
  }

  Widget _buildWorkSafetySection() {
    return Column(
      children: [
        _buildTextField(
          controller: _descripcionController,
          label: 'Descripción del Trabajo',
          icon: Icons.description,
          maxLines: 3,
          required: true,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildTextField(
          controller: _descompresionController,
          label: 'Descompresión Utilizada',
          icon: Icons.safety_check,
          required: true,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildTextField(
          controller: _enfermedadController,
          label: 'Enfermedad o Lesión (Opcional)',
          icon: Icons.medical_services,
          maxLines: 2,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildTextField(
          controller: _tiempoSupervisionController,
          label: 'Tiempo de Supervisión Acumulado (hrs)',
          icon: Icons.watch_later,
          keyboardType: TextInputType.number,
          required: true,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildTextField(
          controller: _tiempoBuceoAcumController,
          label: 'Tiempo de Buceo Acumulado (hrs)',
          icon: Icons.access_alarm,
          keyboardType: TextInputType.number,
          required: true,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.3),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: required
          ? (value) => value?.isEmpty ?? true ? 'Campo requerido' : null
          : null,
      inputFormatters: keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
          : null,
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required String label,
    required IconData icon,
    required List<T> items,
    List<String>? itemLabels,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        filled: true,
        fillColor: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.3),
      ),
      items: items.asMap().entries.map((entry) {
        return DropdownMenuItem<T>(
          value: entry.value,
          child: Text(itemLabels?[entry.key] ?? entry.value.toString()),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDateTimeField({
    required String label,
    required IconData icon,
    required DateTime? value,
    required VoidCallback onTap,
    required DateFormat dateFormat,
    bool optional = false,
    VoidCallback? onClear,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: optional && value != null
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: onClear,
                )
              : const Icon(Icons.calendar_today, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          filled: true,
          fillColor: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.3),
        ),
        child: Text(
          value != null ? dateFormat.format(value) : 'Seleccionar fecha',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }

  String _getBeaufortDescription(int scale) {
    const descriptions = [
      'Calma',
      'Ventolina',
      'Brisa muy débil',
      'Brisa débil',
      'Brisa moderada',
      'Brisa fresca',
      'Brisa fuerte',
      'Viento fuerte',
      'Temporal',
      'Temporal fuerte',
      'Temporal muy fuerte',
      'Tempestad',
      'Huracán',
    ];
    return descriptions[scale];
  }
}
