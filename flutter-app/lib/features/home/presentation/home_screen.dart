import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/presentation/controllers/auth_controller.dart';
import '../../report/presentation/controllers/report_list_controller.dart';
import '../../report/presentation/widgets/report_card.dart';
import 'package:jb_report_app/features/report/domain/models/report_state.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialReports();
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  void _loadInitialReports() {
    ref.read(reportListControllerProvider.notifier).loadReports(refresh: true);
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(reportListControllerProvider.notifier).loadMoreReports();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportListControllerProvider);
    final authState = ref.watch(authControllerProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('JB Report'),
        centerTitle: true,
        leading: null,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
          PopupMenuButton<String>(
            icon: CircleAvatar(
              radius: 16,
              backgroundImage: authState.user?.profileImageUrl != null
                  ? NetworkImage(authState.user!.profileImageUrl!)
                  : null,
              child: authState.user?.profileImageUrl == null
                  ? Text(
                      authState.user?.fullName?.substring(0, 1).toUpperCase() ?? 
                      authState.user?.username.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(fontSize: 14),
                    )
                  : null,
            ),
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  context.push('/profile');
                  break;
                case 'my_reports':
                  context.push('/my-reports');
                  break;
                case 'bookmarks':
                  context.push('/bookmarks');
                  break;
                case 'settings':
                  context.push('/settings');
                  break;
                case 'logout':
                  _logout();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profile'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'my_reports',
                child: ListTile(
                  leading: Icon(Icons.report),
                  title: Text('My Reports'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'bookmarks',
                child: ListTile(
                  leading: Icon(Icons.bookmark),
                  title: Text('Bookmarks'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Logout', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(reportListControllerProvider.notifier).refreshReports();
        },
        child: _buildBody(reportState),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/reports/create'),
        icon: const Icon(Icons.add),
        label: const Text('Report Issue'),
      ),
    );
  }

  Widget _buildBody(ReportListState reportState) {
    switch (reportState.status) {
      case ReportListStatus.initial:
      case ReportListStatus.loading:
        return const Center(child: CircularProgressIndicator());
        
      case ReportListStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading reports',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                reportState.error ?? 'Unknown error occurred',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(reportListControllerProvider.notifier).refreshReports();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        );
        
      case ReportListStatus.loaded:
        if (reportState.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.report_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'No reports yet',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Be the first to report an issue',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.push('/reports/create'),
                  child: const Text('Create First Report'),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: reportState.reports.length + (reportState.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == reportState.reports.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            final report = reportState.reports[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ReportCard(
                report: report,
                onTap: () => context.push('/reports/${report.id}'),
                onLike: () => ref.read(reportListControllerProvider.notifier)
                    .toggleLike(report.id),
                onBookmark: () => ref.read(reportListControllerProvider.notifier)
                    .toggleBookmark(report.id),
              ),
            );
          },
        );
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Reports'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Enter search terms...',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            Navigator.pop(context);
            ref.read(reportListControllerProvider.notifier).searchReports(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    // TODO: Implement filter dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filter feature coming soon')),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authControllerProvider.notifier).logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
