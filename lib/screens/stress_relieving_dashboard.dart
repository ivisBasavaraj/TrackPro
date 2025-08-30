// File: lib/screens/stress_relieving_dashboard.dart
import 'package:flutter/material.dart';

class StressRelievingDashboard extends StatefulWidget {
  @override
  _StressRelievingDashboardState createState() => _StressRelievingDashboardState();
}

class _StressRelievingDashboardState extends State<StressRelievingDashboard> {
  final _componentNameController = TextEditingController();
  final _vendorNameController = TextEditingController();
  final _productivityValueController = TextEditingController();
  String _selectedStatus = 'Select';

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
                'Stress Relieving\nDashboard',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 30),
              
              // Outsource Coordination Section
              Text(
                'Outsource Coordination',
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
              
              _buildInputField('Vendor Name', _vendorNameController),
              SizedBox(height: 15),
              
              _buildInputField('Productivity Value', _productivityValueController),
              SizedBox(height: 15),
              
              // Dropdown for Status
              Text(
                'Status',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedStatus,
                    isExpanded: true,
                    items: ['Select', 'In Progress', 'Completed', 'Pending']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedStatus = newValue!;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 30),
              
              // Upload Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    // Handle file upload
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('File upload feature coming soon!'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[400]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Upload',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              
              // Approved vs Pending Units
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
                      'Approved vs Pending Units',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
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
                          '75 ratings',
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
              
              // History Section
              Text(
                'History of Outsourcing Activities',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 15),
              
              _buildHistoryItem('Activity 1 - Completed'),
              SizedBox(height: 10),
              _buildHistoryItem('Activity 2 - In Progress'),
              SizedBox(height: 10),
              _buildHistoryItem('Activity 3 - Pending'),
              SizedBox(height: 30),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    _submitStressRelievingData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Submit',
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

  Widget _buildInputField(String label, TextEditingController controller) {
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

  Widget _buildHistoryItem(String activity) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: Colors.grey[600]),
          SizedBox(width: 10),
          Text(
            activity,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  void _submitStressRelievingData() {
    // Handle stress relieving data submission
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Stress relieving data submitted successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Clear form fields
    _componentNameController.clear();
    _vendorNameController.clear();
    _productivityValueController.clear();
    setState(() {
      _selectedStatus = 'Select';
    });
  }

  @override
  void dispose() {
    _componentNameController.dispose();
    _vendorNameController.dispose();
    _productivityValueController.dispose();
    super.dispose();
  }
}