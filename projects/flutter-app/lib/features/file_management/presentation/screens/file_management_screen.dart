import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/file_upload_widget.dart';
import '../widgets/file_list_widget.dart';
import '../widgets/file_analysis_result_widget.dart';
import '../../data/models/file_dto.dart';
import '../../data/providers/file_providers.dart';

class FileManagementScreen extends ConsumerStatefulWidget {
  const FileManagementScreen({Key? key}) : super(key: key);
  
  @override
  ConsumerState<FileManagementScreen> createState() => _FileManagementScreenState();
}

class _FileManagementScreenState extends ConsumerState<FileManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<String> _selectedTags = [];
  List<String> _appliedTags = [];
  String? _selectedTaskId;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('파일 관리 시스템'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '파일 업로드'),
            Tab(text: '파일 목록'),
            Tab(text: 'AI 분석'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(filesProvider),
            tooltip: '새로고침',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Upload tab
          _buildUploadTab(),
          
          // Files list tab
          _buildFilesTab(),
          
          // Analysis tab
          _buildAnalysisTab(),
        ],
      ),
    );
  }
  
  Widget _buildUploadTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              // File upload section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '파일 업로드',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      FileUploadWidget(
                        allowMultiple: true,
                        analyzeFiles: true,
                        tags: const ['demo', 'file-management'],
                        showTagSuggestions: true,
                        onUploadSuccess: (files) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${files.length}개의 파일이 업로드되었습니다'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          
                          // If this file has analysis, switch to analysis tab
                          if (files.isNotEmpty && files.last.analysisTaskId != null) {
                            setState(() {
                              _selectedTaskId = files.last.analysisTaskId;
                            });
                            _tabController.animateTo(2); // Switch to analysis tab
                          }
                        },
                        onUploadError: (error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('업로드 오류: ${error.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        },
                        onTagsSelected: (tags) {
                          setState(() {
                            _appliedTags = tags;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Files list section
              Text(
                '업로드된 파일',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const FileListWidget(
                showAnalysisStatus: true,
                allowDelete: true,
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFilesTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search by tags
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '태그로 검색',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: '태그 입력',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                final tag = _searchController.text.trim();
                                if (tag.isNotEmpty && !_selectedTags.contains(tag)) {
                                  setState(() {
                                    _selectedTags.add(tag);
                                    _searchController.clear();
                                  });
                                }
                              },
                            ),
                          ),
                          onSubmitted: (tag) {
                            if (tag.isNotEmpty && !_selectedTags.contains(tag)) {
                              setState(() {
                                _selectedTags.add(tag);
                                _searchController.clear();
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (_selectedTags.isNotEmpty) {
                            ref.refresh(fileSearchProvider(_selectedTags));
                          }
                        },
                        child: const Text('검색'),
                      ),
                    ],
                  ),
                  
                  if (_selectedTags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedTags.map((tag) => Chip(
                        label: Text(tag),
                        onDeleted: () {
                          setState(() {
                            _selectedTags.remove(tag);
                          });
                        },
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Files list
          Text(
            _selectedTags.isEmpty ? '업로드된 모든 파일' : '검색 결과',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _selectedTags.isEmpty
              ? const FileListWidget(
                  showAnalysisStatus: true,
                  allowDelete: true,
                )
              : Consumer(
                  builder: (context, ref, child) {
                    final searchResult = ref.watch(fileSearchProvider(_selectedTags));
                    
                    return searchResult.when(
                      data: (files) {
                        if (files.isEmpty) {
                          return const Center(
                            child: Text('검색된 파일이 없습니다'),
                          );
                        }
                        
                        return FileListWidget(
                          files: files,
                          showAnalysisStatus: true,
                          allowDelete: true,
                          onAnalysisSelected: (taskId) {
                            setState(() {
                              _selectedTaskId = taskId;
                            });
                            _tabController.animateTo(2); // Switch to analysis tab
                          },
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, _) => Center(
                        child: Text('검색 오류: $error'),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnalysisTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedTaskId != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '파일 분석 결과',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    FileAnalysisResultWidget(
                      taskId: _selectedTaskId!,
                      showSuggestedTags: true,
                      onApplyTags: (tags) {
                        setState(() {
                          _selectedTags = tags;
                        });
                        _tabController.animateTo(1); // Switch to files tab
                        // Trigger search with these tags
                        ref.refresh(fileSearchProvider(_selectedTags));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ] else [
            const Center(
              child: Text('분석할 파일을 선택해주세요'),
            ),
          ],
        ],
      ),
    );
  }
}
