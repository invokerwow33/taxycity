import 'package:flutter/material.dart';
import 'package:taxycity/services/storage_service.dart';

class ClientSettingsScreen extends StatefulWidget {
  const ClientSettingsScreen({super.key});

  @override
  State<ClientSettingsScreen> createState() => _ClientSettingsScreenState();
}

class _ClientSettingsScreenState extends State<ClientSettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  bool _sound = true;
  bool _vibration = true;
  bool _smsNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _darkMode = StorageService.isDarkMode();
      // Другие настройки загружать из StorageService
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // Профиль
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
                        StorageService.getUserName() ?? 'Пользователь',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        StorageService.getUserPhone() ?? '',
                        style: TextStyle(
                          color: Colors.grey[600],
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

          // Внешний вид
          _buildSectionHeader('Внешний вид'),
          _buildSwitchTile(
            'Тёмная тема',
            'Использовать тёмное оформление',
            Icons.dark_mode,
            _darkMode,
            (value) async {
              await StorageService.setDarkMode(value);
              setState(() {
                _darkMode = value;
              });
              // В реальном приложении использовать Provider для смены темы
            },
          ),

          // Уведомления
          _buildSectionHeader('Уведомления'),
          _buildSwitchTile(
            'Push-уведомления',
            'Получать уведомления о заказах',
            Icons.notifications,
            _notifications,
            (value) {
              setState(() {
                _notifications = value;
              });
            },
          ),
          _buildSwitchTile(
            'SMS-уведомления',
            'Получать SMS о статусе заказа',
            Icons.sms,
            _smsNotifications,
            (value) {
              setState(() {
                _smsNotifications = value;
              });
            },
          ),
          _buildSwitchTile(
            'Звук',
            'Воспроизводить звук при уведомлениях',
            Icons.volume_up,
            _sound,
            (value) {
              setState(() {
                _sound = value;
              });
            },
          ),
          _buildSwitchTile(
            'Вибрация',
            'Вибрация при уведомлениях',
            Icons.vibration,
            _vibration,
            (value) {
              setState(() {
                _vibration = value;
              });
            },
          ),

          // Избранные адреса
          _buildSectionHeader('Избранные адреса'),
          _buildNavigationTile(
            'Мои адреса',
            'Дом, работа и другие',
            Icons.star,
            () => _showFavoriteAddresses(),
          ),

          // Безопасность
          _buildSectionHeader('Безопасность'),
          _buildNavigationTile(
            'Изменить пароль',
            '',
            Icons.lock,
            () {},
          ),
          _buildNavigationTile(
            'Привязанные карты',
            'Управление способами оплаты',
            Icons.credit_card,
            () {},
          ),
          _buildNavigationTile(
            'Верификация телефона',
            'Подтверждение номера',
            Icons.verified_user,
            () {
              Navigator.pushNamed(context, '/verify');
            },
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

  void _showFavoriteAddresses() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Избранные адреса',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Переход к экрану добавления адреса
                        },
                        icon: const Icon(Icons.add),
                        color: const Color(0xFF1565C0),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      _buildFavoriteAddressTile(
                        'Дом',
                        'ул. Ленина, 1',
                        Icons.home,
                      ),
                      _buildFavoriteAddressTile(
                        'Работа',
                        'пр. Победы, 50',
                        Icons.work,
                      ),
                      _buildFavoriteAddressTile(
                        'Спортзал',
                        'ул. Физкультурная, 15',
                        Icons.fitness_center,
                      ),
                      _buildFavoriteAddressTile(
                        'Родители',
                        'ул. Садовая, 23',
                        Icons.family_restroom,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFavoriteAddressTile(
    String name,
    String address,
    IconData icon,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1565C0).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF1565C0)),
      ),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(address),
      trailing: IconButton(
        onPressed: () {},
        icon: const Icon(Icons.more_vert),
      ),
    );
  }
}
