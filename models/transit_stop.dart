class TransitStop {
  final String id;
  final String name;
  final String type; // bus_stop, station, tram_stop, subway
  final double lat;
  final double lng;
  final String? operator;
  final String? lineInfo;
  final double? distanceInKm;

  TransitStop({
    required this.id,
    required this.name,
    required this.type,
    required this.lat,
    required this.lng,
    this.operator,
    this.lineInfo,
    this.distanceInKm,
  });

  factory TransitStop.fromOverpassJson(Map<String, dynamic> json, {double? userLat, double? userLng}) {
    final tags = json['tags'] as Map<String, dynamic>? ?? {};
    final String name = tags['name'] ??
        tags['name:en'] ??
        tags['operator'] ??
        tags['ref'] ??
        'Public Transit Stop';

    String type = 'Bus Stop';
    final highway = tags['highway'];
    final railway = tags['railway'];
    final publicTransport = tags['public_transport'];

    if (railway == 'station' || railway == 'subway_entrance' || railway == 'subway') {
      type = 'Metro / Train Station';
    } else if (publicTransport == 'station' || highway == 'bus_station') {
      type = 'Bus Terminal';
    } else if (railway == 'tram_stop') {
      type = 'Tram Stop';
    } else {
      type = 'Bus Stop';
    }

    double lat = 0.0;
    double lng = 0.0;
    if (json['lat'] != null && json['lon'] != null) {
      lat = (json['lat'] as num).toDouble();
      lng = (json['lon'] as num).toDouble();
    } else if (json['center'] != null) {
      lat = (json['center']['lat'] as num).toDouble();
      lng = (json['center']['lon'] as num).toDouble();
    }

    return TransitStop(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      type: type,
      lat: lat,
      lng: lng,
      operator: tags['operator'] ?? tags['network'],
      lineInfo: tags['route_ref'] ?? tags['bus_routes'] ?? tags['lines'],
      distanceInKm: null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'lat': lat,
        'lng': lng,
        'operator': operator,
        'lineInfo': lineInfo,
        'distanceInKm': distanceInKm,
      };

  factory TransitStop.fromJson(Map<String, dynamic> json) => TransitStop(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        type: json['type'] ?? 'Bus Stop',
        lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
        lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
        operator: json['operator'],
        lineInfo: json['lineInfo'],
        distanceInKm: (json['distanceInKm'] as num?)?.toDouble(),
      );
}
