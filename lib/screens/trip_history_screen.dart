import 'package:flutter/material.dart';

class TripHistoryScreen extends StatelessWidget {
  const TripHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Демо данные для истории поездок
    final List<Map<String, dynamic>> trips = [
      {
        'id': '1',
        'from': 'ул. Ленина, 10',
        'to': 'ТЦ "Центр"',
        'price': '350 ₽',
        'date': '15 марта 2024, 14:30',
        'status': 'Завершена',
        'driver': 'Александр',
        'car': 'Toyota Camry, А234ВА124',
      },
      {
        'id': '2',
        'from': 'аэропорт',
        'to': 'ул. Пушкина, 25',
        'price': '890 ₽',
        'date': '14 марта 2024, 09:15',
        'status': 'Завершена',
        'driver': 'Михаил',
        'car': 'Kia K5, О567ВК77',
      },
      {
        'id': '3',
        'from': 'ж/д вокзал',
        'to': 'ул. Мира, 42',
        'price': '420 ₽',
        'date': '13 марта 2024, 18:45',
        'status': 'Завершена',
        'driver': 'Иван',
        'car': 'Hyundai Sonata, С890АС77',
      },
      {
        'id': '4',
        'from': 'ул. Садовая, 5',
        'to': ' парк Победы',
        'price': '180 ₽',
        'date': '12 марта 2024, 11:20',
        'status': 'Завершена',
        'driver': 'Александр',
        'car': 'Toyota Camry, А234ВА124',
      },
      {
        'id': '5',
        'from': 'метро "Курская"',
        'to': 'ул. Таганская, 15',
        'price': '250 ₽',
        'date': '11 марта 2024, 20:30',
        'status': 'Завершена',
        'driver': 'Елена',
        'car': 'Volkswagen Polo, М123КХ77',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('История поездок'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: trips.isEmpty
          ? Center(
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
                    'У вас пока нет поездок',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Закажите такси, и они появятся здесь',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: trips.length,
              itemBuilder: (context, index) {
                return _buildTripCard(trips[index]);
              },
            ),
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  trip['date'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    trip['status'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
                  child: Text(
                    trip['from'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(left: 5),
              height: 16,
              width: 2,
              color: Colors.grey[300],
            ),
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
                  child: Text(
                    trip['to'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Водитель: ${trip['driver']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      trip['car'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Text(
                  trip['price'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1565C0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
