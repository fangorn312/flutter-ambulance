import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_provider.dart';
import '../../routes/app_router.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_textfield.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
        body: SafeArea(
        child: Padding(
        padding: const EdgeInsets.all(24.0),
    child: Form(
    key: _formKey,
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
    // App logo
    Padding(
    padding: const EdgeInsets.only(bottom: 48.0),
    child: Column(
    children: [
    Icon(
    Icons.local_hospital,
    size: 72,
    color: Theme.of(context).primaryColor,
    ),
    const SizedBox(height: 16),
    Text(
    'Ambulance Doctor',
    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
    fontWeight: FontWeight.bold,
    color: Theme.of(context).primaryColor,
    ),
    textAlign: TextAlign.center,
    ),
    const SizedBox(height: 8),
    Text(
    'Мобильное приложение врача',
    style: Theme.of(context).textTheme.titleMedium,
    textAlign: TextAlign.center,
    ),
    ],
    ),
    ),

    // Username field
    AppTextField(
    label: 'Логин',
    hint: 'Введите логин',
    prefixIcon: Icons.person,
    controller: _usernameController,
    keyboardType: TextInputType.emailAddress,
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Пожалуйста, введите логин';
    }
    return null;
    },
    ),

    const SizedBox(height: 16),

    // Password field
    AppTextField(
    label: 'Пароль',
    hint: 'Введите пароль',
    prefixIcon: Icons.lock,
    suffixIcon: _showPassword ? Icons.visibility_off : Icons.visibility,
    onSuffixIconPressed: () {
    setState(() {
    _showPassword = !_showPassword;
    });
    },
    controller: _passwordController,
    obscureText: !_showPassword,
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Пожалуйста, введите пароль';
    }
    return null;
    },
    ),

    const SizedBox(height: 8),

    // Remember me checkbox
    Row(
    children: [
    Checkbox(
    value: _rememberMe,
    onChanged: (value) {
    setState(() {
    _rememberMe = value ?? false;
    });
    },
    ),
    Text('Запомнить меня'),
    ],
    ),

    const SizedBox(height: 24),

    // Login button
    AppButton(
    text: 'ВОЙТИ',
    onPressed: () {
    if (_formKey.currentState!.validate()) {
    // Login functionality will be implemented in later iterations
    appProvider.setAuthenticated(true);
    Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
    },
    isLoading: appProvider.isLoading,
    ),

    const SizedBox(height: 16),

    // Connection status indicator
    Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        appProvider.connectionStatus == ConnectionStatus.online
            ? Icons.wifi
            : Icons.wifi_off,
        size: 16,
        color: appProvider.connectionStatus == ConnectionStatus.online
            ? Colors.green
            : Colors.red,
      ),
      const SizedBox(width: 8),
      Text(
        appProvider.connectionStatus == ConnectionStatus.online
            ? 'Подключено к серверу'
            : 'Автономный режим',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: appProvider.connectionStatus == ConnectionStatus.online
              ? Colors.green
              : Colors.red,
        ),
      ),
    ],
    ),
    ],
    ),
    ),
        ),
        ),
    );
  }
}