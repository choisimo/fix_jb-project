import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  final String target; // 휴대폰 번호 또는 이메일
  final String type; // 'sms' 또는 'email'
  final VoidCallback onVerified;

  const VerificationScreen({
    Key? key,
    required this.target,
    required this.type,
    required this.onVerified,
  }) : super(key: key);

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  final TextEditingController _codeController = TextEditingController();
  Timer? _timer;
  int _remainingTime = 300; // 5분
  bool _isLoading = false;
  bool _isResendEnabled = false;

  @override
  void initState() {
    super.initState();
    _sendVerificationCode();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        setState(() {
          _isResendEnabled = true;
        });
        timer.cancel();
      }
    });
  }

  Future<void> _sendVerificationCode() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.dio.post(
        '/api/verification/${widget.type}/send',
        data: {'target': widget.target},
      );

      if (response.statusCode == 200) {
        _showSnackBar('인증번호가 발송되었습니다.', Colors.green);
      } else {
        _showSnackBar('인증번호 발송에 실패했습니다.', Colors.red);
      }
    } catch (e) {
      _showSnackBar('네트워크 오류가 발생했습니다.', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyCode() async {
    if (_codeController.text.length != 6) {
      _showSnackBar('6자리 인증번호를 입력해주세요.', Colors.orange);
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.dio.post(
        '/api/verification/${widget.type}/verify',
        data: {
          'target': widget.target,
          'code': _codeController.text,
        },
      );

      if (response.statusCode == 200) {
        _showSnackBar('인증이 완료되었습니다.', Colors.green);
        widget.onVerified();
        Navigator.of(context).pop(true);
      } else {
        _showSnackBar('인증번호가 올바르지 않습니다.', Colors.red);
      }
    } catch (e) {
      _showSnackBar('네트워크 오류가 발생했습니다.', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendCode() async {
    setState(() {
      _remainingTime = 300;
      _isResendEnabled = false;
    });
    _startTimer();
    await _sendVerificationCode();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String get _formatTime {
    final minutes = _remainingTime ~/ 60;
    final seconds = _remainingTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.type == 'sms' ? 'SMS' : '이메일'} 인증'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            
            // 아이콘
            Icon(
              widget.type == 'sms' ? Icons.sms : Icons.email,
              size: 80,
              color: Colors.blue[600],
            ),
            
            const SizedBox(height: 32),
            
            // 안내 메시지
            Text(
              '${widget.target}으로\n인증번호를 발송했습니다.',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            Text(
              '5분 내에 인증번호를 입력해주세요.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 40),
            
            // 인증번호 입력 필드
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
              decoration: const InputDecoration(
                labelText: '인증번호',
                hintText: '6자리 숫자',
                border: OutlineInputBorder(),
                counterText: '',
              ),
              onChanged: (value) {
                if (value.length == 6) {
                  _verifyCode();
                }
              },
            ),
            
            const SizedBox(height: 16),
            
            // 남은 시간 표시
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.timer,
                  size: 16,
                  color: _remainingTime < 60 ? Colors.red : Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTime,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _remainingTime < 60 ? Colors.red : Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // 인증 확인 버튼
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      '인증 확인',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            
            const SizedBox(height: 16),
            
            // 재발송 버튼
            TextButton(
              onPressed: _isResendEnabled && !_isLoading ? _resendCode : null,
              child: Text(
                '인증번호 재발송',
                style: TextStyle(
                  fontSize: 14,
                  color: _isResendEnabled ? Colors.blue[600] : Colors.grey[400],
                ),
              ),
            ),
            
            const Spacer(),
            
            // 도움말
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '인증번호가 오지 않나요?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.type == 'sms'
                        ? '• 스팸함을 확인해보세요\n• 휴대폰 번호를 다시 확인해보세요\n• 수신거부 설정을 확인해보세요'
                        : '• 스팸함을 확인해보세요\n• 이메일 주소를 다시 확인해보세요\n• 메일 차단 설정을 확인해보세요',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}