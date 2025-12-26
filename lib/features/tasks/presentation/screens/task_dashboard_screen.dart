import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:smart_task_manager/core/network/network_provider.dart';
import 'package:smart_task_manager/core/theme/app_colors.dart';
import 'package:smart_task_manager/core/theme/theme_provider.dart';

import 'package:smart_task_manager/features/tasks/data/models/task_model.dart';
import 'package:smart_task_manager/features/tasks/data/repositories/task_repository.dart';
import 'package:smart_task_manager/features/tasks/presentation/providers/task_provider.dart';
import 'package:smart_task_manager/features/tasks/presentation/widgets/create_task_bottom_sheet.dart';
import 'package:smart_task_manager/features/tasks/presentation/widgets/task_search_delegate.dart';
import 'package:smart_task_manager/features/tasks/presentation/widgets/task_skeleton_card.dart';

class TaskDashboardScreen extends ConsumerStatefulWidget {
  const TaskDashboardScreen({super.key});

  @override
  ConsumerState<TaskDashboardScreen> createState() =>
      _TaskDashboardScreenState();
}

class _TaskDashboardScreenState
    extends ConsumerState<TaskDashboardScreen> {
  String _searchQuery = '';
  String? _selectedStatus;

  // -------------------------------
  // STATUS SUMMARY CARD
  // -------------------------------

  Widget _statusSummaryCard({
    required String label,
    required int count,
    required String status,
    required Color color,
  }) {
    final isSelected = _selectedStatus == status;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() {
            _selectedStatus =
                isSelected ? null : status; // toggle
          });
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withOpacity(0.9)
                : color.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(color: Colors.white, width: 2)
                : null,
          ),
          child: Column(
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------
  // STATUS ICON
  // -------------------------------

  Icon _statusIcon(String status) {
    switch (status) {
      case 'completed':
        return const Icon(Icons.check_circle,
            color: Colors.green, size: 22);
      default:
        return const Icon(Icons.radio_button_unchecked,
            color: Colors.grey, size: 22);
    }
  }

  // -------------------------------
  // PRIORITY BADGE
  // -------------------------------

  Widget _priorityBadge(String priority) {
    Color color;
    switch (priority) {
      case 'high':
        color = AppColors.highPriority;
        break;
      case 'medium':
        color = AppColors.mediumPriority;
        break;
      default:
        color = AppColors.lowPriority;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        priority.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  // -------------------------------
  // TRANSPARENT OUTLINED ICON BUTTON
  // -------------------------------

  Widget _outlinedIconButton({
    required IconData icon,
    required Color borderColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
      ),
    );
  }

  // -------------------------------
  // TASK ACTIONS
  // -------------------------------

  Future<void> _toggleTaskStatus(TaskModel task) async {
    final newStatus =
        task.status == 'completed' ? 'pending' : 'completed';

    await TaskRepository().updateTaskStatus(
      taskId: task.id,
      status: newStatus,
    );

    ref.invalidate(taskProvider);
  }

  Future<void> _confirmDelete(TaskModel task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Task'),
        content:
            const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await TaskRepository().deleteTask(task.id);
      ref.invalidate(taskProvider);
    }
  }

  // -------------------------------
  // TASK CARD
  // -------------------------------

  Widget _buildTaskCard(TaskModel task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => _toggleTaskStatus(task),
                  child: _statusIcon(task.status),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _priorityBadge(task.priority),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                Chip(label: Text(task.category)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _outlinedIconButton(
                  icon: Icons.edit,
                  borderColor: Colors.grey,
                  iconColor: Colors.grey,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) =>
                          CreateTaskBottomSheet(task: task),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _outlinedIconButton(
                  icon: Icons.delete,
                  borderColor: Colors.redAccent,
                  iconColor: Colors.redAccent,
                  onTap: () => _confirmDelete(task),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------
  // UI
  // -------------------------------

  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(taskProvider);
    final connectivity = ref.watch(connectivityProvider);

    return Scaffold(
      appBar: AppBar(
  title: const Text('Tasks'),
  actions: [
    // 🔍 Search icon
    IconButton(
      icon: const Icon(Icons.search),
      onPressed: () {
        showSearch(
          context: context,
          delegate: TaskSearchDelegate(ref),
        );
      },
    ),

    // 🌙 Theme toggle
    IconButton(
      icon: Icon(
        ref.watch(themeProvider) == ThemeMode.dark
            ? Icons.light_mode
            : Icons.dark_mode,
      ),
      onPressed: () {
        ref.read(themeProvider.notifier).toggleTheme();
      },
    ),
  ],
),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const CreateTaskBottomSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          connectivity.when(
            data: (r) => r == ConnectivityResult.none
                ? Container(
                    width: double.infinity,
                    color: Colors.red,
                    padding: const EdgeInsets.all(8),
                    child: const Text(
                      'No Internet Connection',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          Expanded(
            child: taskAsync.when(
              loading: () => ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: 6,
                itemBuilder: (_, __) =>
                    const TaskSkeletonCard(),
              ),
              error: (_, __) =>
                  const Center(child: Text('Unable to load tasks')),
              data: (tasks) {
                final pendingCount =
                    tasks.where((t) => t.status == 'pending').length;
                final inProgressCount =
                    tasks.where((t) => t.status == 'in_progress').length;
                final completedCount =
                    tasks.where((t) => t.status == 'completed').length;

                final filteredTasks = tasks.where((task) {
                  final matchesSearch = task.title
                      .toLowerCase()
                      .contains(_searchQuery);
                  final matchesStatus = _selectedStatus == null ||
                      task.status == _selectedStatus;
                  return matchesSearch && matchesStatus;
                }).toList();

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(taskProvider);
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      Row(
                        children: [
                          _statusSummaryCard(
                            label: 'Pending',
                            count: pendingCount,
                            status: 'pending',
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 12),
                          _statusSummaryCard(
                            label: 'In Progress',
                            count: inProgressCount,
                            status: 'in_progress',
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 12),
                          _statusSummaryCard(
                            label: 'Completed',
                            count: completedCount,
                            status: 'completed',
                            color: Colors.green,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...filteredTasks.map(_buildTaskCard),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}