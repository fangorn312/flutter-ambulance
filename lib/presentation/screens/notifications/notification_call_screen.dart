import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/notification_call.dart';
import '../../../domain/entities/cancel_reason.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/app_button.dart';

class NotificationCallScreen extends StatefulWidget {
  const NotificationCallScreen({Key? key}) : super(key: key);

  @override
  _NotificationCallScreenState createState() => _NotificationCallScreenState();
}

class _NotificationCallScreenState extends State<NotificationCallScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  CancelReason? _selectedReason;
  bool _showReasonDialog = false;

  @override
  void initState() {
    super.initState();

    // Setup animation for the pulsing effect
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleAccept(NotificationProvider provider) async {
    try {
      await provider.acceptCall();
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при принятии вызова: ${e.toString()}')),
      );
    }
  }

  void _showCancelReasonSelector() {
    setState(() {
      _showReasonDialog = true;
    });
  }

  Future<void> _handleReject(NotificationProvider provider) async {
    if (_selectedReason != null) {
      try {
        await provider.rejectCall(_selectedReason!.id);
        if (!mounted) return;
        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Ошибка при отклонении вызова: ${e.toString()}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Пожалуйста, выберите причину отказа')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final call = notificationProvider.activeCall;

    if (call == null) {
      return Container(); // Empty container if no call
    }

    return WillPopScope(
      onWillPop: () async => false, // Prevent back button
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              _buildCallInfo(call),
              if (_showReasonDialog) _buildReasonSelector(notificationProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCallInfo(NotificationCall call) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 20),
          _buildHeader(),
          SizedBox(height: 30),
          _buildPatientInfo(call),
          SizedBox(height: 30),
          _buildAddressInfo(call),
          SizedBox(height: 30),
          _buildReasonInfo(call),
          Spacer(),
          _buildActionButtons(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(
                  Icons.notifications_active,
                  color: Colors.red,
                  size: 64,
                ),
                SizedBox(height: 10),
                Text(
                  'НОВЫЙ ВЫЗОВ',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPatientInfo(NotificationCall call) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Пациент',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            Divider(),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, color: Colors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    call.isUnknownPatient
                        ? 'Пациент не известен'
                        : call.patientName,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.phone, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Пациент: ${call.patientPhone}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone_callback, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Вызывающий: ${call.callerPhone}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressInfo(NotificationCall call) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Адрес',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            Divider(),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.red),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    call.address,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Время: ${call.setupDate}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonInfo(NotificationCall call) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Причина вызова',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            Divider(),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.medical_services, color: Colors.red),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    call.occassionName,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final provider = Provider.of<NotificationProvider>(context);

    return !_showReasonDialog
        ? Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'ОТКЛОНИТЬ',
                  onPressed:
                      provider.isLoading ? null : _showCancelReasonSelector,
                  type: ButtonType.secondary,
                  icon: Icons.cancel,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: AppButton(
                  text: 'ПРИНЯТЬ',
                  onPressed:
                      provider.isLoading ? null : () => _handleAccept(provider),
                  icon: Icons.check_circle,
                  isLoading: provider.isLoading,
                ),
              ),
            ],
          )
        : Container(); // Hide buttons when showing reason selector
  }

  Widget _buildReasonSelector(NotificationProvider provider) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Выберите причину отказа',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                provider.isLoading
                    ? Container(
                        height: 150,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : provider.error.isNotEmpty
                        ? Container(
                            height: 150,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error_outline,
                                      color: Colors.red, size: 48),
                                  SizedBox(height: 16),
                                  Text(
                                    'Ошибка загрузки',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    provider.error,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 12),
                                  )
                                ],
                              ),
                            ),
                          )
                        : Container(
                            height: 250,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: provider.cancelReasons.length,
                              itemBuilder: (context, index) {
                                final reason = provider.cancelReasons[index];
                                return RadioListTile<CancelReason>(
                                  title: Text(reason.name),
                                  value: reason,
                                  groupValue: _selectedReason,
                                  onChanged: (CancelReason? value) {
                                    setState(() {
                                      _selectedReason = value;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showReasonDialog = false;
                          _selectedReason = null;
                        });
                      },
                      child: Text('Отмена'),
                    ),
                    ElevatedButton(
                      onPressed: provider.isLoading
                          ? null
                          : () => _handleReject(provider),
                      child: provider.isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : Text('Подтвердить'),
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
