import 'package:flutter_test/flutter_test.dart';
import 'package:divelogtest/services/dive_service.dart';
import 'package:divelogtest/models/dive_session.dart';

void main() {
  group('DiveService Statistics', () {
    test('calculateStatistics returns zeros for empty list', () {
      final stats = DiveService.calculateStatistics([]);
      expect(stats['totalDives'], 0);
      expect(stats['totalBottomTime'], 0.0);
      expect(stats['deepestDive'], 0.0);
      expect(stats['averageDepth'], 0.0);
    });

    test('calculateStatistics calculates correctly for single session', () {
      final session = _createSession(depth: 20.0, bottomTime: 45.0);
      final stats = DiveService.calculateStatistics([session]);

      expect(stats['totalDives'], 1);
      expect(stats['totalBottomTime'], 45.0);
      expect(stats['deepestDive'], 20.0);
      expect(stats['averageDepth'], 20.0);
    });

    test('calculateStatistics calculates correctly for multiple sessions', () {
      final sessions = [
        _createSession(depth: 10.0, bottomTime: 30.0),
        _createSession(depth: 30.0, bottomTime: 40.0), // Deepest
        _createSession(depth: 20.0, bottomTime: 20.0),
      ];
      final stats = DiveService.calculateStatistics(sessions);

      expect(stats['totalDives'], 3);
      expect(stats['totalBottomTime'], 30.0 + 40.0 + 20.0); // 90.0
      expect(stats['deepestDive'], 30.0);
      expect(stats['averageDepth'], (10 + 30 + 20) / 3); // 20.0
    });
  });
}

DiveSession _createSession({required double depth, required double bottomTime}) {
  return DiveSession(
    id: 'test-id',
    userId: 'user-id',
    cliente: 'Test Client',
    operadoraBuceo: 'Test Op',
    direccionOperadora: 'Address',
    lugarBuceo: 'Location',
    tipoBuceo: 'Scuba',
    nombreBuzos: ['Diver 1'],
    supervisorBuceo: 'Supervisor',
    estadoMar: 1,
    visibilidad: 10,
    temperaturaSuperior: 20,
    temperaturaAgua: 20,
    corrienteAgua: 'None',
    tipoAgua: 'Salt',
    horaEntrada: DateTime.now(),
    maximaProfundidad: depth,
    tiempoIntervaloSuperficie: 0,
    tiempoFondo: bottomTime,
    tiempoTotalInmersion: bottomTime + 5,
    horaSalida: DateTime.now().add(Duration(minutes: bottomTime.toInt() + 5)),
    descripcionTrabajo: 'Work',
    descompresionUtilizada: 'None',
    tiempoSupervisionAcumulado: 0,
    tiempoBuceoAcumulado: 0,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}
