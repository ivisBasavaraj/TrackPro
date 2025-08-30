// File: lib/screens/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'add_user_screen.dart';
import 'login_screen.dart';
import 'casting_dashboard.dart';
import 'raffing_dashboard.dart';
import 'stress_relieving_dashboard.dart';
import 'finishing_dashboard.dart';

class AdminDashboard extends StatelessWidget {
  final String adminName;

  AdminDashboard({required this.adminName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.download, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Admin Dashboard',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Admin Name',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                adminName,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 30),
              
              // Stats Grid - Now clickable
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      Icons.engineering,
                      'Casting',
                      Colors.grey[100]!,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CastingDashboard()),
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      Icons.auto_fix_high,
                      'Raffing',
                      Colors.grey[100]!,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RaffingDashboard()),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      Icons.psychology,
                      'Stress Relieving',
                      Colors.grey[100]!,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => StressRelievingDashboard()),
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      Icons.check_circle,
                      'Finishing',
                      Colors.grey[100]!,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FinishingDashboard()),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              
              // Process Overview
              Text(
                'Process Overview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 15),
              
              Text(
                'Total Units Processed: 1500 ↗',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 30),
              
              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddUserScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Icon(Icons.people, color: Colors.white),
                  label: Text(
                    'Manage Users',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Handle settings
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[400]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Icon(Icons.settings, color: Colors.black),
                  label: Text(
                    'Settings',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, IconData icon, String label, Color backgroundColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 32,
              color: Colors.black87,
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}