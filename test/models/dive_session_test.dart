import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:divelogtest/models/dive_session.dart';

void main() {
  group('DiveSession serialization', () {
    final base = DiveSession(
      id: 'id-1',
      userId: 'user-1',
      cliente: 'Cliente',
      operadoraBuceo: 'Operadora',
      direccionOperadora: 'Dirección',
      lugarBuceo: 'Lugar',
      tipoBuceo: 'Scuba',
      nombreBuzos: ['A', 'B'],
      supervisorBuceo: 'Supervisor',
      estadoMar: 2,
      visibilidad: 20.5,
      temperaturaSuperior: 27.0,
      temperaturaAgua: 25.0,
      corrienteAgua: 'Leve',
      tipoAgua: 'Salada',
      horaEntrada: DateTime.parse('2024-01-02T10:00:00Z'),
      maximaProfundidad: 18.2,
      tiempoIntervaloSuperficie: 60.0,
      tiempoFondo: 35.0,
      inicioDescompresion: null,
      descompresionCompleta: null,
      tiempoTotalInmersion: 42.0,
      horaSalida: DateTime.parse('2024-01-02T10:42:00Z'),
      descripcionTrabajo: 'Desc',
      descompresionUtilizada: 'Ninguna',
      enfermedadLesion: null,
      tiempoSupervisionAcumulado: 2.0,
      tiempoBuceoAcumulado: 0.7,
      createdAt: DateTime.parse('2024-01-02T10:00:00Z'),
      updatedAt: DateTime.parse('2024-01-02T10:00:00Z'),
    );

    test('toJson -> fromJson round-trip preserves fields', () {
      final map = base.toJson();
      final decoded = DiveSession.fromJson(map);

      expect(decoded.id, base.id);
      expect(decoded.userId, base.userId);
      expect(decoded.nombreBuzos, base.nombreBuzos);
      expect(decoded.maximaProfundidad, base.maximaProfundidad);
      expect(decoded.tiempoTotalInmersion, base.tiempoTotalInmersion);
      expect(decoded.horaEntrada.toIso8601String(), base.horaEntrada.toIso8601String());
    });

    test('fromJson supports nombreBuzos as JSON-encoded String', () {
      final map = base.toJson();
      // Store list as JSON string (simulating SQLite TEXT column)
      map['nombreBuzos'] = jsonEncode(map['nombreBuzos']);

      final decoded = DiveSession.fromJson(map);
      expect(decoded.nombreBuzos, ['A', 'B']);
    });

    test('fromJson falls back when nombreBuzos is a plain string', () {
      final map = base.toJson();
      map['nombreBuzos'] = 'SingleName';
      final decoded = DiveSession.fromJson(map);
      expect(decoded.nombreBuzos, ['SingleName']);
    });
  });
}
