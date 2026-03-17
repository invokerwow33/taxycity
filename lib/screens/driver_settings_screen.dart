import 'package:flutter/material.dart';
import 'package:taxycity/services/storage_service.dart';

class DriverSettingsScreen extends StatefulWidget {
  const DriverSettingsScreen({super.key});

  @override
  State<DriverSettingsScreen> createState() => _DriverSettingsScreenState();
}

class _DriverSettingsScreenState extends State<DriverSettingsScreen> {
  bool _autoAccept = false;
  bool _soundNotifications = true;
  bool _vibration = true;
  bool _nightMode = false;

  // Информация о водителе
  String _carNumber = '';
  String _carBrand = '';
  String _carColor = '';

  @override
  void initState() {
    super.initState();
    _loadDriverData();
  }

  void _loadDriverData() {
    setState(() {
      _carNumber = StorageService.getDriverCarNumber() ?? '';
      _carBrand = StorageService.getDriverCarBrand() ?? '';
      _carColor = StorageService.getDriverCarColor() ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки водителя'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // Профиль водителя
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: const Color(0xFF1565C0),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        StorageService.getUserName() ?? 'Водитель',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '+${StorageService.getUserPhone() ?? ''}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Водитель',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Редактирование профиля
                  },
                  icon: const Icon(Icons.edit),
                  color: const Color(0xFF1565C0),
                ),
              ],
            ),
          ),

          // Информация об автомобиле
          _buildSectionHeader('Автомобиль'),
          _buildNavigationTile(
            '$_carBrand $_carColor',
            'номер: $_carNumber',
            Icons.directions_car,
            () {},
          ),
          _buildNavigationTile(
            'Добавить автомобиль',
            'Зарегистрировать ещё один автомобиль',
            Icons.add_circle_outline,
            () {},
          ),
          _buildNavigationTile(
            'Документы',
            'Водительское удостоверение, ОСАГО',
            Icons.description,
            () {},
          ),

          // Настройки работы
          _buildSectionHeader('Настройки работы'),
          _buildSwitchTile(
            'Автоприём заказов',
            'Автоматически принимать подходящие заказы',
            Icons.autorenew,
            _autoAccept,
            (value) {
              setState(() {
                _autoAccept = value;
              });
            },
          ),
          _buildSwitchTile(
            'Ночной режим',
            'Работать только в светлое время суток',
            Icons.nightlight,
            _nightMode,
            (value) {
              setState(() {
                _nightMode = value;
              });
            },
          ),

          // Уведомления
          _buildSectionHeader('Уведомления'),
          _buildSwitchTile(
            'Звуковые уведомления',
            'Звук при новом заказе',
            Icons.notifications_active,
            _soundNotifications,
            (value) {
              setState(() {
                _soundNotifications = value;
              });
            },
          ),
          _buildSwitchTile(
            'Вибрация',
            'Вибрация при новом заказе',
            Icons.vibration,
            _vibration,
            (value) {
              setState(() {
                _vibration = value;
              });
            },
          ),

          // Статистика
          _buildSectionHeader('Статистика'),
          _buildNavigationTile(
            'Моя статистика',
            'Рейтинг, количество поездок',
            Icons.bar_chart,
            () {},
          ),
          _buildNavigationTile(
            'Доходы',
            'За сегодня, неделю, месяц',
            Icons.payments,
            () {},
          ),

          // Финансы
          _buildSectionHeader('Финансы'),
          _buildNavigationTile(
            'Вывод средств',
            'На банковскую карту',
            Icons.account_balance,
            () {},
          ),
          _buildNavigationTile(
            'Промокоды',
            'Активировать промокод',
            Icons.card_giftcard,
            () {},
          ),

          // О приложении
          _buildSectionHeader('О приложении'),
          _buildNavigationTile(
            'Помощь',
            'FAQ и поддержка',
            Icons.help,
            () {},
          ),
          _buildNavigationTile(
            'Политика конфиденциальности',
            '',
            Icons.privacy_tip,
            () {},
          ),
          _buildNavigationTile(
            'Версия приложения',
            '1.0.0+2',
            Icons.info,
            () {},
          ),

          // Выход
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () async {
                await StorageService.logout();
                if (context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Выйти из аккаунта'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1565C0),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1565C0)),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF1565C0),
      ),
    );
  }

  Widget _buildNavigationTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1565C0)),
      title: Text(title),
      subtitle: subtitle.isNotEmpty
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            )
          : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
