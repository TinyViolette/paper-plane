import 'package:latlong2/latlong.dart';

sealed class BurnMarkState {
  final List<LatLng> burnMarks;

  const BurnMarkState(this.burnMarks);
}

class BurnMarkUpdated extends BurnMarkState {
  const BurnMarkUpdated(super.burnMarks);
}
