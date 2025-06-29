import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _reportStatusUpdates = true;
  bool _newReportAlerts = false;
  bool _maintenanceAlerts = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushNotifications = prefs.getBool('push_notifications') ?? true;
      _emailNotifications = prefs.getBool('email_notifications') ?? false;
      _reportStatusUpdates = prefs.getBool('report_status_updates') ?? true;
      _newReportAlerts = prefs.getBool('new_report_alerts') ?? false;
      _maintenanceAlerts = prefs.getBool('maintenance_alerts') ?? true;
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('push_notifications', _pushNotifications);
    await prefs.setBool('email_notifications', _emailNotifications);
    await prefs.setBool('report_status_updates', _reportStatusUpdates);
    await prefs.setBool('new_report_alerts', _newReportAlerts);
    await prefs.setBool('maintenance_alerts', _maintenanceAlerts);
    await prefs.setBool('sound_enabled', _soundEnabled);
    await prefs.setBool('vibration_enabled', _vibrationEnabled);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('알림 설정이 저장되었습니다'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림 설정'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveSettings),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('기본 알림'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('푸시 알림'),
                  subtitle: const Text('앱 알림을 받습니다'),
                  value: _pushNotifications,
                  onChanged: (value) {
                    setState(() {
                      _pushNotifications = value;
                    });
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('이메일 알림'),
                  subtitle: const Text('이메일로 알림을 받습니다'),
                  value: _emailNotifications,
                  onChanged: (value) {
                    setState(() {
                      _emailNotifications = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('알림 유형'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('보고서 상태 업데이트'),
                  subtitle: const Text('내 보고서의 처리 상태가 변경될 때 알림'),
                  value: _reportStatusUpdates,
                  onChanged: _pushNotifications
                      ? (value) {
                          setState(() {
                            _reportStatusUpdates = value;
                          });
                        }
                      : null,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('새 보고서 알림'),
                  subtitle: const Text('새로운 보고서가 등록될 때 알림'),
                  value: _newReportAlerts,
                  onChanged: _pushNotifications
                      ? (value) {
                          setState(() {
                            _newReportAlerts = value;
                          });
                        }
                      : null,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('유지보수 알림'),
                  subtitle: const Text('시스템 유지보수 및 업데이트 알림'),
                  value: _maintenanceAlerts,
                  onChanged: _pushNotifications
                      ? (value) {
                          setState(() {
                            _maintenanceAlerts = value;
                          });
                        }
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('알림 방식'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('소리'),
                  subtitle: const Text('알림 소리를 재생합니다'),
                  value: _soundEnabled,
                  onChanged: _pushNotifications
                      ? (value) {
                          setState(() {
                            _soundEnabled = value;
                          });
                        }
                      : null,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('진동'),
                  subtitle: const Text('알림 시 진동을 사용합니다'),
                  value: _vibrationEnabled,
                  onChanged: _pushNotifications
                      ? (value) {
                          setState(() {
                            _vibrationEnabled = value;
                          });
                        }
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.notifications_active,
                color: Colors.blue,
              ),
              title: const Text('알림 테스트'),
              subtitle: const Text('알림이 정상적으로 작동하는지 확인'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _testNotification,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            '※ 푸시 알림이 비활성화되면 모든 세부 알림도 비활성화됩니다.',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  void _testNotification() {
    if (!_pushNotifications) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('푸시 알림이 비활성화되어 있습니다. 설정에서 활성화해주세요.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // 현재 알림 설정 상태 확인
    final notificationTypes = <String>[];
    if (_reportStatusUpdates) notificationTypes.add('신고서 상태 업데이트');
    if (_newReportAlerts) notificationTypes.add('새 신고 알림');
    if (_maintenanceAlerts) notificationTypes.add('유지보수 알림');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.notifications_active, color: Colors.green),
            const SizedBox(width: 8),
            const Text('알림 테스트'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📱 테스트 알림이 발송되었습니다!'),
            const SizedBox(height: 12),
            const Text(
              '현재 활성화된 알림 유형:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (notificationTypes.isEmpty)
              const Text(
                '• 활성화된 알림 유형이 없습니다',
                style: TextStyle(color: Colors.grey),
              )
            else
              ...notificationTypes.map((type) => Text('• $type')),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  _soundEnabled ? Icons.volume_up : Icons.volume_off,
                  size: 16,
                  color: _soundEnabled ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text('소리: ${_soundEnabled ? "켜짐" : "꺼짐"}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  _vibrationEnabled ? Icons.vibration : Icons.phonelink_erase,
                  size: 16,
                  color: _vibrationEnabled ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text('진동: ${_vibrationEnabled ? "켜짐" : "꺼짐"}'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 8),
                      const Text('알림 테스트 완료!'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('다시 테스트'),
          ),
        ],
      ),
    );

    // 실제 알림 시뮬레이션
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.notifications, color: Colors.white),
            SizedBox(width: 8),
            Text('테스트 알림: 전북 신고 앱'),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: '확인',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}
