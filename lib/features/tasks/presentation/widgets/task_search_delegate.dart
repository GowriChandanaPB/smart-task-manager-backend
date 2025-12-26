import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/task_model.dart';
import '../providers/task_provider.dart';

class TaskSearchDelegate extends SearchDelegate {
  final WidgetRef ref;

  TaskSearchDelegate(this.ref);

  // -------------------------------
  // ACTIONS (clear button)
  // -------------------------------
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final tasksAsync = ref.watch(taskProvider);

    return tasksAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (_, __) =>
          const Center(child: Text('Failed to load tasks')),
      data: (tasks) {
        final results = tasks
            .where(
              (task) =>
                  task.title.toLowerCase().contains(query.toLowerCase()) ||
                  task.description
                      .toLowerCase()
                      .contains(query.toLowerCase()),
            )
            .toList();

        if (results.isEmpty) {
          return const Center(child: Text('No matching tasks'));
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (_, index) {
            final task = results[index];
            return ListTile(
              title: Text(task.title),
              subtitle: Text(task.category),
              onTap: () {
                close(context, null);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
