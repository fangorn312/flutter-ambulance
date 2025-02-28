import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/services/notification_service.dart';
import '../../../domain/entities/call.dart';
import '../../../domain/entities/brigade_status.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/status_button.dart';
import '../../widgets/call_item.dart';
import '../../routes/app_router.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<Call> _activeCalls = [];
  List<Call> _pendingCalls = [];
  List<Call> _completedCalls = [];
  BrigadeStatus _brigadeStatus = BrigadeStatus.available;
  bool _mounted = true;

  late NotificationService _notificationService;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMockData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationProvider = Provider.of<NotificationProvider>(
          context, listen: false);

      _notificationService =
          NotificationService(notificationProvider, _navigatorKey);
    });
  }

  Future<void> _loadMockData() async {
    if (!_mounted) return;

    setState(() {
      _isLoading = true;
    });

    // Симуляция загрузки данных
    await Future.delayed(Duration(milliseconds: 800));

    if (!_mounted) return;

    setState(() {
      // Заглушечные данные для активных вызовов
      _activeCalls = [
        Call(
          id: '1',
          patientName: 'Асанов Усон',
          address: 'ул. Ленина, 42, кв. 15',
          timestamp: DateTime.now().subtract(Duration(minutes: 30)),
          callReason: 'Высокая температура',
          callType: 'Срочный',
          status: 'active',
        ),
        Call(
          id: '2',
          patientName: 'Бакирова Айгуль',
          address: 'ул. Курманжан Датка, 102',
          timestamp: DateTime.now().subtract(Duration(minutes: 15)),
          callReason: 'Боли в груди',
          callType: 'Экстренный',
          status: 'active',
        ),
      ];

      // Заглушечные данные для вызовов на проверке
      _pendingCalls = [
        Call(
          id: '3',
          patientName: 'Жумабеков Кубат',
          address: 'ул. Масалиева, 56',
          timestamp: DateTime.now().subtract(Duration(hours: 2)),
          callReason: 'Отравление',
          callType: 'Неотложный',
          status: 'pending',
        ),
      ];

      // Заглушечные данные для завершенных вызовов
      _completedCalls = [
        Call(
          id: '4',
          patientName: 'Турдубаева Чолпон',
          address: 'ул. Айтиева, 128, кв. 35',
          timestamp: DateTime.now().subtract(Duration(hours: 3)),
          callReason: 'Травма руки',
          callType: 'Плановый',
          status: 'completed',
        ),
        Call(
          id: '5',
          patientName: 'Нурлан уулу Азамат',
          address: 'ул. Киевская, 77, кв. 12',
          timestamp: DateTime.now().subtract(Duration(hours: 4)),
          callReason: 'Головокружение',
          callType: 'Неотложный',
          status: 'completed',
        ),
        Call(
          id: '6',
          patientName: 'Исаева Гульнара',
          address: 'ул. Токтогула, 214, кв. 8',
          timestamp: DateTime.now().subtract(Duration(hours: 5)),
          callReason: 'Сердечный приступ',
          callType: 'Экстренный',
          status: 'completed',
        ),
      ];

      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _mounted = false;
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _updateBrigadeStatus(BrigadeStatus status) async {
    if (!_mounted) return;

    setState(() {
      _isLoading = true;
    });

    // Симуляция обновления статуса
    await Future.delayed(Duration(milliseconds: 500));

    if (!_mounted) return;

    setState(() {
      _brigadeStatus = status;
      _isLoading = false;
    });

    // Показать диалог при определенных статусах
    if (!_mounted) return;

    if (status == BrigadeStatus.available) {
      _showInfoDialog(
        'Статус обновлен',
        'Бригада готова принимать вызовы.',
      );
    } else if (status == BrigadeStatus.pendingReview) {
      _showInfoDialog(
        'Карта отправлена на проверку',
        'Заполненная карта вызова отправлена на проверку старшему врачу.',
      );
    }
  }

  void _showInfoDialog(String title, String message) {
    if (!_mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('ОК'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final appProvider = Provider.of<AppProvider>(context);
    final dateFormat = DateFormat('dd.MM.yyyy');
    final today = dateFormat.format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text('АИС «Скорая помощь»'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadMockData,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(130),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Смена: $today',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Пользователь: ${authProvider.currentUser?.name ?? "Врач бригады"}',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              _buildBrigadeStatusSelector(),
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'Активные'),
                  Tab(text: 'На проверку'),
                  Tab(text: 'Архив'),
                ],
              ),
            ],
          ),
        ),
      ),
      drawer: _buildDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildActiveCallsTab(),
          _buildPendingCallsTab(),
          _buildCompletedCallsTab(),
        ],
      ),
    );
  }

  Widget _buildBrigadeStatusSelector() {
    return Container(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 8),
        children: [
          StatusButton(
            title: 'Свободен',
            isSelected: _brigadeStatus == BrigadeStatus.available,
            onPressed: () => _updateBrigadeStatus(BrigadeStatus.available),
          ),
          StatusButton(
            title: 'Выехали',
            isSelected: _brigadeStatus == BrigadeStatus.enRoute,
            onPressed: () => _updateBrigadeStatus(BrigadeStatus.enRoute),
          ),
          StatusButton(
            title: 'Прибыли',
            isSelected: _brigadeStatus == BrigadeStatus.arrived,
            onPressed: () => _updateBrigadeStatus(BrigadeStatus.arrived),
          ),
          StatusButton(
            title: 'Завершено',
            isSelected: _brigadeStatus == BrigadeStatus.completed,
            onPressed: () => _updateBrigadeStatus(BrigadeStatus.completed),
          ),
          StatusButton(
            title: 'На проверку СВ',
            isSelected: _brigadeStatus == BrigadeStatus.pendingReview,
            onPressed: () => _updateBrigadeStatus(BrigadeStatus.pendingReview),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 36,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Врач бригады №103',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Бригада: Линейная',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Главная'),
            selected: true,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('Журнал вызовов'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.callList);
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Профиль'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Настройки'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('О приложении'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Выйти из системы'),
            onTap: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCallsTab() {
    if (_activeCalls.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services_outlined,
              size: 72,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Нет активных вызовов',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            SizedBox(height: 8),
            Text(
              'Ожидайте новых вызовов',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: _activeCalls.length,
      itemBuilder: (context, index) {
        final call = _activeCalls[index];
        return CallItem(
          call: call,
          onTap: () {
            _navigateToCallDetail(call.id);
          },
        );
      },
    );
  }

  Widget _buildPendingCallsTab() {
    if (_pendingCalls.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pending_actions,
              size: 72,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Нет вызовов на проверке',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: _pendingCalls.length,
      itemBuilder: (context, index) {
        final call = _pendingCalls[index];
        return CallItem(
          call: call,
          onTap: () {
            _navigateToCallDetail(call.id);
          },
        );
      },
    );
  }

  Widget _buildCompletedCallsTab() {
    if (_completedCalls.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 72,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Нет завершенных вызовов',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: _completedCalls.length,
      itemBuilder: (context, index) {
        final call = _completedCalls[index];
        return CallItem(
          call: call,
          onTap: () {
            _navigateToCallDetail(call.id);
          },
        );
      },
    );
  }

  void _navigateToCallDetail(String callId) {
    // Заглушка для навигации к деталям вызова
    Future.delayed(Duration(seconds: 5), () {
      final Map<String, dynamic> testNotification = {
        'data': {
          'json': '{"id":123,"idOccassionNavName":"Температура","isUnknownPatient":false,"addressFull":"Ленина 12","fullName":"Иванов Иван","phoneCaller":"778123","phonePatient":"771333","strbrigadeSetupDate":"2025-02-20 08:00:00","brigadeId":1}',
          'employeeIds': [123, 45, 67],
          'cancelCall': 'false'
        },
        'topic': 'topic1'
      };

      _notificationService.triggerTestNotification(testNotification);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Переход к деталям вызова №$callId'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}