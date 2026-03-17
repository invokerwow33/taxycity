import 'package:flutter/material.dart';

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Демо данные истории поездок
  final List<Map<String, dynamic>> _completedTrips = [
    {
      'id': '1001',
      'from': 'ул. Ленина, 10',
      'to': 'ТЦ "Центр", ул. Пушкина, 25',
      'price': '350 ₽',
      'date': '15.01.2025',
      'time': '14:30',
      'status': 'Завершена',
      'driverName': 'Алексей',
      'driverRating': 4.8,
      'car': 'Toyota Camry (А777АА)',
    },
    {
      'id': '1002',
      'from': 'м. Курская',
      'to': 'пр. Победы, 50',
      'price': '420 ₽',
      'date': '14.01.2025',
      'time': '09:15',
      'status': 'Завершена',
      'driverName': 'Мария',
      'driverRating': 5.0,
      'car': 'Kia Rio (В555ОР)',
    },
    {
      'id': '1003',
      'from': 'Вокзал',
      'to': 'ул. Садовая, 23',
      'price': '280 ₽',
      'date': '13.01.2025',
      'time': '18:45',
      'status': 'Завершена',
      'driverName': 'Иван',
      'driverRating': 4.5,
      'car': 'Hyundai Solaris (С333КХ)',
    },
    {
      'id': '1004',
      'from': 'Аэропорт',
      'to': 'центр города',
      'price': '890 ₽',
      'date': '12.01.2025',
      'time': '11:20',
      'status': 'Завершена',
      'driverName': 'Пётр',
      'driverRating': 4.9,
      'car': 'Volkswagen Polo (Е123МР)',
    },
    {
      'id': '1005',
      'from': 'ТЦ "Мега"',
      'to': 'ул. Новая, 15',
      'price': '310 ₽',
      'date': '11.01.2025',
      'time': '16:00',
      'status': 'Завершена',
      'driverName': 'Анна',
      'driverRating': 4.7,
      'car': 'Renault Logan (К789ОР)',
    },
  ];

  final List<Map<String, dynamic>> _cancelledTrips = [
    {
      'id': '1006',
      'from': 'ул. Центральная, 5',
      'to': 'парк Победы',
      'price': '200 ₽',
      'date': '15.01.2025',
      'time': '10:00',
      'status': 'Отменена',
      'reason': 'Водитель не приехал',
    },
    {
      'id': '1007',
      'from': 'дом',
      'to': 'работа',
      'price': '180 ₽',
      'date': '14.01.2025',
      'time': '08:30',
      'status': 'Отменена',
      'reason': 'Отменено клиентом',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История поездок'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Все'),
            Tab(text: 'Завершённые'),
            Tab(text: 'Отменённые'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Статистика
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Всего поездок',
                    '${_completedTrips.length + _cancelledTrips.length}',
                    Icons.route,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Потрачено',
                    '${_calculateTotal()} ₽',
                    Icons.attach_money,
                  ),
                ),
              ],
            ),
          ),

          // Список поездок
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Все поездки
                _buildTripsList([
                  ..._completedTrips,
                  ..._cancelledTrips,
                ]),
                // Завершённые
                _buildTripsList(_completedTrips),
                // Отменённые
                _buildTripsList(_cancelledTrips),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF1565C0)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTripsList(List<Map<String, dynamic>> trips) {
    if (trips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Нет поездок',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        return _buildTripCard(trip);
      },
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip) {
    final isCompleted = trip['status'] == 'Завершена';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок с датой и статусом
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${trip['date']} в ${trip['time']}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        trip['status'],
                        style: TextStyle(
                          color: isCompleted ? Colors.green : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                            trip['from'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            trip['to'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Детали для завершённых поездок
                if (isCompleted) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Водитель
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              trip['driverName'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Рейтинг
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${trip['driverRating']}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.directions_car,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trip['car'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],

                // Причина отмены
                if (!isCompleted && trip['reason'] != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            trip['reason'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Подвал с ценой и действиями
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green[50] : Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Text(
                  trip['price'],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.green : Colors.grey,
                  ),
                ),
                const Spacer(),
                if (isCompleted)
                  OutlinedButton(
                    onPressed: () {
                      // Повторить поездку
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Маршрут скопирован'),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1565C0),
                      side: const BorderSide(color: Color(0xFF1565C0)),
                    ),
                    child: const Text('Повторить'),
                  ),
                if (!isCompleted)
                  OutlinedButton(
                    onPressed: () {
                      // Заново заказать
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1565C0),
                      side: const BorderSide(color: Color(0xFF1565C0)),
                    ),
                    child: const Text('Заказать снова'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _calculateTotal() {
    int total = 0;
    for (var trip in _completedTrips) {
      String price = trip['price'].toString().replaceAll(' ₽', '');
      total += int.tryParse(price) ?? 0;
    }
    return total.toString();
  }
}
