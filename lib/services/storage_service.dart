import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static late SharedPreferences _prefs;
  
  static const String _keyUserType = 'user_type';
  static const String _keyUserName = 'user_name';
  static const String _keyUserPhone = 'user_phone';
  static const String _keyUserEmail = 'user_email';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyDriverCarNumber = 'driver_car_number';
  static const String _keyDriverCarBrand = 'driver_car_brand';
  static const String _keyDriverCarColor = 'driver_car_color';
  static const String _keyIsPhoneVerified = 'is_phone_verified';
  static const String _keyVerificationCode = 'verification_code';
  
  // История поездок
  static const String _keyTripHistory = 'trip_history';
  
  // Избранные адреса
  static const String _keyFavoriteAddresses = 'favorite_addresses';
  
  // Тема приложения
  static const String _keyDarkMode = 'dark_mode';
  
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // Сохранение типа пользователя
  static Future<void> setUserType(String type) async {
    await _prefs.setString(_keyUserType, type);
  }
  
  static String? getUserType() {
    return _prefs.getString(_keyUserType);
  }
  
  // Сохранение имени
  static Future<void> setUserName(String name) async {
    await _prefs.setString(_keyUserName, name);
  }
  
  static String? getUserName() {
    return _prefs.getString(_keyUserName);
  }
  
  // Сохранение телефона
  static Future<void> setUserPhone(String phone) async {
    await _prefs.setString(_keyUserPhone, phone);
  }
  
  static String? getUserPhone() {
    return _prefs.getString(_keyUserPhone);
  }
  
  // Сохранение email
  static Future<void> setUserEmail(String email) async {
    await _prefs.setString(_keyUserEmail, email);
  }
  
  static String? getUserEmail() {
    return _prefs.getString(_keyUserEmail);
  }
  
  // Статус входа
  static Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool(_keyIsLoggedIn, value);
  }
  
  static bool isLoggedIn() {
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }
  
  // Данные автомобиля водителя
  static Future<void> setDriverCarNumber(String number) async {
    await _prefs.setString(_keyDriverCarNumber, number);
  }
  
  static String? getDriverCarNumber() {
    return _prefs.getString(_keyDriverCarNumber);
  }
  
  static Future<void> setDriverCarBrand(String brand) async {
    await _prefs.setString(_keyDriverCarBrand, brand);
  }
  
  static String? getDriverCarBrand() {
    return _prefs.getString(_keyDriverCarBrand);
  }
  
  static Future<void> setDriverCarColor(String color) async {
    await _prefs.setString(_keyDriverCarColor, color);
  }
  
  static String? getDriverCarColor() {
    return _prefs.getString(_keyDriverCarColor);
  }
  
  // Верификация телефона
  static Future<void> setPhoneVerified(bool value) async {
    await _prefs.setBool(_keyIsPhoneVerified, value);
  }
  
  static bool isPhoneVerified() {
    return _prefs.getBool(_keyIsPhoneVerified) ?? false;
  }
  
  // Код верификации (для демо)
  static Future<void> setVerificationCode(String code) async {
    await _prefs.setString(_keyVerificationCode, code);
  }
  
  static String? getVerificationCode() {
    return _prefs.getString(_keyVerificationCode);
  }
  
  // Тема приложения
  static Future<void> setDarkMode(bool value) async {
    await _prefs.setBool(_keyDarkMode, value);
  }
  
  static bool isDarkMode() {
    return _prefs.getBool(_keyDarkMode) ?? false;
  }
  
  // Избранные адреса
  static Future<void> addFavoriteAddress(Map<String, String> address) async {
    final favorites = getFavoriteAddresses();
    favorites.add(address);
    final jsonList = favorites.map((addr) => addr.toString()).toList();
    await _prefs.setStringList(_keyFavoriteAddresses, jsonList);
  }
  
  static Future<void> removeFavoriteAddress(int index) async {
    final favorites = getFavoriteAddresses();
    if (index >= 0 && index < favorites.length) {
      favorites.removeAt(index);
      final jsonList = favorites.map((addr) => addr.toString()).toList();
      await _prefs.setStringList(_keyFavoriteAddresses, jsonList);
    }
  }
  
  static List<Map<String, String>> getFavoriteAddresses() {
    final jsonList = _prefs.getStringList(_keyFavoriteAddresses) ?? [];
    // Упрощённая реализация - в реальном приложении использовать JSON
    List<Map<String, String>> result = [];
    
    // Предзаполненные избранные адреса
    if (jsonList.isEmpty) {
      result = [
        {'name': 'Дом', 'address': '', 'lat': '', 'lng': ''},
        {'name': 'Работа', 'address': '', 'lat': '', 'lng': ''},
      ];
    } else {
      for (var item in jsonList) {
        result.add({'name': '', 'address': item, 'lat': '', 'lng': ''});
      }
    }
    return result;
  }
  
  // История поездок
  static Future<void> addTripToHistory(Map<String, dynamic> trip) async {
    final history = getTripHistory();
    history.add(trip);
    await _prefs.setString(_keyTripHistory, tripHistoryToJson(history));
  }
  
  static List<Map<String, dynamic>> getTripHistory() {
    final json = _prefs.getString(_keyTripHistory);
    if (json == null) return [];
    return tripHistoryFromJson(json);
  }
  
  static String tripHistoryToJson(List<Map<String, dynamic>> history) {
    return history.map((trip) => {
      'id': trip['id'] ?? '',
      'from': trip['from'] ?? '',
      'to': trip['to'] ?? '',
      'price': trip['price'] ?? '',
      'date': trip['date'] ?? '',
      'status': trip['status'] ?? '',
    }).toList().toString();
  }
  
  static List<Map<String, dynamic>> tripHistoryFromJson(String json) {
    // Упрощённая реализация - в реальном приложении использовать json.decode
    return [];
  }
  
  // Очистка всех данных (выход из аккаунта)
  static Future<void> clearAll() async {
    await _prefs.clear();
  }
  
  // Выход из аккаунта
  static Future<void> logout() async {
    await _prefs.setBool(_keyIsLoggedIn, false);
  }
}
