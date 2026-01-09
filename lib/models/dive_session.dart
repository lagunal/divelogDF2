import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class DiveSession {
  final String id;
  final String userId;
  
  // General Information
  final String cliente;
  final String operadoraBuceo;
  final String direccionOperadora;
  final String lugarBuceo;
  final String tipoBuceo; // Scuba, Asist. Superficie, Altura Geográfica, Saturación
  final List<String> nombreBuzos;
  final String supervisorBuceo;
  
  // Equipment and Conditions
  //final String tablaBuceo;
  //final String aparatoRespiratorio;
  //final double presionCilindro;
  //final String tipoTraje;
  //final String mezclaUtilizada;
  
  // Water Conditions
  final int estadoMar; // Escala Beaufort (0-12)
  final double visibilidad; // in meters
  final double temperaturaSuperior; // in Celsius
  final double temperaturaAgua; // in Celsius
  final String corrienteAgua;
  final String tipoAgua; // fresh, salt, etc.
  
  // Dive Details
  final DateTime horaEntrada;
  final double maximaProfundidad; // in meters
  final double tiempoIntervaloSuperficie; // in minutes
  final double tiempoFondo; // in minutes
  final DateTime? inicioDescompresion;
  final DateTime? descompresionCompleta;
  final double tiempoTotalInmersion; // in minutes
  final DateTime horaSalida;
  
  // Work and Safety
  final String descripcionTrabajo;
  final String descompresionUtilizada;
  final String? enfermedadLesion;
  final double tiempoSupervisionAcumulado; // in hours
  final double tiempoBuceoAcumulado; // in hours
  
  // Sync Status (Local only)
  final bool isSynced;
  final DateTime? lastSyncedAt;
  
  final DateTime createdAt;
  final DateTime updatedAt;

  DiveSession({
    required this.id,
    required this.userId,
    required this.cliente,
    required this.operadoraBuceo,
    required this.direccionOperadora,
    required this.lugarBuceo,
    required this.tipoBuceo,
    required this.nombreBuzos,
    required this.supervisorBuceo,
    //required this.tablaBuceo,
    //required this.aparatoRespiratorio,
    //required this.presionCilindro,
    //required this.tipoTraje,
    //required this.mezclaUtilizada,
    required this.estadoMar,
    required this.visibilidad,
    required this.temperaturaSuperior,
    required this.temperaturaAgua,
    required this.corrienteAgua,
    required this.tipoAgua,
    required this.horaEntrada,
    required this.maximaProfundidad,
    required this.tiempoIntervaloSuperficie,
    required this.tiempoFondo,
    this.inicioDescompresion,
    this.descompresionCompleta,
    required this.tiempoTotalInmersion,
    required this.horaSalida,
    required this.descripcionTrabajo,
    required this.descompresionUtilizada,
    this.enfermedadLesion,
    required this.tiempoSupervisionAcumulado,
    required this.tiempoBuceoAcumulado,
    this.isSynced = false,
    this.lastSyncedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toFirestore() => {
    'id': id,
    'userId': userId,
    'cliente': cliente,
    'operadoraBuceo': operadoraBuceo,
    'direccionOperadora': direccionOperadora,
    'lugarBuceo': lugarBuceo,
    'tipoBuceo': tipoBuceo,
    'nombreBuzos': nombreBuzos,
    'supervisorBuceo': supervisorBuceo,
    'estadoMar': estadoMar,
    'visibilidad': visibilidad,
    'temperaturaSuperior': temperaturaSuperior,
    'temperaturaAgua': temperaturaAgua,
    'corrienteAgua': corrienteAgua,
    'tipoAgua': tipoAgua,
    'horaEntrada': Timestamp.fromDate(horaEntrada),
    'maximaProfundidad': maximaProfundidad,
    'tiempoIntervaloSuperficie': tiempoIntervaloSuperficie,
    'tiempoFondo': tiempoFondo,
    'inicioDescompresion': inicioDescompresion != null ? Timestamp.fromDate(inicioDescompresion!) : null,
    'descompresionCompleta': descompresionCompleta != null ? Timestamp.fromDate(descompresionCompleta!) : null,
    'tiempoTotalInmersion': tiempoTotalInmersion,
    'horaSalida': Timestamp.fromDate(horaSalida),
    'descripcionTrabajo': descripcionTrabajo,
    'descompresionUtilizada': descompresionUtilizada,
    'enfermedadLesion': enfermedadLesion,
    'tiempoSupervisionAcumulado': tiempoSupervisionAcumulado,
    'tiempoBuceoAcumulado': tiempoBuceoAcumulado,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'cliente': cliente,
    'operadoraBuceo': operadoraBuceo,
    'direccionOperadora': direccionOperadora,
    'lugarBuceo': lugarBuceo,
    'tipoBuceo': tipoBuceo,
    'nombreBuzos': nombreBuzos,
    'supervisorBuceo': supervisorBuceo,
    //'tablaBuceo': tablaBuceo,
    //'aparatoRespiratorio': aparatoRespiratorio,
    //'presionCilindro': presionCilindro,
    //'tipoTraje': tipoTraje,
    //'mezclaUtilizada': mezclaUtilizada,
    'estadoMar': estadoMar,
    'visibilidad': visibilidad,
    'temperaturaSuperior': temperaturaSuperior,
    'temperaturaAgua': temperaturaAgua,
    'corrienteAgua': corrienteAgua,
    'tipoAgua': tipoAgua,
    'horaEntrada': horaEntrada.toIso8601String(),
    'maximaProfundidad': maximaProfundidad,
    'tiempoIntervaloSuperficie': tiempoIntervaloSuperficie,
    'tiempoFondo': tiempoFondo,
    'inicioDescompresion': inicioDescompresion?.toIso8601String(),
    'descompresionCompleta': descompresionCompleta?.toIso8601String(),
    'tiempoTotalInmersion': tiempoTotalInmersion,
    'horaSalida': horaSalida.toIso8601String(),
    'descripcionTrabajo': descripcionTrabajo,
    'descompresionUtilizada': descompresionUtilizada,
    'enfermedadLesion': enfermedadLesion,
    'tiempoSupervisionAcumulado': tiempoSupervisionAcumulado,
    'tiempoBuceoAcumulado': tiempoBuceoAcumulado,
    'isSynced': isSynced ? 1 : 0, // SQLite stores bool as INTEGER
    'lastSyncedAt': lastSyncedAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory DiveSession.fromJson(Map<String, dynamic> json) {
    // Handle nombreBuzos which can be List (from Web/JSON) or String (from SQLite)
    List<String> parsedBuzos;
    if (json['nombreBuzos'] is String) {
      try {
        final decoded = jsonDecode(json['nombreBuzos'] as String);
        if (decoded is List) {
          parsedBuzos = List<String>.from(decoded);
        } else {
          // Fallback if decode result is not a list
          parsedBuzos = [json['nombreBuzos'] as String];
        }
      } catch (e) {
        // Fallback if not valid JSON
        parsedBuzos = [json['nombreBuzos'] as String];
      }
    } else {
      parsedBuzos = List<String>.from(json['nombreBuzos'] as List? ?? []);
    }

    return DiveSession(
      id: json['id'] as String,
      userId: json['userId'] as String,
      cliente: json['cliente'] as String,
      operadoraBuceo: json['operadoraBuceo'] as String,
      direccionOperadora: json['direccionOperadora'] as String,
      lugarBuceo: json['lugarBuceo'] as String,
      tipoBuceo: json['tipoBuceo'] as String,
      nombreBuzos: parsedBuzos,
      supervisorBuceo: json['supervisorBuceo'] as String,
      //tablaBuceo: json['tablaBuceo'] as String,
      //aparatoRespiratorio: json['aparatoRespiratorio'] as String,
      //presionCilindro: (json['presionCilindro'] as num).toDouble(),
      //tipoTraje: json['tipoTraje'] as String,
      //mezclaUtilizada: json['mezclaUtilizada'] as String,
      estadoMar: json['estadoMar'] as int,
      visibilidad: (json['visibilidad'] as num).toDouble(),
      temperaturaSuperior: (json['temperaturaSuperior'] as num).toDouble(),
      temperaturaAgua: (json['temperaturaAgua'] as num).toDouble(),
      corrienteAgua: json['corrienteAgua'] as String,
      tipoAgua: json['tipoAgua'] as String,
      horaEntrada: DateTime.parse(json['horaEntrada'] as String),
      maximaProfundidad: (json['maximaProfundidad'] as num).toDouble(),
      tiempoIntervaloSuperficie: (json['tiempoIntervaloSuperficie'] as num).toDouble(),
      tiempoFondo: (json['tiempoFondo'] as num).toDouble(),
      inicioDescompresion: json['inicioDescompresion'] != null 
        ? DateTime.parse(json['inicioDescompresion'] as String) 
        : null,
      descompresionCompleta: json['descompresionCompleta'] != null 
        ? DateTime.parse(json['descompresionCompleta'] as String) 
        : null,
      tiempoTotalInmersion: (json['tiempoTotalInmersion'] as num).toDouble(),
      horaSalida: DateTime.parse(json['horaSalida'] as String),
      descripcionTrabajo: json['descripcionTrabajo'] as String,
      descompresionUtilizada: json['descompresionUtilizada'] as String,
      enfermedadLesion: json['enfermedadLesion'] as String?,
      tiempoSupervisionAcumulado: (json['tiempoSupervisionAcumulado'] as num).toDouble(),
      tiempoBuceoAcumulado: (json['tiempoBuceoAcumulado'] as num).toDouble(),
      isSynced: (json['isSynced'] as int? ?? 0) == 1,
      lastSyncedAt: json['lastSyncedAt'] != null 
        ? DateTime.parse(json['lastSyncedAt'] as String) 
        : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  factory DiveSession.fromFirestore(Map<String, dynamic> data) => DiveSession(
    id: data['id'] as String,
    userId: data['userId'] as String,
    cliente: data['cliente'] as String,
    operadoraBuceo: data['operadoraBuceo'] as String,
    direccionOperadora: data['direccionOperadora'] as String,
    lugarBuceo: data['lugarBuceo'] as String,
    tipoBuceo: data['tipoBuceo'] as String,
    nombreBuzos: List<String>.from(data['nombreBuzos'] as List? ?? []),
    supervisorBuceo: data['supervisorBuceo'] as String,
    estadoMar: data['estadoMar'] as int,
    visibilidad: (data['visibilidad'] as num).toDouble(),
    temperaturaSuperior: (data['temperaturaSuperior'] as num).toDouble(),
    temperaturaAgua: (data['temperaturaAgua'] as num).toDouble(),
    corrienteAgua: data['corrienteAgua'] as String,
    tipoAgua: data['tipoAgua'] as String,
    horaEntrada: (data['horaEntrada'] as Timestamp).toDate(),
    maximaProfundidad: (data['maximaProfundidad'] as num).toDouble(),
    tiempoIntervaloSuperficie: (data['tiempoIntervaloSuperficie'] as num).toDouble(),
    tiempoFondo: (data['tiempoFondo'] as num).toDouble(),
    inicioDescompresion: data['inicioDescompresion'] != null ? (data['inicioDescompresion'] as Timestamp).toDate() : null,
    descompresionCompleta: data['descompresionCompleta'] != null ? (data['descompresionCompleta'] as Timestamp).toDate() : null,
    tiempoTotalInmersion: (data['tiempoTotalInmersion'] as num).toDouble(),
    horaSalida: (data['horaSalida'] as Timestamp).toDate(),
    descripcionTrabajo: data['descripcionTrabajo'] as String,
    descompresionUtilizada: data['descompresionUtilizada'] as String,
    enfermedadLesion: data['enfermedadLesion'] as String?,
    tiempoSupervisionAcumulado: (data['tiempoSupervisionAcumulado'] as num).toDouble(),
    tiempoBuceoAcumulado: (data['tiempoBuceoAcumulado'] as num).toDouble(),
    isSynced: true, // Data from Firestore is by definition synced
    lastSyncedAt: DateTime.now(), // Mark as synced just now
    createdAt: (data['createdAt'] as Timestamp).toDate(),
    updatedAt: (data['updatedAt'] as Timestamp).toDate(),
  );

  DiveSession copyWith({
    String? id,
    String? userId,
    String? cliente,
    String? operadoraBuceo,
    String? direccionOperadora,
    String? lugarBuceo,
    String? tipoBuceo,
    List<String>? nombreBuzos,
    String? supervisorBuceo,
    //String? tablaBuceo,
    //String? aparatoRespiratorio,
    //double? presionCilindro,
    //String? tipoTraje,
    //String? mezclaUtilizada,
    int? estadoMar,
    double? visibilidad,
    double? temperaturaSuperior,
    double? temperaturaAgua,
    String? corrienteAgua,
    String? tipoAgua,
    DateTime? horaEntrada,
    double? maximaProfundidad,
    double? tiempoIntervaloSuperficie,
    double? tiempoFondo,
    DateTime? inicioDescompresion,
    DateTime? descompresionCompleta,
    double? tiempoTotalInmersion,
    DateTime? horaSalida,
    String? descripcionTrabajo,
    String? descompresionUtilizada,
    String? enfermedadLesion,
    double? tiempoSupervisionAcumulado,
    double? tiempoBuceoAcumulado,
    bool? isSynced,
    DateTime? lastSyncedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DiveSession(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    cliente: cliente ?? this.cliente,
    operadoraBuceo: operadoraBuceo ?? this.operadoraBuceo,
    direccionOperadora: direccionOperadora ?? this.direccionOperadora,
    lugarBuceo: lugarBuceo ?? this.lugarBuceo,
    tipoBuceo: tipoBuceo ?? this.tipoBuceo,
    nombreBuzos: nombreBuzos ?? this.nombreBuzos,
    supervisorBuceo: supervisorBuceo ?? this.supervisorBuceo,
    //tablaBuceo: tablaBuceo ?? this.tablaBuceo,
    //aparatoRespiratorio: aparatoRespiratorio ?? this.aparatoRespiratorio,
    //presionCilindro: presionCilindro ?? this.presionCilindro,
    //tipoTraje: tipoTraje ?? this.tipoTraje,
    //mezclaUtilizada: mezclaUtilizada ?? this.mezclaUtilizada,
    estadoMar: estadoMar ?? this.estadoMar,
    visibilidad: visibilidad ?? this.visibilidad,
    temperaturaSuperior: temperaturaSuperior ?? this.temperaturaSuperior,
    temperaturaAgua: temperaturaAgua ?? this.temperaturaAgua,
    corrienteAgua: corrienteAgua ?? this.corrienteAgua,
    tipoAgua: tipoAgua ?? this.tipoAgua,
    horaEntrada: horaEntrada ?? this.horaEntrada,
    maximaProfundidad: maximaProfundidad ?? this.maximaProfundidad,
    tiempoIntervaloSuperficie: tiempoIntervaloSuperficie ?? this.tiempoIntervaloSuperficie,
    tiempoFondo: tiempoFondo ?? this.tiempoFondo,
    inicioDescompresion: inicioDescompresion ?? this.inicioDescompresion,
    descompresionCompleta: descompresionCompleta ?? this.descompresionCompleta,
    tiempoTotalInmersion: tiempoTotalInmersion ?? this.tiempoTotalInmersion,
    horaSalida: horaSalida ?? this.horaSalida,
    descripcionTrabajo: descripcionTrabajo ?? this.descripcionTrabajo,
    descompresionUtilizada: descompresionUtilizada ?? this.descompresionUtilizada,
    enfermedadLesion: enfermedadLesion ?? this.enfermedadLesion,
    tiempoSupervisionAcumulado: tiempoSupervisionAcumulado ?? this.tiempoSupervisionAcumulado,
    tiempoBuceoAcumulado: tiempoBuceoAcumulado ?? this.tiempoBuceoAcumulado,
    isSynced: isSynced ?? this.isSynced,
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
