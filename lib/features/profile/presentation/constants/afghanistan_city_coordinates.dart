import 'package:latlong2/latlong.dart';

/// Approximate city centers in Afghanistan for map defaults.
abstract final class AfghanistanCityCoordinates {
  static const LatLng kabul = LatLng(34.5553, 69.2075);
  static const LatLng defaultCenter = kabul;

  static const Map<String, LatLng> byCity = {
    'کابل': LatLng(34.5553, 69.2075),
    'هرات': LatLng(34.3482, 62.1997),
    'مزار شریف': LatLng(36.7081, 67.1108),
    'قندهار': LatLng(31.6289, 65.7372),
    'جلال‌آباد': LatLng(34.4265, 70.4515),
    'کندز': LatLng(36.7289, 68.8681),
    'غزنی': LatLng(33.5508, 68.4225),
    'پلخمری': LatLng(35.9446, 68.7151),
    'بامیان': LatLng(34.8216, 67.8273),
    'خوست': LatLng(33.3395, 69.9204),
    'تخار': LatLng(36.7361, 69.5345),
    'بدخشان': LatLng(37.1166, 70.5800),
    'فاریاب': LatLng(36.1307, 64.8565),
    'سایر': kabul,
  };

  static LatLng forCity(String city) => byCity[city] ?? defaultCenter;
}
