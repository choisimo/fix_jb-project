import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/report_provider.dart';
import '../widgets/report_card.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../shared/widgets/loading_overlay.dart';

class ReportListPage extends StatefulWidget {
  const ReportListPage({super.key});

  @override
  State<ReportListPage> createState() => _ReportListPageState();
}

class _ReportListPageState extends State<ReportListPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadReports();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    final reportProvider = context.read<ReportProvider>();
    await reportProvider.loadReports();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      final reportProvider = context.read<ReportProvider>();
      reportProvider.loadMoreReports();
    }
  }

  Future<void> _onRefresh() async {
    final reportProvider = context.read<ReportProvider>();
    await reportProvider.refreshReports();
  }

  void _onSearch(String query) {
    final reportProvider = context.read<ReportProvider>();
    reportProvider.searchReports(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('보고서 목록'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      body: const Placeholder(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.reportCreate);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('필터'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 필터 옵션들 구현
            Text('필터 기능 구현 예정'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('적용'),
          ),
        ],
      ),
    );
  }
}
