import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxycity/services/map_service.dart';
import 'package:taxycity/services/notification_service.dart';
import 'package:taxycity/services/storage_service.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  String _status = 'available';
  bool _isOnline = false;
  double? _currentLat;
  double? _currentLng;
  bool _isLoadingLocation = false;
  
  GoogleMapController? _mapController;
  Timer? _locationTimer;

  // Список доступных заказов (демо данные)
  final List<Map<String, dynamic>> _availableOrders = [
    {
      'id': '1',
      'from': 'ул. Ленина, 10',
      'to': 'ТЦ "Центр", ул. Пушкина, 25',
      'price': '350 ₽',
      'distance': '3.2 км',
      'eta': '8 мин',
      'clientName': 'Алексей',
      'rating': 4.8,
      'lat': 55.757,
      'lng': 37.619,
    },
    {
      'id': '2',
      'from': 'м. Курская',
      'to': 'пр. Победы, 50',
      'price': '420 ₽',
      'distance': '4.5 км',
      'eta': '12 мин',
      'clientName': 'Мария',
      'rating': 5.0,
      'lat': 55.759,
      'lng': 37.621,
    },
    {
      'id': '3',
      'from': 'Вокзал',
      'to': 'аэропорт',
      'price': '890 ₽',
      'distance': '15 км',
      'eta': '25 мин',
      'clientName': 'Иван',
      'rating': 4.5,
      'lat': 55.761,
      'lng': 37.623,
    },
  ];

  // Текущий активный заказ
  Map<String, dynamic>? _activeOrder;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    // Обновлять местоположение каждые 10 секунд
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (_isOnline && _mapController != null) {
        _updateLocation();
      }
    });
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
      
      // Обновить маркер на карте
      if (_mapController != null) {
        _updateMapMarkers();
      }
    }

    setState(() {
      _isLoadingLocation = false;
    });
  }

  Future<void> _updateLocation() async {
    final position = await MapService.getCurrentLocation();
    if (position != null && mounted) {
      setState(() {
        _currentLat = position.latitude;
        _currentLng = position.longitude;
      });
      MapService.updateCurrentPosition(position.latitude, position.longitude);
    }
  }

  void _updateMapMarkers() {
    MapService.clearMarkers();
    
    if (_currentLat != null && _currentLng != null) {
      MapService.addDriverMarker(_currentLat!, _currentLng!, 'Вы');
    }
    
    // Добавить маркеры заказов
    if (_isOnline && _availableOrders.isNotEmpty) {
      for (var order in _availableOrders) {
        MapService.addStartMarker(
          order['lat'],
          order['lng'],
          '${order['price']} - ${order['clientName']}',
        );
      }
    }
    
    setState(() {});
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    MapService.updateController(controller);
    _updateMapMarkers();
    
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

  void _toggleOnline() {
    setState(() {
      _isOnline = !_isOnline;
      if (_isOnline) {
        _status = 'available';
      } else {
        _status = 'offline';
        _activeOrder = null;
      }
    });
    _updateMapMarkers();
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
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Верхняя панель статуса
          SafeArea(
            child: Column(
              children: [
                // Статус онлайн/офлайн
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isOnline ? Colors.green : Colors.grey[800],
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onTap: _toggleOnline,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isOnline ? Icons.circle : Icons.circle_outlined,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isOnline ? 'Онлайн' : 'Офлайн',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_availableOrders.length} заказов',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Кнопка моего местоположения
          Positioned(
            right: 16,
            bottom: _activeOrder != null ? 300 : 100,
            child: Column(
              children: [
                FloatingActionButton(
                  mini: true,
                  heroTag: 'location',
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
                      : const Icon(Icons.my_location, color: Color(0xFF1565C0)),
                ),
                if (_isOnline) ...[
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    mini: true,
                    heroTag: 'refresh',
                    onPressed: () {
                      _updateMapMarkers();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Карта обновлена'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.refresh, color: Color(0xFF1565C0)),
                  ),
                ],
              ],
            ),
          ),

          // Панель заказов или активного заказа
          if (_activeOrder != null)
            _buildActiveOrderPanel()
          else if (_isOnline)
            _buildOrdersList()
          else
            _buildOfflinePanel(),
        ],
      ),
    );
  }

  Widget _buildOfflinePanel() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.offline_bolt,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Вы офлайн',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Переключитесь в режим онлайн\nдля получения заказов',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _toggleOnline,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Выйти на линию',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            // Заголовок
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Доступные заказы',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_availableOrders.length}',
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Список заказов
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _availableOrders.length,
                itemBuilder: (context, index) {
                  final order = _availableOrders[index];
                  return _buildOrderCard(order);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Цена и расстояние
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order['price'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.straighten, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    order['distance'],
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.timer, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    order['eta'],
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Маршрут
          Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    width: 2,
                    height: 20,
                    color: Colors.grey[300],
                  ),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order['from'],
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      order['to'],
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Клиент и кнопка
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF1565C0),
                child: Text(
                  order['clientName'][0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order['clientName'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        '${order['rating']}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _activeOrder = Map.from(order);
                    _activeOrder!['status'] = 'В пути';
                  });
                  NotificationService.newOrder(
                    order['from'],
                    order['price'],
                  );
                  
                  // Показать маршрут на карте
                  if (_mapController != null && order['lat'] != null && order['lng'] != null) {
                    _mapController!.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        LatLng(order['lat'], order['lng']),
                        15,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Принять'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveOrderPanel() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Статус
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _activeOrder!['status'] ?? 'В пути',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Информация о клиенте
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF1565C0),
                  child: Text(
                    _activeOrder!['clientName'][0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _activeOrder!['clientName'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text('${_activeOrder!['rating']}'),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.phone, color: Colors.green),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.green[50],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/chat');
                  },
                  icon: const Icon(Icons.chat, color: Color(0xFF1565C0)),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0).withOpacity(0.1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Маршрут
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_activeOrder!['from']),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_activeOrder!['to']),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Стоимость
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.attach_money, color: Colors.green),
                        Text(
                          _activeOrder!['price'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.straighten, color: Colors.blue),
                        Text(
                          _activeOrder!['distance'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Кнопки действий
            if (_activeOrder!['status'] == 'В пути')
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _activeOrder!['status'] = 'На месте';
                    });
                    NotificationService.driverArrived();
                  },
                  icon: const Icon(Icons.location_on),
                  label: const Text('Я на месте'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              )
            else if (_activeOrder!['status'] == 'На месте')
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _activeOrder = null;
                    });
                    NotificationService.tripCompleted();
                    _updateMapMarkers();
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Завершить поездку'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }
}
