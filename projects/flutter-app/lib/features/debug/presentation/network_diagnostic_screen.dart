import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import '../../../core/services/network_test_service.dart';
import '../../../core/providers/service_provider.dart';

class NetworkDiagnosticScreen extends ConsumerStatefulWidget {
  const NetworkDiagnosticScreen({super.key});

  @override
  ConsumerState<NetworkDiagnosticScreen> createState() => _NetworkDiagnosticScreenState();
}

class _NetworkDiagnosticScreenState extends ConsumerState<NetworkDiagnosticScreen> {
  Map<String, dynamic>? _diagnosticResult;
  bool _isRunning = false;
  late NetworkDiagnosticService _networkDiagnosticService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dio = ref.read(aiDioProvider);
      _networkDiagnosticService = NetworkDiagnosticService(dio);
    });
  }

  Future<void> _runDiagnostic() async {
    setState(() {
      _isRunning = true;
      _diagnosticResult = null;
    });

    try {
      developer.log('🔧 Starting network diagnostic...', name: 'DIAGNOSTIC_SCREEN');
      final result = await _networkDiagnosticService.runComprehensiveDiagnostic();
      
      setState(() {
        _diagnosticResult = result;
        _isRunning = false;
      });
      
      developer.log('✅ Network diagnostic completed', name: 'DIAGNOSTIC_SCREEN');
    } catch (e) {
      developer.log('❌ Network diagnostic failed: $e', name: 'DIAGNOSTIC_SCREEN');
      setState(() {
        _diagnosticResult = {
          'overall': {'success': false},
          'error': e.toString(),
        };
        _isRunning = false;
      });
    }
  }

  Future<void> _checkWebhooks() async {
    final webhookService = ref.read(webhookServiceProvider);
    
    setState(() {
      _isRunning = true;
    });

    try {
      developer.log('🔧 Checking webhooks...', name: 'DIAGNOSTIC_SCREEN');
      final results = await webhookService.checkWebhookUrls();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Webhook check results: ${results.toString()}'),
            backgroundColor: results.values.any((success) => success) ? Colors.green : Colors.red,
          ),
        );
      }
      
      developer.log('✅ Webhook check completed: $results', name: 'DIAGNOSTIC_SCREEN');
    } catch (e) {
      developer.log('❌ Webhook check failed: $e', name: 'DIAGNOSTIC_SCREEN');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Webhook check failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Diagnostic'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Network Connection Test',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                       'Check connection to AI Analysis Server and webhook endpoints',                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isRunning ? null : _runDiagnostic,
                            icon: _isRunning 
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.network_check),
                            label: Text(_isRunning ? 'Running...' : 'Run Diagnostic'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isRunning ? null : _checkWebhooks,
                            icon: const Icon(Icons.webhook),
                            label: const Text('Check Webhooks'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_diagnosticResult != null) ...[
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _diagnosticResult!['overall']['success'] == true
                                  ? Icons.check_circle
                                  : Icons.error,
                              color: _diagnosticResult!['overall']['success'] == true
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Diagnostic Results',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildResultSection('Health Check', _diagnosticResult!['healthCheck']),
                                const SizedBox(height: 16),
                                _buildResultSection('Image Upload Check', _diagnosticResult!['imageUploadTest']),
                                const SizedBox(height: 16),
                                _buildResultSection('Overall', _diagnosticResult!['overall']),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultSection(String title, Map<String, dynamic>? data) {
    if (data == null) return const SizedBox.shrink();

    final isSuccess = data['success'] == true;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSuccess ? Colors.green : Colors.red,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isSuccess ? Icons.check : Icons.close,
                color: isSuccess ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...data.entries.map((entry) => Padding(
            padding: const EdgeInsets.only(left: 24, bottom: 4),
            child: Text(
              '${entry.key}: ${entry.value}',
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          )),
        ],
      ),
    );
  }
}