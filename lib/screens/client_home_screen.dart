import 'package:flutter/material.dart';
import 'package:taxycity/services/location_service.dart';
import 'package:taxycity/services/notification_service.dart';

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

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    final position = await LocationService.getCurrentLocation();
    if (position != null) {
      setState(() {
        _currentLat = position.latitude;
        _currentLng = position.longitude;
        _fromController.text = await LocationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
      });
    }

    setState(() {
      _isLoadingLocation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TaxyCity'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, '/client/history');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/client/settings');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Карта (заглушка)
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[300],
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map,
                          size: 50,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Карта',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                        ),
                        if (_currentLat != null && _currentLng != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'GPS: ${_currentLat!.toStringAsFixed(4)}, ${_currentLng!.toStringAsFixed(4)}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _isLoadingLocation
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.my_location, size: 16, color: Color(0xFF1565C0)),
                          const SizedBox(width: 4),
                          const Text(
                            'Мое местоположение',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Кнопка определения места
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: FloatingActionButton.small(
                      onPressed: _getCurrentLocation,
                      backgroundColor: Colors.white,
                      child: _isLoadingLocation
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location, color: Color(0xFF1565C0)),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Избранные адреса
                  const Text(
                    'Избранные адреса',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _favoriteAddresses.length,
                      itemBuilder: (context, index) {
                        final address = _favoriteAddresses[index];
                        return GestureDetector(
                          onTap: () {
                            _toController.text = address['address']!;
                          },
                          child: Container(
                            width: 120,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _getIconFromString(address['icon']!),
                                  color: const Color(0xFF1565C0),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  address['name']!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Поле "Откуда" и "Куда"
                  Container(
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
                      children: [
                        Row(
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
                                  hintText: 'Откуда поехать?',
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.my_location, size: 20),
                              onPressed: _getCurrentLocation,
                              color: const Color(0xFF1565C0),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
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
                                  hintText: 'Куда поехать?',
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Дополнительные остановки
                        const Divider(),
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.orange[700]!),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _additionalStopsController,
                                decoration: const InputDecoration(
                                  hintText: 'Добавить остановку (необязательно)',
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Выбор тарифа
                  const Text(
                    'Выберите тариф',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._tariffs.entries.map((entry) {
                    return _buildTariffCard(entry.key, entry.value);
                  }),
                  const SizedBox(height: 16),

                  // Дополнительные опции
                  const Text(
                    'Дополнительные опции',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        _buildOptionSwitch(
                          'Перевозка животных',
                          Icons.pets,
                          _isPetAllowed,
                          (value) => setState(() => _isPetAllowed = value),
                        ),
                        const Divider(),
                        _buildOptionSwitch(
                          'Багаж в салоне',
                          Icons.luggage,
                          _isLuggage,
                          (value) => setState(() => _isLuggage = value),
                        ),
                        const Divider(),
                        _buildOptionSwitch(
                          'Ожидание на месте (бесплатно 5 мин)',
                          Icons.timer,
                          _isWaiting,
                          (value) => setState(() => _isWaiting = value),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Заказ на время
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.access_time, color: Color(0xFF1565C0)),
                                SizedBox(width: 8),
                                Text(
                                  'Заказ на время',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: _isScheduleLater,
                              onChanged: (value) {
                                setState(() {
                                  _isScheduleLater = value;
                                });
                              },
                              activeColor: const Color(0xFF1565C0),
                            ),
                          ],
                        ),
                        if (_isScheduleLater) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _selectDate,
                                  icon: const Icon(Icons.calendar_today),
                                  label: Text(
                                    _selectedDate != null
                                        ? '${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}'
                                        : 'Выбрать дату',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _selectTime,
                                  icon: const Icon(Icons.access_time),
                                  label: Text(
                                    _selectedTime != null
                                        ? _selectedTime!.format(context)
                                        : 'Выбрать время',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Кнопка "Поделиться поездкой"
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ссылка на поездку скопирована!'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Поделиться поездкой'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1565C0),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Итоговая стоимость
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Предварительная стоимость:',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              _calculatePrice(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (_isPetAllowed || _isLuggage || _isWaiting)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                const Text(
                                  'Включено: ',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                if (_isPetAllowed)
                                  _buildTag('Животные'),
                                if (_isLuggage)
                                  _buildTag('Багаж'),
                                if (_isWaiting)
                                  _buildTag('Ожидание'),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              NotificationService.orderAccepted();
                              Navigator.pushNamed(context, '/client/order');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1565C0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Заказать такси',
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
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionSwitch(
    String label,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1565C0)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF1565C0),
        ),
      ],
    );
  }

  Widget _buildTag(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
        ),
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1565C0).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF1565C0) : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1565C0) : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                tariff['icon'],
                color: isSelected ? Colors.white : const Color(0xFF1565C0),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tariff['name'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFF1565C0) : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tariff['description'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              tariff['price'],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF1565C0) : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _calculatePrice() {
    if (_toController.text.isEmpty) {
      return '—';
    }
    int basePrice;
    switch (_selectedTariff) {
      case 'econom':
        basePrice = 250;
        break;
      case 'comfort':
        basePrice = 450;
        break;
      case 'business':
        basePrice = 800;
        break;
      default:
        basePrice = 250;
    }
    
    // Доплата за опции
    if (_isPetAllowed) basePrice += 50;
    if (_isLuggage) basePrice += 30;
    if (_isWaiting) basePrice += 20;
    
    return 'от $basePrice ₽';
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _additionalStopsController.dispose();
    super.dispose();
  }
}
