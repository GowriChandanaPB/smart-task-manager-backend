import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/task_repository.dart';

final createTaskProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>(
  (ref, payload) async {
    return TaskRepository().createTask(payload);
  },
);
