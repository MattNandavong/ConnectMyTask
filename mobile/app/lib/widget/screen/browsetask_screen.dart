import 'package:app/model/task.dart';
import 'package:app/widget/browse_task/task_items_card.dart';
import 'package:flutter/material.dart';
import 'package:app/utils/task_service.dart';
import 'package:app/widget/filter_sorting_task.dart';

class BrowseTask extends StatefulWidget {
  const BrowseTask({super.key});

  @override
  State<BrowseTask> createState() => _BrowseTaskState();
}

class _BrowseTaskState extends State<BrowseTask> {
  late Future<List<Task>> _tasks;

  List<Task> _allTasks = [];
  List<Task> _filteredTasks = [];

  List<String> _selectedCategories = [];
  double _minBudget = 0;
  double _maxBudget = 100;
  bool _remoteOnly = false;
  String _selectedSort = 'Recent';
  String _selectedStatus = 'All';

  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    TaskService().getAllTasks().then((tasks) {
      setState(() {
        _allTasks = tasks;
        _applyFilters();
      });
    });
  }

  void _applyFilters() {
    List<Task> tasks = _allTasks;

    if (_searchQuery.isNotEmpty) {
      tasks =
          tasks
              .where(
                (t) =>
                    t.title.toLowerCase().contains(_searchQuery) ||
                    t.description.toLowerCase().contains(_searchQuery) ||
                    t.category.toLowerCase().contains(_searchQuery),
                // optionally add: || t.category.toLowerCase().contains(_searchQuery)
              )
              .toList();
    }

    if (_selectedCategories.isNotEmpty) {
      tasks =
          tasks.where((t) => _selectedCategories.contains(t.category)).toList();
    }

    if (_selectedStatus != 'All') {
      tasks = tasks.where((t) => t.status == _selectedStatus).toList();
    }

    if (_remoteOnly) {
      tasks = tasks.where((t) => t.location == 'Remote').toList();
    }

    tasks = tasks.where((t) => t.budget >= _minBudget).toList();

    switch (_selectedSort) {
      case 'Recent':
        tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Highest Budget':
        tasks.sort((a, b) => b.budget.compareTo(a.budget));
        break;
      case 'Lowest Budget':
        tasks.sort((a, b) => a.budget.compareTo(b.budget));
        break;
    }

    _filteredTasks = tasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Container(
              // height: 60,
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Row(
                children: [
                  // Search field takes up most of the space
                  Expanded(
                    flex: 4,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(0),

                        // labelText: 'Search tasks...',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide(
                            width: 1,
                            color: Colors.transparent,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                          borderSide: BorderSide(
                            width: 1,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        // focusColor: Colors.blueGrey,
                        labelText: 'Search tasks...',
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        prefixIcon: Icon(Icons.search),
                        suffixIcon:
                            _searchQuery.isNotEmpty
                                ? IconButton(
                                  icon: Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _searchQuery = '';
                                      _searchController.clear();
                                      _applyFilters();
                                    });
                                  },
                                )
                                : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                          _applyFilters();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Filter button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.filter_alt),
                      label: const Text('Filter'),
                      // style: ElevatedButton.styleFrom(
                      //   padding: const EdgeInsets.symmetric(vertical: 16),
                      // ),
                      onPressed: () {
                        showTaskFilterModal(
                          context: context,
                          selectedCategories: _selectedCategories,
                          minBudget: _minBudget,
                          maxBudget: _maxBudget,
                          remoteOnly: _remoteOnly,
                          selectedSort: _selectedSort,
                          selectedStatus: _selectedStatus,
                          onApply: ({
                            required List<String> categories,
                            required double min,
                            required double max,
                            required bool remote,
                            required String sort,
                            required String status,
                          }) {
                            setState(() {
                              _selectedCategories = categories;
                              _minBudget = min;
                              _maxBudget = max;
                              _remoteOnly = remote;
                              _selectedSort = sort;
                              _selectedStatus = status;
                              _applyFilters();
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // FutureBuilder<List<Task>>(
            //   future: _tasks,
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return Center(child: CircularProgressIndicator());
            //     }
            //     if (snapshot.hasError) {
            //       return Center(child: Text('Error: ${snapshot.error}'));
            //     }
            //     if (!snapshot.hasData || snapshot.data!.isEmpty) {
            //       return Center(child: Text('No tasks found'));
            //     }
            //     return Padding(
            //       padding: const EdgeInsets.all(10.0),
            //       child: ListView.builder(
            //         itemCount: snapshot.data!.length,
            //         itemBuilder: (context, index) {
            //           final task = snapshot.data![index];
            //           return TaskCard(context: context, task: task);
            //         },
            //       ),
            //     );
            //   },
            // ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  final tasks = await TaskService().getAllTasks();
                  setState(() {
                    _allTasks = tasks;
                    _applyFilters();
                  });
                },
                child:
                    _filteredTasks.isEmpty
                        ? ListView(
                          children: const [
                            SizedBox(height: 200),
                            Center(child: Text('No tasks found')),
                          ],
                        )
                        : ListView.builder(
                          itemCount: _filteredTasks.length,
                          itemBuilder: (context, index) {
                            final task = _filteredTasks[index];
                            return TaskCard(context: context, task: task);
                          },
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
