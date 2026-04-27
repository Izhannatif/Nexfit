import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/PersonalGoals.dart';
class ApiService {
  static const String baseUrl = 'http://192.168.1.13:8001';

  Future<Map<String, dynamic>> getUserData(int userId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/userdata/$userId/'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<Map<String, dynamic>> getTrainerData(int userId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/trainerdata/$userId/'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<List<dynamic>> getExercisesData() async {
    final response = await http.get(Uri.parse('$baseUrl/api/exercises/'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load Exercises data');
    }
  }
  
  Future<List<dynamic>> getUserPurchases(int gymUserId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/$gymUserId/get-user-purchases/'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load User Purchases');
    }
  }

  Future<List<dynamic>> getUserAttendance(int userId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/get-user-attendance/$userId/'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<List<dynamic>> getTraineesList(int userId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/get-trainees/$userId/'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<List<dynamic>> getTraineeDietPlans(int userId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/$userId/trainee-diet-plans/'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<List<dynamic>> getTrainerDietPlans(int userId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/$userId/trainer-diet-plans/'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<http.Response> createDietPlan(
      Map<String, dynamic> dietPlanData, int trainerID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('$baseUrl/api/$trainerID/create-diet-plan/'),
      headers: {
        'Content-Type': 'application/json',
        // 'Authorization': 'Bearer $token',
      },
      body: json.encode(dietPlanData),
    );

    return response;
  }

 Future<http.Response> updateDietPlan(int trainerId, int planId, Map<String, dynamic> dietPlanData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/edit-diet-plan/$planId/'),
      body: json.encode(dietPlanData),
      headers: <String,String>{'Content-Type': 'application/json; charset=UTF-8'},
    );
    return response;
  }

  // Fetch a specific diet plan
  Future<Map<String, dynamic>> getDietPlan(int dietPlanID) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/diet-plan/$dietPlanID/'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load diet plan');
    }
  }
Future<http.Response> deleteDietPlanDay(int id) async {
    final url = Uri.parse('$baseUrl/api/delete-diet-plan-day/$id/');
    final response = await http.delete(url);
    return response;
  }

  // Add this method to the ApiService class
Future<http.Response> createWorkoutPlan(Map<String, dynamic> workoutPlanData) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  final response = await http.post(
    Uri.parse('$baseUrl/api/workout-plans/create/'),
    headers: {
      'Content-Type': 'application/json',
      // 'Authorization': 'Bearer $token', // Use token if authentication is required
    },
    body: json.encode(workoutPlanData),
  );

  return response;
}

 Future<List<dynamic>> getWorkoutPlans(int id) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/$id/workout-plans/list/'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to Load Workout Plans');
    }
  }

   Future<List<dynamic>> getTraineeWorkoutPlans(int id) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/$id/trainee-workout-plans/list/'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to Load Workout Plans');
    }
  }

Future<Map<String, dynamic>> getWorkoutPlanDetails(int id) async{
    final response =
        await http.get(Uri.parse('$baseUrl/api/workout-plan/$id'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to Load Workout Plan Details');
    }
  }
Future<http.Response> updateWorkoutPlan(
      int trainerId, int planId, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/workout-plans/$planId/update/');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    return response;
  }

  Future<http.Response> deleteWorkoutPlanDay(int dayId) async {
    final url = Uri.parse('$baseUrl/workoutplandays/$dayId/');
    final response = await http.delete(url);
    return response;
  }

  Future<List<PersonalGoal>> getPersonalGoals(int userId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/personal-goals/$userId/'));
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((json) => PersonalGoal.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load personal goals');
    }
  }

  Future<PersonalGoal> addPersonalGoal(PersonalGoal goal) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/personal-goals/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(goal.toJson()),
    );

    if (response.statusCode == 201) {
      return PersonalGoal.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add personal goal');
    }
  }

  Future<List<WeeklyProgress>> getWeeklyProgress(int goalId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/weekly-progress/$goalId/'));
    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((json) => WeeklyProgress.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load weekly progress');
    }
  }

  Future<WeeklyProgress> addWeeklyProgress(WeeklyProgress progress) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/weekly-progress/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(progress.toJson()),
    );

    if (response.statusCode == 201) {
      return WeeklyProgress.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add weekly progress');
    }
  }
}