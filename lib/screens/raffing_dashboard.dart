// File: lib/screens/raffing_dashboard.dart
import 'package:flutter/material.dart';

class RaffingDashboard extends StatefulWidget {
  @override
  _RaffingDashboardState createState() => _RaffingDashboardState();
}

class _RaffingDashboardState extends State<RaffingDashboard> {
  final _componentNameController = TextEditingController();
  final _assignedWorkerController = TextEditingController();
  final _unitsProcessedController = TextEditingController();
  final _productivityController = TextEditingController();
  final _remarksController = TextEditingController();

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
            Navigator.pop(context);
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
                'Raffing Process\nDashboard',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 30),
              
              // Unit-1 Operations Section
              Text(
                'Unit-1 Operations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),
              
              // Form Fields
              _buildInputField('Component Name', _componentNameController),
              SizedBox(height: 15),
              _buildInputField('Assigned Worker/Team', _assignedWorkerController),
              SizedBox(height: 15),
              _buildInputField('No. of Units Processed', _unitsProcessedController),
              SizedBox(height: 15),
              _buildInputField('Productivity Value', _productivityController),
              SizedBox(height: 15),
              _buildInputField('Remarks/Notes', _remarksController, maxLines: 3),
              SizedBox(height: 30),
              
              // Daily vs Target Productivity Summary
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily vs Target Productivity\nSummary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 5),
                        Text(
                          '4.95',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Excellent Tracking',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    _submitRaffingData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Submit Entry',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  void _submitRaffingData() {
    // Handle raffing data submission
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Raffing data submitted successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Clear form fields
    _componentNameController.clear();
    _assignedWorkerController.clear();
    _unitsProcessedController.clear();
    _productivityController.clear();
    _remarksController.clear();
  }

  @override
  void dispose() {
    _componentNameController.dispose();
    _assignedWorkerController.dispose();
    _unitsProcessedController.dispose();
    _productivityController.dispose();
    _remarksController.dispose();
    super.dispose();
  }
}