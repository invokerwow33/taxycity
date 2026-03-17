import 'package:geolocator/geolocator.dart';

class LocationService {
  // Проверка и запрос разрешений на геолокацию
  static Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    
    return true;
  }

  // Получение текущего местоположения
  static Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await checkAndRequestPermission();
      if (!hasPermission) {
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return position;
    } catch (e) {
      return null;
    }
  }

  // Получение адреса по координатам
  static Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      // В реальном приложении использовать geocoding package
      // Для демо возвращаем координаты
      return 'Широта: ${lat.toStringAsFixed(4)}, Долгота: ${lng.toStringAsFixed(4)}';
    } catch (e) {
      return 'Неизвестный адрес';
    }
  }

  // Расчёт расстояния между двумя точками (в км)
  static double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2) / 1000;
  }

  // Оценка времени прибытия (в минутах)
  static int estimateArrivalTime(double distanceKm) {
    // Средняя скорость в городе 30 км/ч
    double speedKmH = 30;
    double timeHours = distanceKm / speedKmH;
    return (timeHours * 60).round();
  }

  // Предложение списка ближайших адресов (демо)
  static List<Map<String, dynamic>> getNearbyAddresses(double lat, double lng) {
    // В реальном приложении использовать API геокодирования
    return [
      {
        'name': 'ул. Ленина, 10',
        'address': 'ул. Ленина, 10',
        'lat': lat + 0.001,
        'lng': lng + 0.001,
        'distance': '200 м',
      },
      {
        'name': 'ТЦ "Центр"',
        'address': 'ул. Пушкина, 25',
        'lat': lat + 0.002,
        'lng': lng + 0.002,
        'distance': '350 м',
      },
      {
        'name': 'метро "Курская"',
        'address': 'метро Курская',
        'lat': lat + 0.003,
        'lng': lng + 0.003,
        'distance': '500 м',
      },
    ];
  }
  
  // Расчёт стоимости поездки на основе расстояния
  static double calculatePrice(double distanceKm, String tariff) {
    double basePrice;
    double pricePerKm;
    
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
      default:
        basePrice = 99;
        pricePerKm = 15;
    }
    
    // Минимальная стоимость
    double totalPrice = basePrice + (distanceKm * pricePerKm);
    return totalPrice < basePrice ? basePrice : totalPrice;
  }
}
