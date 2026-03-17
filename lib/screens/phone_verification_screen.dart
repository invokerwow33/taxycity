import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:taxycity/services/storage_service.dart';

class PhoneVerificationScreen extends StatefulWidget {
  final String userType;
  final String phoneNumber;
  final Map<String, String> userData;
  
  const PhoneVerificationScreen({
    super.key,
    required this.userType,
    required this.phoneNumber,
    required this.userData,
  });

  @override
  State<PhoneVerificationScreen> createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6, (_) => TextEditingController()
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  
  String _generatedCode = '';
  bool _isResending = false;
  int _resendTimer = 0;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _generateAndSendCode();
  }

  void _generateAndSendCode() {
    // Генерация 6-значного кода
    final random = Random();
    _generatedCode = (random.nextInt(900000) + 100000).toString();
    
    // Сохраняем код для верификации (в реальном приложении код отправляется на сервер/SMS)
    StorageService.setVerificationCode(_generatedCode);
    
    // Для демонстрации показываем код
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ваш код: $_generatedCode (для демо)'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 10),
        ),
      );
    }
    
    // Запускаем таймер для повторной отправки
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendTimer = 60;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _resendTimer--;
      });
      if (_resendTimer <= 0) {
        return false;
      }
      return true;
    });
  }

  void _onCodeChanged(int index, String value) {
    _errorMessage = '';
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _verifyCode();
      }
    }
  }

  void _onCodeKeyPress(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _verifyCode() {
    final enteredCode = _controllers.map((c) => c.text).join();
    
    if (enteredCode.length == 6) {
      if (enteredCode == _generatedCode) {
        // Код верный - сохраняем данные и переходим
        _saveUserDataAndNavigate();
      } else {
        setState(() {
          _errorMessage = 'Неверный код. Попробуйте снова.';
        });
        // Очистить поля
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      }
    }
  }

  void _saveUserDataAndNavigate() async {
    // Сохраняем данные пользователя
    await StorageService.setUserType(widget.userType);
    await StorageService.setUserPhone(widget.phoneNumber);
    await StorageService.setUserName(widget.userData['name'] ?? '');
    await StorageService.setUserEmail(widget.userData['email'] ?? '');
    await StorageService.setLoggedIn(true);
    await StorageService.setPhoneVerified(true);
    
    // Для водителя сохраняем данные об автомобиле
    if (widget.userType == 'driver') {
      await StorageService.setDriverCarNumber(widget.userData['carNumber'] ?? '');
      await StorageService.setDriverCarBrand(widget.userData['carBrand'] ?? '');
      await StorageService.setDriverCarColor(widget.userData['carColor'] ?? '');
    }
    
    if (mounted) {
      // Переходим на главный экран
      if (widget.userType == 'driver') {
        Navigator.pushReplacementNamed(context, '/driver/home');
      } else {
        Navigator.pushReplacementNamed(context, '/client/home');
      }
    }
  }

  void _resendCode() {
    if (_resendTimer > 0 || _isResending) return;
    
    setState(() {
      _isResending = true;
    });
    
    _generateAndSendCode();
    
    setState(() {
      _isResending = false;
    });
    
    // Очистить поля
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Подтверждение телефона'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // Иконка
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.phone_android,
                size: 40,
                color: Color(0xFF1565C0),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Введите код из SMS',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Мы отправили код на номер\n${widget.phoneNumber}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            
            // Поля для ввода кода
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                return Container(
                  width: 45,
                  height: 55,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: RawKeyboardListener(
                    focusNode: FocusNode(),
                    onKey: (event) => _onCodeKeyPress(index, event),
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF1565C0),
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) => _onCodeChanged(index, value),
                    ),
                  ),
                );
              }),
            ),
            
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            ],
            
            const SizedBox(height: 32),
            
            // Кнопка повторной отправки
            if (_resendTimer > 0)
              Text(
                'Повторить через $_resendTimer секунд',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              )
            else
              TextButton(
                onPressed: _resendCode,
                child: const Text(
                  'Отправить код повторно',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1565C0),
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
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
}
