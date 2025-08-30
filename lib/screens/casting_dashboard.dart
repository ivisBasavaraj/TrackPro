// File: lib/screens/casting_dashboard.dart
import 'package:flutter/material.dart';

class CastingDashboard extends StatefulWidget {
  @override
  _CastingDashboardState createState() => _CastingDashboardState();
}

class _CastingDashboardState extends State<CastingDashboard> {
  final _componentNameController = TextEditingController();
  final _productDescriptionController = TextEditingController();
  final _unitsController = TextEditingController();
  final _vendorNameController = TextEditingController();
  final _productivityController = TextEditingController();

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
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      'Casting Process\nDashboard',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 30),
                    
                    // Casting Details Section
                    Text(
                      'Casting Details',
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
                    _buildInputField('Product Description', _productDescriptionController),
                    SizedBox(height: 15),
                    _buildInputField('No. of Units', _unitsController),
                    SizedBox(height: 15),
                    _buildInputField('Vendor Name', _vendorNameController),
                    SizedBox(height: 15),
                    _buildInputField('Productivity Value (Units/hour/day)', _productivityController),
                    SizedBox(height: 30),
                    
                    // Total Units Display
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
                            'Total Units: 100',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'History Records',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Extra space for better scrolling
                    SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            
            // Fixed Submit Button at bottom
            Container(
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, -1),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    _submitCastingData();
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
            ),
          ],
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

  void _submitCastingData() {
    // Handle casting data submission
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Casting data submitted successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Clear form fields
    _componentNameController.clear();
    _productDescriptionController.clear();
    _unitsController.clear();
    _vendorNameController.clear();
    _productivityController.clear();
  }

  @override
  void dispose() {
    _componentNameController.dispose();
    _productDescriptionController.dispose();
    _unitsController.dispose();
    _vendorNameController.dispose();
    _productivityController.dispose();
    super.dispose();
  }
}