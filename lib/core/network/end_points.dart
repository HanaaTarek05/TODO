abstract class EndPoints {
  static const String baseUrl = "https://ntitodo-production-8a7f.up.railway.app/api/";

  static const String login = 'login';
  static const String register = 'register';
  static const String changePassword = 'change_password';
  static const String refreshToken = 'refresh_token';
  static const String updateProfile = 'update_profile';
  static const String getUserData = 'get_user_data';
  static const String deleteUser = 'delete_user';

  static const String newTask = 'new_task';
  static const String tasks = 'tasks'; // used for tasks/{id}
  static const String myTasks = 'my_tasks';
}