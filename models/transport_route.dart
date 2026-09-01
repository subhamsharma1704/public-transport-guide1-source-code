import 'package:latlong2/latlong.dart';

class RouteStep {
  final String instruction;
  final double distanceKm;
  final double durationMins;
  final String name;

  RouteStep({
    required this.instruction,
    required this.distanceKm,
    required this.durationMins,
    required this.name,
  });

  factory RouteStep.fromJson(Map<String, dynamic> json) {
    final double distance = (json['distance'] as num?)?.toDouble() ?? 0.0;
    final double duration = (json['duration'] as num?)?.toDouble() ?? 0.0;
    final String name = json['name'] as String? ?? 'Transit Road';
    
    String instruction = 'Continue along $name';
    if (json['maneuver'] != null && json['maneuver'] is Map) {
      final man = json['maneuver'] as Map<String, dynamic>;
      final type = man['type'] ?? 'turn';
      final modifier = man['modifier'] ?? '';
      instruction = '$type $modifier on $name'.trim();
    }

    return RouteStep(
      instruction: instruction,
      distanceKm: distance / 1000.0,
      durationMins: duration / 60.0,
      name: name,
    );
  }

  Map<String, dynamic> toJson() => {
        'instruction': instruction,
        'distanceKm': distanceKm,
        'durationMins': durationMins,
        'name': name,
      };
}

class TransportRoute {
  final String id;
  final String source;
  final String destination;
  final double sourceLat;
  final double sourceLng;
  final double destLat;
  final double destLng;
  final double distanceKm;
  final double durationMinutes;
  final double estimatedFare; // In INR (₹)
  final String transportMode; // Bus, Metro, Local Train, Combined
  final List<String> intermediateStops;
  final List<RouteStep> steps;
  final List<LatLng> polylinePoints;
  final String departureTime;
  final String frequency;

  TransportRoute({
    required this.id,
    required this.source,
    required this.destination,
    required this.sourceLat,
    required this.sourceLng,
    required this.destLat,
    required this.destLng,
    required this.distanceKm,
    required this.durationMinutes,
    required this.estimatedFare,
    required this.transportMode,
    required this.intermediateStops,
    required this.steps,
    required this.polylinePoints,
    required this.departureTime,
    required this.frequency,
  });

  factory TransportRoute.fromJson(Map<String, dynamic> json) {
    var rawSteps = json['steps'] as List<dynamic>? ?? [];
    List<RouteStep> parsedSteps = rawSteps
        .map((s) => RouteStep(
              instruction: s['instruction'] ?? '',
              distanceKm: (s['distanceKm'] as num?)?.toDouble() ?? 0.0,
              durationMins: (s['durationMins'] as num?)?.toDouble() ?? 0.0,
              name: s['name'] ?? '',
            ))
        .toList();

    var rawPoints = json['polylinePoints'] as List<dynamic>? ?? [];
    List<LatLng> coords = rawPoints
        .map((p) => LatLng(
              (p['lat'] as num).toDouble(),
              (p['lng'] as num).toDouble(),
            ))
        .toList();

    return TransportRoute(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      source: json['source'] ?? '',
      destination: json['destination'] ?? '',
      sourceLat: (json['sourceLat'] as num?)?.toDouble() ?? 0.0,
      sourceLng: (json['sourceLng'] as num?)?.toDouble() ?? 0.0,
      destLat: (json['destLat'] as num?)?.toDouble() ?? 0.0,
      destLng: (json['destLng'] as num?)?.toDouble() ?? 0.0,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: (json['durationMinutes'] as num?)?.toDouble() ?? 0.0,
      estimatedFare: (json['estimatedFare'] as num?)?.toDouble() ?? 0.0,
      transportMode: json['transportMode'] ?? 'Bus',
      intermediateStops: (json['intermediateStops'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      steps: parsedSteps,
      polylinePoints: coords,
      departureTime: json['departureTime'] ?? 'Every 10-15 mins',
      frequency: json['frequency'] ?? 'High Frequency',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'source': source,
        'destination': destination,
        'sourceLat': sourceLat,
        'sourceLng': sourceLng,
        'destLat': destLat,
        'destLng': destLng,
        'distanceKm': distanceKm,
        'durationMinutes': durationMinutes,
        'estimatedFare': estimatedFare,
        'transportMode': transportMode,
        'intermediateStops': intermediateStops,
        'steps': steps.map((s) => s.toJson()).toList(),
        'polylinePoints': polylinePoints
            .map((p) => {'lat': p.latitude, 'lng': p.longitude})
            .toList(),
        'departureTime': departureTime,
        'frequency': frequency,
      };
}
