import 'dart:async';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import '../../services/api_service.dart';

class NotificationHandler extends StatefulWidget {
  final Widget child;
  final VoidCallback onUpdate;

  const NotificationHandler({
    Key? key,
    required this.child,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _NotificationHandlerState createState() => _NotificationHandlerState();
}

class _NotificationHandlerState extends State<NotificationHandler>
    with WidgetsBindingObserver {
  Timer? _notificationTimer;
  final ApiService _apiService = ApiService();
  DateTime? _lastNotificationTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupNotificationCheck();
  }

  void _setupNotificationCheck() {
    _notificationTimer = Timer.periodic(
      Duration(minutes: 1), // Check for updates every minute
      (_) => _checkForUpdates(),
    );
    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    try {
      final hasUpdates = await _apiService.checkForUpdates();

      if (hasUpdates && mounted) {
        final now = DateTime.now();
        if (_lastNotificationTime == null ||
            now.difference(_lastNotificationTime!) > const Duration(minutes: 5)) {
          _showUpdateNotification();
          _lastNotificationTime = now;
          widget.onUpdate(); // Refresh the schedule data
        }
      }
    } catch (e) {
      print('Error checking for updates: $e');
    }
  }

  void _showUpdateNotification() {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecond,
        channelKey: 'basic_channel',
        title: 'Schedule Update Available',
        body: 'Your class schedule has been updated. Tap to view changes.',
        notificationLayout: NotificationLayout.Default,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'VIEW_UPDATES',
          label: 'View Updates',
        ),
      ],
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkForUpdates();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void dispose() {
    _notificationTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}