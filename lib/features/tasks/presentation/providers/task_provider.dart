import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/models/task_model.dart';


final taskProvider = FutureProvider<List<TaskModel>>((ref) async {
  return TaskRepository().fetchTasks();
});

