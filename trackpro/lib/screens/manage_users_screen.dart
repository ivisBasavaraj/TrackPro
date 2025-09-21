// File: lib/screens/manage_users_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ManageUsersScreen extends StatefulWidget {
  @override
  _ManageUsersScreenState createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Sample user data - in real app, this would come from a database
  List<User> users = [
    User(
      id: '001',
      name: 'John Smith',
      username: 'john.smith',
      role: 'Supervisor',
      isActive: true,
      todayTasks: [
        Task('Incoming Inspection', 'Batch #IN-2024-098', 'Completed', Colors.green),
        Task('Quality Control', 'Part ID: QC-2024-045', 'In Progress', Colors.orange),
      ],
      completedToday: 8,
      totalAssigned: 12,
    ),
    User(
      id: '002',
      name: 'Sarah Johnson',
      username: 'sarah.johnson',
      role: 'User',
      isActive: true,
      todayTasks: [
        Task('Finishing Operations', 'AMS-141 COLUMN', 'In Progress', Colors.blue),
        Task('Delivery Management', 'Order #DEL-445', 'Completed', Colors.green),
        Task('Incoming Inspection', 'Component Check', 'Pending', Colors.grey),
      ],
      completedToday: 6,
      totalAssigned: 9,
    ),
    User(
      id: '003',
      name: 'Mike Wilson',
      username: 'mike.wilson',
      role: 'User',
      isActive: false,
      todayTasks: [
        Task('Quality Control', 'Final Inspection', 'Paused', Colors.red),
      ],
      completedToday: 3,
      totalAssigned: 8,
    ),
    User(
      id: '004',
      name: 'Emily Davis',
      username: 'emily.davis',
      role: 'Supervisor',
      isActive: true,
      todayTasks: [
        Task('Delivery Management', 'Route Planning', 'Completed', Colors.green),
        Task('Quality Control', 'Tolerance Check', 'Completed', Colors.green),
        Task('Incoming Inspection', 'Supplier Audit', 'In Progress', Colors.orange),
      ],
      completedToday: 11,
      totalAssigned: 14,
    ),
  ];

  // Add user form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = 'User';
  final List<String> _roles = ['Admin', 'Supervisor', 'User'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Manage Users',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Colors.black,
          tabs: [
            Tab(
              icon: Icon(Icons.people),
              text: 'User List',
            ),
            Tab(
              icon: Icon(Icons.person_add),
              text: 'Add User',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUserListTab(),
          _buildAddUserTab(),
        ],
      ),
    );
  }

  Widget _buildUserListTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          _buildSummarySection(),
          SizedBox(height: 25),
          
          // Users List
          Text(
            'Team Members',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 15),
          
          ...users.map((user) => _buildUserCard(user)).toList(),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    int activeUsers = users.where((u) => u.isActive).length;
    int totalUsers = users.length;
    int totalTasksCompleted = users.fold(0, (sum, user) => sum + user.completedToday);
    int totalTasksAssigned = users.fold(0, (sum, user) => sum + user.totalAssigned);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Team Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Active Users',
                '$activeUsers/$totalUsers',
                Icons.people,
                Colors.green,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Tasks Today',
                '$totalTasksCompleted/$totalTasksAssigned',
                Icons.assignment,
                Colors.blue,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Supervisors',
                '${users.where((u) => u.role == 'Supervisor').length}',
                Icons.supervisor_account,
                Colors.purple,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Efficiency',
                '${((totalTasksCompleted / totalTasksAssigned) * 100).toInt()}%',
                Icons.trending_up,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(User user) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // User Header
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: user.isActive ? Colors.green[100] : Colors.grey[300],
                child: Text(
                  user.name.split(' ').map((n) => n[0]).join(''),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: user.isActive ? Colors.green[700] : Colors.grey[600],
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: user.isActive ? Colors.green[100] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 10,
                              color: user.isActive ? Colors.green[700] : Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2),
                    Text(
                      '@${user.username}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Role Dropdown
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: user.role,
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                    onChanged: (String? newRole) {
                      setState(() {
                        user.role = newRole!;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${user.name}\'s role updated to $newRole'),
                          backgroundColor: Colors.blue,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    items: _roles.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          // Progress Bar
          Row(
            children: [
              Text(
                'Today\'s Progress: ${user.completedToday}/${user.totalAssigned}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              Text(
                '${((user.completedToday / user.totalAssigned) * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: user.completedToday / user.totalAssigned,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              user.completedToday / user.totalAssigned > 0.8 
                  ? Colors.green 
                  : user.completedToday / user.totalAssigned > 0.5 
                      ? Colors.orange 
                      : Colors.red,
            ),
          ),
          
          SizedBox(height: 16),
          
          // Today's Tasks
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today\'s Tasks',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              ...user.todayTasks.map((task) => _buildTaskItem(task)).toList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(Task task) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: task.statusColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '${task.type}: ${task.description}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: task.statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              task.status,
              style: TextStyle(
                fontSize: 10,
                color: task.statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddUserTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add New Team Member',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Fill in the details below to add a new user to your team',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 30),

          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildInputField('Full Name', _nameController, 'Enter full name'),
                SizedBox(height: 20),
                _buildInputField('Username', _usernameController, 'Enter username'),
                SizedBox(height: 20),
                _buildInputField('Password', _passwordController, 'Enter password', isPassword: true),
                SizedBox(height: 20),
                
                // Role Selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Role',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedRole,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedRole = newValue!;
                            });
                          },
                          items: _roles.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 30),
                
                // Add Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _addUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Add Team Member',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String hint, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.black),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  void _addUser() async {
    if (_nameController.text.isNotEmpty && 
        _usernameController.text.isNotEmpty && 
        _passwordController.text.isNotEmpty) {
      
      final result = await ApiService.registerUser(
        _nameController.text,
        _usernameController.text,
        _passwordController.text,
        _selectedRole,
      );
      
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_nameController.text} added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Clear form
        _nameController.clear();
        _usernameController.clear();
        _passwordController.clear();
        setState(() {
          _selectedRole = 'User';
        });
        
        // Refresh user list
        _loadUsers();
        _tabController.animateTo(0);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _loadUsers() async {
    try {
      final userList = await ApiService.getUsers();
      setState(() {
        users = userList.map((userData) => User(
          id: userData['_id'],
          name: userData['name'],
          username: userData['username'],
          role: userData['role'],
          isActive: userData['isActive'],
          todayTasks: [],
          completedToday: userData['completedToday'] ?? 0,
          totalAssigned: userData['totalAssigned'] ?? 0,
        )).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load users: $e')),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// Data Models
class User {
  final String id;
  String name;
  String username;
  String role;
  bool isActive;
  List<Task> todayTasks;
  int completedToday;
  int totalAssigned;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.role,
    required this.isActive,
    required this.todayTasks,
    required this.completedToday,
    required this.totalAssigned,
  });
}

class Task {
  final String type;
  final String description;
  final String status;
  final Color statusColor;

  Task(this.type, this.description, this.status, this.statusColor);
}