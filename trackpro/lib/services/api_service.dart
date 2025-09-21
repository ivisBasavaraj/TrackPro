import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  
  // Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  
  // Store token
  static Future<void> storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
  
  // Remove token
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
  
  // Get headers with auth token
  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  // Login
  static Future<Map<String, dynamic>> login(String username, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'role': role,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        await storeToken(data['token']);
        return {'success': true, 'user': data['user']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  // Register user (Admin only)
  static Future<Map<String, dynamic>> registerUser(String name, String username, String password, String role) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: headers,
        body: jsonEncode({
          'name': name,
          'username': username,
          'password': password,
          'role': role,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        return {'success': true, 'user': data['user']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Registration failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  // Get all users
  static Future<List<dynamic>> getUsers() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // Assign task to user
  static Future<Map<String, dynamic>> assignTask(String userId, String task) async {
    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId/assign-task'),
        headers: headers,
        body: jsonEncode({'assignedTask': task}),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'user': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Task assignment failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  // Unassign task from user
  static Future<Map<String, dynamic>> unassignTask(String userId) async {
    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId/unassign-task'),
        headers: headers,
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'user': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Task unassignment failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  // Create inspection
  static Future<Map<String, dynamic>> createInspection(Map<String, dynamic> inspectionData, {File? image}) async {
    try {
      final token = await getToken();
      final uri = Uri.parse('$baseUrl/inspections');
      
      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      
      // Add form fields
      inspectionData.forEach((key, value) {
        request.fields[key] = value.toString();
      });
      
      // Add image if provided
      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath('image', image.path));
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        return {'success': true, 'inspection': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Inspection creation failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  // Create finishing record
  static Future<Map<String, dynamic>> createFinishing(Map<String, dynamic> finishingData) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/finishing'),
        headers: headers,
        body: jsonEncode(finishingData),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        return {'success': true, 'finishing': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Finishing record creation failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  // Create quality control record
  static Future<Map<String, dynamic>> createQualityControl(Map<String, dynamic> qcData, {File? signature}) async {
    try {
      final token = await getToken();
      final uri = Uri.parse('$baseUrl/quality');
      
      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      
      // Add form fields
      qcData.forEach((key, value) {
        if (value is Map) {
          // Handle nested objects like holeDimensions and levelReadings
          value.forEach((nestedKey, nestedValue) {
            request.fields['$key.$nestedKey'] = nestedValue.toString();
          });
        } else {
          request.fields[key] = value.toString();
        }
      });
      
      // Add signature if provided
      if (signature != null) {
        request.files.add(await http.MultipartFile.fromPath('signatureImage', signature.path));
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        return {'success': true, 'qualityControl': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'QC record creation failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  // Create delivery record
  static Future<Map<String, dynamic>> createDelivery(Map<String, dynamic> deliveryData, {File? proofImage}) async {
    try {
      final token = await getToken();
      final uri = Uri.parse('$baseUrl/delivery');
      
      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      
      // Add form fields
      deliveryData.forEach((key, value) {
        request.fields[key] = value.toString();
      });
      
      // Add proof image if provided
      if (proofImage != null) {
        request.files.add(await http.MultipartFile.fromPath('deliveryProofImage', proofImage.path));
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        return {'success': true, 'delivery': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Delivery record creation failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  // Get dashboard data
  static Future<Map<String, dynamic>> getDashboardData(String role) async {
    try {
      final headers = await getHeaders();
      String endpoint;
      
      switch (role.toLowerCase()) {
        case 'admin':
          endpoint = 'dashboard/admin';
          break;
        case 'supervisor':
          endpoint = 'dashboard/supervisor';
          break;
        default:
          endpoint = 'dashboard/user';
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load dashboard data');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // Get reports
  static Future<Map<String, dynamic>> getReport(String type, {String? startDate, String? endDate}) async {
    try {
      final headers = await getHeaders();
      String url = '$baseUrl/dashboard/reports/$type';
      
      if (startDate != null && endDate != null) {
        url += '?startDate=$startDate&endDate=$endDate';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load report');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // Upload Excel tool list
  static Future<Map<String, dynamic>> uploadToolList(String toolName, File excelFile) async {
    try {
      final token = await getToken();
      final uri = Uri.parse('$baseUrl/tools/upload');
      
      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      
      request.fields['toolName'] = toolName;
      request.files.add(await http.MultipartFile.fromPath('excel', excelFile.path));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        return {'success': true, 'toolList': data['toolList']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Upload failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  // Get tool lists
  static Future<List<dynamic>> getToolLists() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/tools'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load tool lists');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // Get tool list by name
  static Future<Map<String, dynamic>> getToolListByName(String toolName) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/tools/$toolName'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Tool list not found');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}