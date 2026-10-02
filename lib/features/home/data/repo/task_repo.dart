import '../../../../core/network/api_helper.dart';
import '../../../../core/network/end_points.dart';
import '../models/task_model.dart';

class TaskRepo {
  final ApiHelper _apiHelper;

  TaskRepo([ApiHelper? apiHelper]) : _apiHelper = apiHelper ?? ApiHelper();

  Future<List<TaskModel>> getMyTasks() async {
    try {
      final response = await _apiHelper.getRequest(
        endPoint: EndPoints.myTasks,
        isPrivate: true,
      );

      if (response.data is List) {
        return (response.data as List)
            .map((taskJson) => TaskModel.fromJson(taskJson))
            .toList();
      } else if (response.data is Map && response.data['tasks'] is List) {
        return (response.data['tasks'] as List)
            .map((taskJson) => TaskModel.fromJson(taskJson))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<TaskModel> createNewTask({
    required String title,
    required String description,
    String? imagePath,
  }) async {
    try {
      final imageData = imagePath != null ? await _apiHelper.getImageData(imagePath) : '';
      final Map<String, dynamic> data = {
        'title': title,
        'description': description,
        if (imageData != '') 'image': imageData,
      };

      final response = await _apiHelper.postRequest(
        endPoint: EndPoints.newTask,
        data: data,
        isFormData: true,
        isPrivate: true,
      );

      if (response.data is Map<String, dynamic> && response.data['task'] != null) {
        return TaskModel.fromJson(response.data['task']);
      }
      return TaskModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<TaskModel> updateTask({
    required int taskId,
    required String title,
    required String description,
    String? imagePath,
  }) async {
    try {
      final imageData = imagePath != null ? await _apiHelper.getImageData(imagePath) : '';
      final Map<String, dynamic> data = {
        'title': title,
        'description': description,
        if (imageData != '') 'image': imageData,
      };

      final response = await _apiHelper.putRequest(
        endPoint: "${EndPoints.tasks}/$taskId",
        data: data,
        isFormData: true,
        isPrivate: true,
      );

      if (response.data is Map<String, dynamic> && response.data['task'] != null) {
        return TaskModel.fromJson(response.data['task']);
      }
      return TaskModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTask({required int taskId}) async {
    try {
      await _apiHelper.deleteRequest(
        endPoint: "${EndPoints.tasks}/$taskId",
        isPrivate: true,
      );
    } catch (e) {
      rethrow;
    }
  }
}
