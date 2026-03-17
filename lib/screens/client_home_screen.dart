import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxycity/services/map_service.dart';
import 'package:taxycity/services/notification_service.dart';
import 'package:taxycity/services/storage_service.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _additionalStopsController = TextEditingController();
  String _selectedTariff = 'econom';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isScheduleLater = false;
  bool _isLoadingLocation = false;
  bool _isPetAllowed = false;
  bool _isLuggage = false;
  bool _isWaiting = false;
  
  double? _currentLat;
  double? _currentLng;
  double? _destinationLat;
  double? _destinationLng;
  double? _distance;
  int? _eta;
  
  GoogleMapController? _mapController;
  bool _isMapReady = false;

  final Map<String, Map<String, dynamic>> _tariffs = {
    'econom': {
      'name': 'Эконом',
      'price': 'от 99 ₽',
      'icon': Icons.directions_car,
      'description': 'Комфортный автомобиль по доступной цене',
    },
    'comfort': {
      'name': 'Комфорт',
      'price': 'от 199 ₽',
      'icon': Icons.airline_seat_recline_extra,
      'description': 'Просторный салон, кондиционер',
    },
    'business': {
      'name': 'Бизнес',
      'price': 'от 399 ₽',
      'icon': Icons.diamond,
      'description': 'Премиум автомобили, высокий сервис',
    },
  };

  // Избранные адреса
  final List<Map<String, String>> _favoriteAddresses = [
    {'name': 'Дом', 'address': 'ул. Ленина, 1', 'icon': 'home'},
    {'name': 'Работа', 'address': 'пр. Победы, 50', 'icon': 'work'},
    {'name': 'Спортзал', 'address': 'ул. Физкультурная, 15', 'icon': 'fitness_center'},
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      case 'fitness_center':
        return Icons.fitness_center;
      default:
        return Icons.place;
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    final position = await MapService.getCurrentLocation();
    if (position != null) {
      setState(() {
        _currentLat = position.latitude;
        _currentLng = position.longitude;
      });
      
      MapService.updateCurrentPosition(position.latitude, position.longitude);
      
      // Обновляем маркер на карте
      if (_mapController != null) {
        MapService.addStartMarker(
          position.latitude,
          position.longitude,
          'Моё местоположение',
        );
      }
    }

    setState(() {
      _isLoadingLocation = false;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    MapService.updateController(controller);
    setState(() {
      _isMapReady = true;
    });
    
    // Добавить маркер текущей позиции
    if (_currentLat != null && _currentLng != null) {
      MapService.addStartMarker(_currentLat!, _currentLng!, 'Моё местоположение');
    }
    
    // Переместить камеру к текущей позиции
    if (_currentLat != null && _currentLng != null) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentLat!, _currentLng!),
          15,
        ),
      );
    }
  }

  void _calculateRoute() {
    if (_toController.text.isEmpty) return;
    
    // Демо расчёт маршрута
    // В реальном приложении использовать Google Directions API
    setState(() {
      _destinationLat = _currentLat != null ? _currentLat! + 0.01 : 55.7658;
      _destinationLng = _currentLng != null ? _currentLng! + 0.01 : 37.6273;
      
      // Демо значения
      _distance = 3500; // 3.5 км
      _eta = 12; // 12 минут
      
      // Добавить маркер назначения
      if (_destinationLat != null && _destinationLng != null) {
        MapService.addEndMarker(
          _destinationLat!,
          _destinationLng!,
          _toController.text,
        );
        
        // Добавить маршрут
        MapService.addRoute([
          LatLng(_currentLat ?? 55.7558, _currentLng ?? 37.6173),
          LatLng(_destinationLat!, _destinationLng!),
        ]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Карта
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: MapService.getDefaultPosition(),
            markers: MapService.markers,
            polylines: MapService.polylines,
            circles: MapService.circles,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onTap: (LatLng position) {
              // При тапе на карту - установить точку назначения
              setState(() {
                _destinationLat = position.latitude;
                _destinationLng = position.longitude;
                _toController.text = 'Выбрано на карте';
              });
              MapService.clearMarkers();
              if (_currentLat != null && _currentLng != null) {
                MapService.addStartMarker(_currentLat!, _currentLng!, 'Откуда');
              }
              MapService.addEndMarker(position.latitude, position.lng, 'Куда');
              _calculateRoute();
            },
          ),

          // Панель поиска сверху
          SafeArea(
            child: Column(
              children: [
                // Панель поиска
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Откуда
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _fromController,
                                decoration: const InputDecoration(
                                  hintText: 'Откуда?',
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            if (_isLoadingLocation)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            else
                              IconButton(
                                icon: const Icon(Icons.my_location, size: 20),
                                onPressed: _getCurrentLocation,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      // Куда
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _toController,
                                decoration: const InputDecoration(
                                  hintText: 'Куда?',
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onSubmitted: (_) => _calculateRoute(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Кнопки избранных адресов
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _favoriteAddresses.length,
                    itemBuilder: (context, index) {
                      final address = _favoriteAddresses[index];
                      return GestureDetector(
                        onTap: () {
                          _toController.text = address['address']!;
                          _calculateRoute();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getIconFromString(address['icon']!),
                                size: 16,
                                color: const Color(0xFF1565C0),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                address['name']!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Кнопка моего местоположения
          Positioned(
            right: 16,
            bottom: _destinationLat != null ? 280 : 100,
            child: FloatingActionButton(
              mini: true,
              onPressed: () async {
                await _getCurrentLocation();
                if (_mapController != null && _currentLat != null && _currentLng != null) {
                  _mapController!.animateCamera(
                    CameraUpdate.newLatLngZoom(
                      LatLng(_currentLat!, _currentLng!),
                      15,
                    ),
                  );
                }
              },
              backgroundColor: Colors.white,
              child: _isLoadingLocation
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF1565C0),
                      ),
                    )
                  : const Icon(
                      Icons.my_location,
                      color: Color(0xFF1565C0),
                    ),
            ),
          ),

          // Панель выбора тарифа и заказа
          if (_destinationLat != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Информация о поездке
                    if (_distance != null && _eta != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            const Icon(Icons.straighten, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              MapService.formatDistance(_distance!),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.timer, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              MapService.formatDuration(_eta!),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Выбор тарифа
                    const Text(
                      'Выберите тариф',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    ..._tariffs.entries.map((entry) {
                      return _buildTariffCard(entry.key, entry.value);
                    }),

                    const SizedBox(height: 16),

                    // Кнопка заказа
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          NotificationService.orderAccepted();
                          Navigator.pushNamed(context, '/client/order');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Заказать за ${MapService.calculatePrice(_distance ?? 0, _selectedTariff)} ₽',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTariffCard(String key, Map<String, dynamic> tariff) {
    final isSelected = _selectedTariff == key;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTariff = key;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1565C0).withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF1565C0) : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1565C0) : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                tariff['icon'],
                size: 20,
                color: isSelected ? Colors.white : const Color(0xFF1565C0),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tariff['name'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFF1565C0) : Colors.black,
                    ),
                  ),
                  Text(
                    tariff['description'],
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              tariff['price'],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF1565C0) : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _additionalStopsController.dispose();
    _mapController?.dispose();
    super.dispose();
  }
}
