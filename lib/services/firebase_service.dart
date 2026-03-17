import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseService {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseMessaging get messaging => FirebaseMessaging.instance;
  static FirebaseAnalytics get analytics => FirebaseAnalytics.instance;

  // Инициализация Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp();
    
    // Настройка FCM
    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    
    // Получение FCM токена
    final token = await messaging.getToken();
    if (token != null) {
      print('FCM Token: $token');
    }
  }

  // Регистрация пользователя
  static Future<User?> registerWithEmail(String email, String password) async {
    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Вход по email
  static Future<User?> signInWithEmail(String email, String password) async {
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Вход по телефону
  static Future<User?> signInWithPhone(String phoneNumber) async {
    try {
      // Для России добавляем код страны
      final formattedPhone = phoneNumber.startsWith('+') 
          ? phoneNumber 
          : '+$phoneNumber';
      
      // В реальном приложении использовать верификацию по SMS
      // Здесь демо-режим
      return auth.currentUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Верификация телефона кодом
  static Future<User?> verifyPhoneCode(String verificationId, String code) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: code,
      );
      final userCredential = await auth.signInWithCredential(credential);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Выход
  static Future<void> signOut() async {
    await auth.signOut();
  }

  // Текущий пользователь
  static User? get currentUser => auth.currentUser;

  // Создание/обновление профиля пользователя
  static Future<void> updateUserProfile({
    required String uid,
    required String name,
    String? phone,
    String? email,
    String? photoUrl,
  }) async {
    await firestore.collection('users').doc(uid).set({
      'name': name,
      'phone': phone,
      'email': email,
      'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Создание профиля водителя
  static Future<void> createDriverProfile({
    required String uid,
    required String name,
    required String phone,
    required String carNumber,
    required String carBrand,
    required String carColor,
  }) async {
    await firestore.collection('drivers').doc(uid).set({
      'name': name,
      'phone': phone,
      'carNumber': carNumber,
      'carBrand': carBrand,
      'carColor': carColor,
      'rating': 5.0,
      'totalTrips': 0,
      'isOnline': false,
      'isAvailable': false,
      'currentLat': 0.0,
      'currentLng': 0.0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Обновление геолокации водителя
  static Future<void> updateDriverLocation(
    String uid,
    double lat,
    double lng,
  ) async {
    await firestore.collection('drivers').doc(uid).update({
      'currentLat': lat,
      'currentLng': lng,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Установка статуса онлайн/офлайн
  static Future<void> setDriverOnline(String uid, bool isOnline) async {
    await firestore.collection('drivers').doc(uid).update({
      'isOnline': isOnline,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Создание заказа
  static Future<String> createOrder({
    required String clientId,
    required String fromAddress,
    required double fromLat,
    required double fromLng,
    required String toAddress,
    required double toLat,
    required double toLng,
    required String tariff,
    required double price,
  }) async {
    final orderRef = await firestore.collection('orders').add({
      'clientId': clientId,
      'fromAddress': fromAddress,
      'fromLat': fromLat,
      'fromLng': fromLng,
      'toAddress': toAddress,
      'toLat': toLat,
      'toLng': toLng,
      'tariff': tariff,
      'price': price,
      'status': 'searching', // searching, accepted, inProgress, completed, cancelled
      'driverId': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return orderRef.id;
  }

  // Принятие заказа водителем
  static Future<void> acceptOrder(String orderId, String driverId) async {
    await firestore.collection('orders').doc(orderId).update({
      'driverId': driverId,
      'status': 'accepted',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Обновление статуса заказа
  static Future<void> updateOrderStatus(
    String orderId,
    String status,
  ) async {
    await firestore.collection('orders').doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Отмена заказа
  static Future<void> cancelOrder(String orderId, String reason) async {
    await firestore.collection('orders').doc(orderId).update({
      'status': 'cancelled',
      'cancelReason': reason,
      'cancelledAt': FieldValue.serverTimestamp(),
    });
  }

  // Завершение заказа
  static Future<void> completeOrder(
    String orderId,
    double finalPrice,
    int duration, // в минутах
  ) async {
    await firestore.collection('orders').doc(orderId).update({
      'status': 'completed',
      'finalPrice': finalPrice,
      'duration': duration,
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  // Сохранение FCM токена пользователя
  static Future<void> saveUserFCMToken(String uid, String token) async {
    await firestore.collection('users').doc(uid).update({
      'fcmToken': token,
    });
  }

  // Отправка уведомления водителю
  static Future<void> sendNotificationToDriver(
    String driverId,
    String title,
    String body,
  ) async {
    // Используем Cloud Functions в реальном приложении
    // Здесь просто логируем
    print('Notification to driver $driverId: $title - $body');
  }

  // Получение списка доступных водителей
  static Stream<List<Map<String, dynamic>>> getNearbyDrivers(
    double lat,
    double lng,
    double radiusKm,
  ) {
    // В реальном приложении использовать гео-запросы Firestore
    return firestore
        .collection('drivers')
        .where('isOnline', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  // Получение истории заказов пользователя
  static Stream<List<Map<String, dynamic>>> getUserOrders(String userId) {
    return firestore
        .collection('orders')
        .where('clientId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  // Обработка ошибок Firebase Auth
  static String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Пароль слишком слабый';
      case 'email-already-in-use':
        return 'Этот email уже используется';
      case 'invalid-email':
        return 'Неверный формат email';
      case 'user-disabled':
        return 'Аккаунт заблокирован';
      case 'user-not-found':
        return 'Пользователь не найден';
      case 'wrong-password':
        return 'Неверный пароль';
      case 'invalid-verification-code':
        return 'Неверный код подтверждения';
      case 'invalid-phone-number':
        return 'Неверный номер телефона';
      case 'quota-exceeded':
        return 'Превышен лимит запросов';
      default:
        return 'Произошла ошибка: ${e.message}';
    }
  }

  // Аналитика - событие начала оформления заказа
  static Future<void> logBeginCheckout({
    required String currency,
    required double value,
    required String coupon,
  }) async {
    await analytics.logBeginCheckout(
      value: value,
      currency: currency,
      items: [
        AnalyticsEventItem(
          itemName: 'taxi_order',
          coupon: coupon,
        ),
      ],
    );
  }

  // Аналитика - событие успешной оплаты
  static Future<void> logPurchase({
    required String currency,
    required double value,
    required String transactionId,
  }) async {
    await analytics.logPurchase(
      value: value,
      currency: currency,
      transactionId: transactionId,
    );
  }

  // Аналитика - событие поиска водителя
  static Future<void> logSearchDriver(String tariff) async {
    await analytics.logSearch(
      searchTerm: 'driver_search_$tariff',
    );
  }
}
