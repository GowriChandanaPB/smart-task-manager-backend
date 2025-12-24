import '../../../../core/network/dio_client.dart';
import '../models/task_model.dart';

class TaskRepository {
  Future<List<TaskModel>> fetchTasks() async {
    final response = await DioClient.dio.get('/tasks');
    final List tasks = response.data['tasks'];

    return tasks
        .map((e) => TaskModel.fromJson(e))
        .toList();
  }
  Future<Map<String, dynamic>> createTask(
      Map<String, dynamic> payload) async {
    final response = await DioClient.dio.post(
      '/tasks',
      data: payload,
    );

    return response.data as Map<String, dynamic>;
  }
  Future<void> updateTaskStatus({
  required String taskId,
  required String status,
}) async {
  await DioClient.dio.patch(
    '/tasks/$taskId',
    data: {
      'status': status,
    },
  );
}
Future<void> updateTask({
  required String taskId,
  required Map<String, dynamic> payload,
}) async {
  await DioClient.dio.put(
    '/tasks/$taskId',
    data: payload,
  );
}

Future<void> deleteTask(String taskId) async {
  await DioClient.dio.delete('/tasks/$taskId');
}


}
