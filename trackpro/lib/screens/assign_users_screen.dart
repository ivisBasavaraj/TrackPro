// File: lib/screens/assign_users_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class User {
  final String id;
  final String name;
  final String email;
  String? assignedTask;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.assignedTask,
  });
}

class AssignUsersScreen extends StatefulWidget {
  @override
  _AssignUsersScreenState createState() => _AssignUsersScreenState();
}

class _AssignUsersScreenState extends State<AssignUsersScreen> {
  // Sample users data
  List<User> users = [
    User(id: '1', name: 'John Smith', email: 'john.smith@company.com'),
    User(id: '2', name: 'Sarah Johnson', email: 'sarah.johnson@company.com', assignedTask: 'Incoming Inspection'),
    User(id: '3', name: 'Mike Davis', email: 'mike.davis@company.com'),
    User(id: '4', name: 'Emily Wilson', email: 'emily.wilson@company.com', assignedTask: 'Quality Control'),
    User(id: '5', name: 'Robert Brown', email: 'robert.brown@company.com'),
    User(id: '6', name: 'Lisa Taylor', email: 'lisa.taylor@company.com', assignedTask: 'Finishing'),
    User(id: '7', name: 'David Miller', email: 'david.miller@company.com'),
    User(id: '8', name: 'Jennifer Garcia', email: 'jennifer.garcia@company.com'),
  ];

  // Available tasks
  final List<String> availableTasks = [
    'Incoming Inspection',
    'Finishing',
    'Quality Control',
    'Delivery'
  ];

  @override
  Widget build(BuildContext context) {
    List<User> assignedUsers = users.where((user) => user.assignedTask != null).toList();
    List<User> unassignedUsers = users.where((user) => user.assignedTask == null).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Assign Users',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Assigned Users Section
            Text(
              'Assigned Users',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 15),
            assignedUsers.isEmpty
                ? Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Center(
                      child: Text(
                        'No users assigned yet',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: assignedUsers.map((user) => _buildAssignedUserCard(user)).toList(),
                  ),
            
            SizedBox(height: 30),
            
            // Unassigned Users Section
            Text(
              'Unassigned Users',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 15),
            unassignedUsers.isEmpty
                ? Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Center(
                      child: Text(
                        'All users are assigned',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: unassignedUsers.map((user) => _buildUnassignedUserCard(user)).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignedUserCard(User user) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[700],
            child: Icon(Icons.person, color: Colors.white),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.assignedTask!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _unassignUser(user),
            icon: Icon(Icons.remove_circle_outline, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildUnassignedUserCard(User user) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[200],
            child: Icon(Icons.person, color: Colors.grey[600]),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showAssignTaskDialog(user),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              'Assign',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showAssignTaskDialog(User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.person_add,
                      color: Colors.grey[700],
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Assign Task',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                
                // User info
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        radius: 20,
                        child: Icon(Icons.person, color: Colors.grey[700]),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              user.email,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 20),
                
                Text(
                  'Select a task to assign:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 16),
                
                // Task options
                ...availableTasks.map((task) => Container(
                  margin: EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      _assignTask(user, task);
                      Navigator.of(context).pop();
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              _getTaskIcon(task),
                              color: Colors.grey[700],
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            task,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey[400],
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                )).toList(),
                
                SizedBox(height: 20),
                
                // Cancel button
                Container(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getTaskIcon(String task) {
    switch (task) {
      case 'Incoming Inspection':
        return Icons.input;
      case 'Finishing':
        return Icons.check_circle;
      case 'Quality Control':
        return Icons.verified;
      case 'Delivery':
        return Icons.local_shipping;
      default:
        return Icons.work;
    }
  }

  void _assignTask(User user, String task) async {
    final result = await ApiService.assignTask(user.id, task);
    if (result['success']) {
      setState(() {
        user.assignedTask = task;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user.name} assigned to $task'),
          backgroundColor: Colors.grey[800],
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to assign task: ${result['message']}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _unassignUser(User user) async {
    final result = await ApiService.unassignTask(user.id);
    if (result['success']) {
      setState(() {
        user.assignedTask = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user.name} unassigned'),
          backgroundColor: Colors.grey[700],
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to unassign: ${result['message']}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}