import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/report_filter.dart';

/// 신고서 필터링을 위한 다이얼로그
class ReportFilterDialog extends StatefulWidget {
  final ReportFilter initialFilter;
  final Function(ReportFilter) onApplyFilter;

  const ReportFilterDialog({
    super.key,
    required this.initialFilter,
    required this.onApplyFilter,
  });

  @override
  State<ReportFilterDialog> createState() => _ReportFilterDialogState();
}

class _ReportFilterDialogState extends State<ReportFilterDialog> {
  late ReportFilter _currentFilter;
  final TextEditingController _keywordController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.initialFilter;
    _keywordController.text = _currentFilter.keyword;
    _locationController.text = _currentFilter.location ?? '';
  }

  @override
  void dispose() {
    _keywordController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        '필터 설정',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildKeywordSection(),
              const SizedBox(height: 20),
              _buildCategoriesSection(),
              const SizedBox(height: 20),
              _buildStatusesSection(),
              const SizedBox(height: 20),
              _buildPrioritiesSection(),
              const SizedBox(height: 20),
              _buildDateRangeSection(),
              const SizedBox(height: 20),
              _buildLocationSection(),
              const SizedBox(height: 20),
              _buildOptionsSection(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _resetFilter,
          child: const Text('초기화'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _applyFilter,
          child: const Text('적용'),
        ),
      ],
    );
  }

  Widget _buildKeywordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '키워드 검색',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _keywordController,
          decoration: const InputDecoration(
            hintText: '제목, 내용, 주소에서 검색',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() {
              _currentFilter = _currentFilter.copyWith(keyword: value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '카테고리',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: FilterOptions.categories.map((category) {
            final isSelected = _currentFilter.categories.contains(category);
            return FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  List<String> newCategories = List.from(_currentFilter.categories);
                  if (selected) {
                    newCategories.add(category);
                  } else {
                    newCategories.remove(category);
                  }
                  _currentFilter = _currentFilter.copyWith(categories: newCategories);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatusesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '상태',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: FilterOptions.statuses.map((status) {
            final isSelected = _currentFilter.statuses.contains(status);
            return FilterChip(
              label: Text(status),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  List<String> newStatuses = List.from(_currentFilter.statuses);
                  if (selected) {
                    newStatuses.add(status);
                  } else {
                    newStatuses.remove(status);
                  }
                  _currentFilter = _currentFilter.copyWith(statuses: newStatuses);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPrioritiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '우선순위',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: FilterOptions.priorities.map((priority) {
            final displayName = FilterOptions.getPriorityDisplayName(priority);
            final isSelected = _currentFilter.priorities.contains(priority);
            return FilterChip(
              label: Text(displayName),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  List<String> newPriorities = List.from(_currentFilter.priorities);
                  if (selected) {
                    newPriorities.add(priority);
                  } else {
                    newPriorities.remove(priority);
                  }
                  _currentFilter = _currentFilter.copyWith(priorities: newPriorities);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '기간',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(true),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _currentFilter.startDate != null
                        ? DateFormat('yyyy-MM-dd').format(_currentFilter.startDate!)
                        : '시작일',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text('~'),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(false),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _currentFilter.endDate != null
                        ? DateFormat('yyyy-MM-dd').format(_currentFilter.endDate!)
                        : '종료일',
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '위치',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _locationController,
          decoration: const InputDecoration(
            hintText: '주소 또는 지역명',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_on),
          ),
          onChanged: (value) {
            setState(() {
              _currentFilter = _currentFilter.copyWith(
                location: value.isEmpty ? null : value,
              );
            });
          },
        ),
        if (_currentFilter.location != null && _currentFilter.location!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('반경: '),
              Expanded(
                child: Slider(
                  value: _currentFilter.radiusKm,
                  min: 1.0,
                  max: 50.0,
                  divisions: 49,
                  label: '${_currentFilter.radiusKm.toInt()}km',
                  onChanged: (value) {
                    setState(() {
                      _currentFilter = _currentFilter.copyWith(radiusKm: value);
                    });
                  },
                ),
              ),
              Text('${_currentFilter.radiusKm.toInt()}km'),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '옵션',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          title: const Text('내 신고서만'),
          value: _currentFilter.onlyMyReports,
          onChanged: (value) {
            setState(() {
              _currentFilter = _currentFilter.copyWith(onlyMyReports: value ?? false);
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: const Text('복잡한 주제만'),
          value: _currentFilter.onlyComplexSubjects,
          onChanged: (value) {
            setState(() {
              _currentFilter = _currentFilter.copyWith(onlyComplexSubjects: value ?? false);
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: const Text('이미지 포함만'),
          value: _currentFilter.onlyWithImages,
          onChanged: (value) {
            setState(() {
              _currentFilter = _currentFilter.copyWith(onlyWithImages: value ?? false);
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate 
          ? (_currentFilter.startDate ?? DateTime.now())
          : (_currentFilter.endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _currentFilter = _currentFilter.copyWith(startDate: picked);
        } else {
          _currentFilter = _currentFilter.copyWith(endDate: picked);
        }
      });
    }
  }

  void _resetFilter() {
    setState(() {
      _currentFilter = const ReportFilter();
      _keywordController.text = '';
      _locationController.text = '';
    });
  }

  void _applyFilter() {
    widget.onApplyFilter(_currentFilter);
    Navigator.of(context).pop();
  }
}