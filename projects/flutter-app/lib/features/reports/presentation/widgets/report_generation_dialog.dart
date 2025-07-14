import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/report_template.dart';
import '../providers/reports_provider.dart';

class ReportGenerationDialog extends ConsumerStatefulWidget {
  final ReportTemplate? template;
  
  const ReportGenerationDialog({Key? key, this.template}) : super(key: key);
  
  @override
  ConsumerState<ReportGenerationDialog> createState() => _ReportGenerationDialogState();
}

class _ReportGenerationDialogState extends ConsumerState<ReportGenerationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedCategory = 'operational';
  String _selectedFormat = 'pdf';
  DateTimeRange? _dateRange;
  Map<String, dynamic> _parameters = {};
  bool _useAI = true;
  bool _isGenerating = false;
  
  @override
  void initState() {
    super.initState();
    if (widget.template != null) {
      _titleController.text = widget.template!.name;
      _selectedCategory = widget.template!.category;
      _parameters = Map.from(widget.template!.defaultParameters);
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 600),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Generate AI-Powered Report',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Basic Information
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Report Title',
                    hintText: 'Enter a descriptive title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'Add any additional notes',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                
                // Category and Format
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedCategory,
                        items: const [
                          DropdownMenuItem(value: 'financial', child: Text('Financial')),
                          DropdownMenuItem(value: 'operational', child: Text('Operational')),
                          DropdownMenuItem(value: 'analytics', child: Text('Analytics')),
                          DropdownMenuItem(value: 'compliance', child: Text('Compliance')),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedCategory = value!);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Format',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedFormat,
                        items: const [
                          DropdownMenuItem(value: 'pdf', child: Text('PDF')),
                          DropdownMenuItem(value: 'excel', child: Text('Excel')),
                          DropdownMenuItem(value: 'csv', child: Text('CSV')),
                          DropdownMenuItem(value: 'json', child: Text('JSON')),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedFormat = value!);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Date Range
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.date_range),
                    title: const Text('Date Range'),
                    subtitle: Text(
                      _dateRange != null
                          ? '${_formatDate(_dateRange!.start)} - ${_formatDate(_dateRange!.end)}'
                          : 'Select date range',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: _selectDateRange,
                  ),
                ),
                const SizedBox(height: 16),
                
                // AI Options
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.psychology, color: Colors.purple),
                            const SizedBox(width: 8),
                            Text(
                              'AI Features',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Use AI Analysis'),
                          subtitle: const Text('Generate insights and recommendations'),
                          value: _useAI,
                          onChanged: (value) {
                            setState(() => _useAI = value);
                          },
                        ),
                        if (_useAI) ...[
                          CheckboxListTile(
                            title: const Text('Include Predictions'),
                            value: _parameters['includePredictions'] ?? false,
                            onChanged: (value) {
                              setState(() => _parameters['includePredictions'] = value);
                            },
                          ),
                          CheckboxListTile(
                            title: const Text('Anomaly Detection'),
                            value: _parameters['anomalyDetection'] ?? false,
                            onChanged: (value) {
                              setState(() => _parameters['anomalyDetection'] = value);
                            },
                          ),
                          CheckboxListTile(
                            title: const Text('Trend Analysis'),
                            value: _parameters['trendAnalysis'] ?? true,
                            onChanged: (value) {
                              setState(() => _parameters['trendAnalysis'] = value);
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Advanced Options
                ExpansionTile(
                  title: const Text('Advanced Options'),
                  children: [
                    ListTile(
                      title: const Text('Include Charts'),
                      trailing: Switch(
                        value: _parameters['includeCharts'] ?? true,
                        onChanged: (value) {
                          setState(() => _parameters['includeCharts'] = value);
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('Include Summary'),
                      trailing: Switch(
                        value: _parameters['includeSummary'] ?? true,
                        onChanged: (value) {
                          setState(() => _parameters['includeSummary'] = value);
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('Language'),
                      trailing: DropdownButton<String>(
                        value: _parameters['language'] ?? 'en',
                        items: const [
                          DropdownMenuItem(value: 'en', child: Text('English')),
                          DropdownMenuItem(value: 'es', child: Text('Spanish')),
                          DropdownMenuItem(value: 'fr', child: Text('French')),
                          DropdownMenuItem(value: 'ko', child: Text('Korean')),
                        ],
                        onChanged: (value) {
                          setState(() => _parameters['language'] = value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isGenerating ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _isGenerating ? null : _generateReport,
                      icon: _isGenerating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.auto_awesome),
                      label: Text(_isGenerating ? 'Generating...' : 'Generate Report'),
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
  
  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    
    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  Future<void> _generateReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_dateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date range'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() => _isGenerating = true);
    
    try {
      await ref.read(reportsProvider.notifier).generateReport(
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        format: _selectedFormat,
        dateRange: _dateRange!,
        useAI: _useAI,
        parameters: _parameters,
      );
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report generation started'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }
}

class ScheduleEditDialog extends ConsumerStatefulWidget {
  final ScheduledReport schedule;
  
  const ScheduleEditDialog({Key? key, required this.schedule}) : super(key: key);
  
  @override
  ConsumerState<ScheduleEditDialog> createState() => _ScheduleEditDialogState();
}

class _ScheduleEditDialogState extends ConsumerState<ScheduleEditDialog> {
  late String _frequency;
  late TimeOfDay _time;
  late List<int> _daysOfWeek;
  late int _dayOfMonth;
  
  @override
  void initState() {
    super.initState();
    _frequency = widget.schedule.frequency;
    _time = TimeOfDay.fromDateTime(widget.schedule.nextRun);
    _daysOfWeek = widget.schedule.daysOfWeek ?? [1];
    _dayOfMonth = widget.schedule.dayOfMonth ?? 1;
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Schedule: ${widget.schedule.name}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Frequency',
                border: OutlineInputBorder(),
              ),
              value: _frequency,
              items: const [
                DropdownMenuItem(value: 'daily', child: Text('Daily')),
                DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
              ],
              onChanged: (value) {
                setState(() => _frequency = value!);
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Time'),
              subtitle: Text(_time.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: _time,
                );
                if (picked != null) {
                  setState(() => _time = picked);
                }
              },
            ),
            if (_frequency == 'weekly') ...[
              const SizedBox(height: 16),
              const Text('Days of Week'),
              Wrap(
                spacing: 8,
                children: List.generate(7, (index) {
                  final day = index + 1;
                  return FilterChip(
                    label: Text(_getDayName(day)),
                    selected: _daysOfWeek.contains(day),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _daysOfWeek.add(day);
                        } else {
                          _daysOfWeek.remove(day);
                        }
                      });
                    },
                  );
                }),
              ),
            ],
            if (_frequency == 'monthly') ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Day of Month',
                  border: OutlineInputBorder(),
                ),
                value: _dayOfMonth,
                items: List.generate(28, (index) {
                  final day = index + 1;
                  return DropdownMenuItem(value: day, child: Text('$day'));
                }),
                onChanged: (value) {
                  setState(() => _dayOfMonth = value!);
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            await ref.read(reportsProvider.notifier).updateSchedule(
              widget.schedule.id,
              frequency: _frequency,
              time: _time,
              daysOfWeek: _daysOfWeek,
              dayOfMonth: _dayOfMonth,
            );
            if (mounted) {
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
  
  String _getDayName(int day) {
    switch (day) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }
}
