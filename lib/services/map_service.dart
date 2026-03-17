import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class MapService {
  static GoogleMapController? _mapController;
  static LatLng _currentPosition = const LatLng(55.7558, 37.6173); // Москва по умолчанию
  
  // Маркеры
  static final Set<Marker> _markers = {};
  static final Set<Polyline> _polylines = {};
  static final Set<Circle> _circles = {};

  // Настройки карты
  static const CameraPosition _defaultPosition = CameraPosition(
    target: LatLng(55.7558, 37.6173),
    zoom: 14,
  );

  // Получить контроллер карты
  static GoogleMapController? get mapController => _mapController;

  // Получить текущую позицию
  static LatLng get currentPosition => _currentPosition;

  // Получить маркеры
  static Set<Marker> get markers => _markers;

  // Получить полилинии
  static Set<Polyline> get polylines => _polylines;

  // Получить круги
  static Set<Circle> get circles => _circles;

  // Инициализация карты
  static CameraPosition getDefaultPosition() {
    return _defaultPosition;
  }

  // Обновить контроллер
  static void updateController(GoogleMapController controller) {
    _mapController = controller;
  }

  // Обновить текущую позицию
  static void updateCurrentPosition(double lat, double lng) {
    _currentPosition = LatLng(lat, lng);
  }

  // Переместить камеру к позиции
  static Future<void> animateToPosition(
    double lat,
    double lng, {
    double zoom = 15,
  }) async {
    if (_mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(lat, lng), zoom),
      );
    }
  }

  // Переместить камеру к текущей позиции пользователя
  static Future<void> animateToMyLocation() async {
    await animateToPosition(
      _currentPosition.latitude,
      _currentPosition.longitude,
    );
  }

  // Получить текущее местоположение
  static Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (e) {
      return null;
    }
  }

  // Добавить маркер точки отправления
  static void addStartMarker(double lat, double lng, String title) {
    _markers.add(
      Marker(
        markerId: const MarkerId('start'),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: title),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );
  }

  // Добавить маркер точки назначения
  static void addEndMarker(double lat, double lng, String title) {
    _markers.add(
      Marker(
        markerId: const MarkerId('end'),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: title),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
  }

  // Добавить маркер водителя
  static void addDriverMarker(double lat, double lng, String driverName) {
    _markers.add(
      Marker(
        markerId: const MarkerId('driver'),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: driverName),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );
  }

  // Очистить все маркеры
  static void clearMarkers() {
    _markers.clear();
  }

  // Добавить маршрут (полилиния)
  static void addRoute(List<LatLng> points, {Color color = Colors.blue}) {
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: points,
        color: color,
        width: 4,
      ),
    );
  }

  // Очистить маршрут
  static void clearRoute() {
    _polylines.clear();
  }

  // Добавить круг вокруг точки
  static void addCircle(double lat, double lng, double radiusMeters) {
    _circles.add(
      Circle(
        circleId: const CircleId('search_radius'),
        center: LatLng(lat, lng),
        radius: radiusMeters,
        fillColor: Colors.blue.withOpacity(0.1),
        strokeColor: Colors.blue,
        strokeWidth: 2,
      ),
    );
  }

  // Очистить круги
  static void clearCircles() {
    _circles.clear();
  }

  // Очистить все элементы
  static void clearAll() {
    clearMarkers();
    clearRoute();
    clearCircles();
  }

  // Расчёт расстояния между двумя точками (в метрах)
  static double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  // Расчёт расстояния до точки от текущей позиции
  static double distanceToCurrentPosition(double lat, double lng) {
    return calculateDistance(
      _currentPosition.latitude,
      _currentPosition.longitude,
      lat,
      lng,
    );
  }

  // Оценка времени в пути (в минутах)
  static int estimateTravelTime(double distanceMeters) {
    // Средняя скорость в городе 30 км/ч = 8.33 м/с
    double speedMps = 8.33;
    double timeSeconds = distanceMeters / speedMps;
    return (timeSeconds / 60).round();
  }

  // Проверка, находится ли точка в пределах радиуса
  static bool isWithinRadius(
    double centerLat,
    double centerLng,
    double pointLat,
    double pointLng,
    double radiusMeters,
  ) {
    double distance = calculateDistance(centerLat, centerLng, pointLat, pointLng);
    return distance <= radiusMeters;
  }

  // Получить ближайшую точку на маршруте (упрощённо)
  static LatLng? getNearestPointOnRoute(
    List<LatLng> route,
    LatLng currentPosition,
  ) {
    if (route.isEmpty) return null;

    double minDistance = double.infinity;
    LatLng? nearestPoint;

    for (int i = 0; i < route.length - 1; i++) {
      LatLng point = _nearestPointOnSegment(
        currentPosition,
        route[i],
        route[i + 1],
      );
      
      double distance = calculateDistance(
        currentPosition.latitude,
        currentPosition.longitude,
        point.latitude,
        point.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestPoint = point;
      }
    }

    return nearestPoint;
  }

  // Вспомогательная функция для нахождения ближайшей точки на отрезке
  static LatLng _nearestPointOnSegment(
    LatLng point,
    LatLng start,
    LatLng end,
  ) {
    double dx = end.longitude - start.longitude;
    double dy = end.latitude - start.latitude;
    
    if (dx == 0 && dy == 0) {
      return start;
    }

    double t = ((point.longitude - start.longitude) * dx + 
                (point.latitude - start.latitude) * dy) / 
               (dx * dx + dy * dy);
    
    t = t.clamp(0.0, 1.0);
    
    return LatLng(
      start.latitude + t * dy,
      start.longitude + t * dx,
    );
  }

  // Форматирование расстояния для отображения
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} м';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} км';
    }
  }

  // Форматирование времени для отображения
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes мин';
    } else {
      int hours = minutes ~/ 60;
      int mins = minutes % 60;
      if (mins == 0) {
        return '$hours ч';
      }
      return '$hours ч $mins мин';
    }
  }

  // Расчёт стоимости поездки
  static double calculatePrice(
    double distanceMeters,
    String tariff, {
    double basePrice = 99,
    double pricePerKm = 15,
  }) {
    double distanceKm = distanceMeters / 1000;
    double price;

    switch (tariff) {
      case 'econom':
        basePrice = 99;
        pricePerKm = 15;
        break;
      case 'comfort':
        basePrice = 199;
        pricePerKm = 20;
        break;
      case 'business':
        basePrice = 399;
        pricePerKm = 30;
        break;
      case 'premium':
        basePrice = 799;
        pricePerKm = 45;
        break;
      default:
        basePrice = 99;
        pricePerKm = 15;
    }

    price = basePrice + (distanceKm * pricePerKm);
    return price.roundToDouble();
  }
}
