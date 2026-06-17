import 'package:latlong2/latlong.dart';

class BlossomData {
  final LatLng position;
  final double scale;
  final double rotation;
  final DateTime timestamp;

  const BlossomData({
    required this.position,
    required this.scale,
    required this.rotation,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'lat': position.latitude,
        'lng': position.longitude,
        'scale': scale,
        'rotation': rotation,
        'timestamp': timestamp.toIso8601String(),
      };

  factory BlossomData.fromJson(Map<String, dynamic> json) => BlossomData(
        position: LatLng(json['lat'] as double, json['lng'] as double),
        scale: json['scale'] as double,
        rotation: json['rotation'] as double,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

sealed class BlossomState {
  final List<BlossomData> blossoms;

  const BlossomState(this.blossoms);
}

class BlossomUpdated extends BlossomState {
  const BlossomUpdated(super.blossoms);
}
