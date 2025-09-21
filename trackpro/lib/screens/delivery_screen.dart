// File: lib/screens/delivery_screen.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class DeliveryScreen extends StatefulWidget {
  @override
  _DeliveryScreenState createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerIdController = TextEditingController();
  final _deliveryAddressController = TextEditingController();
  final _vehicleDetailsController = TextEditingController();
  final _driverNameController = TextEditingController();
  final _driverContactController = TextEditingController();
  final _partIdController = TextEditingController();
  final _remarksController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  File? _deliveryProofImage;
  final ImagePicker _picker = ImagePicker();
  String _deliveryStatus = 'Pending';

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _pickDeliveryProof() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _deliveryProofImage = File(image.path);
      });
    }
  }

  void _submitDelivery() async {
    if (_formKey.currentState!.validate()) {
      final deliveryData = {
        'customerName': _customerNameController.text,
        'customerId': _customerIdController.text,
        'deliveryAddress': _deliveryAddressController.text,
        'partId': _partIdController.text,
        'vehicleDetails': _vehicleDetailsController.text,
        'driverName': _driverNameController.text,
        'driverContact': _driverContactController.text,
        'scheduledDate': _selectedDate.toIso8601String(),
        'scheduledTime': _selectedTime.format(context),
        'deliveryStatus': _deliveryStatus,
        'remarks': _remarksController.text,
      };
      
      final result = await ApiService.createDelivery(deliveryData, proofImage: _deliveryProofImage);
      
      if (result['success']) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delivery Record Saved'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Customer: ${_customerNameController.text}'),
                Text('Part ID: ${_partIdController.text}'),
                Text('Delivery Status: $_deliveryStatus'),
                Text('Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                Text('Time: ${_selectedTime.format(context)}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save delivery record: ${result['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Delivery Management',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer Information
                Text(
                  'Customer Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _customerNameController,
                  decoration: InputDecoration(
                    labelText: 'Customer Name *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter customer name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _customerIdController,
                  decoration: InputDecoration(
                    labelText: 'Customer ID',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge),
                  ),
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _deliveryAddressController,
                  decoration: InputDecoration(
                    labelText: 'Delivery Address *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter delivery address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 25),

                // Part Information
                Text(
                  'Part Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _partIdController,
                  decoration: InputDecoration(
                    labelText: 'Part ID *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.qr_code),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Part ID';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 25),

                // Vehicle/Transport Details
                Text(
                  'Transport Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _vehicleDetailsController,
                  decoration: InputDecoration(
                    labelText: 'Vehicle Details *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.local_shipping),
                    hintText: 'e.g., Truck - TN01AB1234',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter vehicle details';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _driverNameController,
                        decoration: InputDecoration(
                          labelText: 'Driver Name *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _driverContactController,
                        decoration: InputDecoration(
                          labelText: 'Driver Contact *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25),

                // Date & Time of Dispatch
                Text(
                  'Dispatch Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, color: Colors.grey[600]),
                              SizedBox(width: 8),
                              Text(
                                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectTime(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.access_time, color: Colors.grey[600]),
                              SizedBox(width: 8),
                              Text(
                                _selectedTime.format(context),
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25),

                // Delivery Status
                Text(
                  'Delivery Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 15),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _deliveryStatus,
                      isExpanded: true,
                      icon: Icon(Icons.arrow_drop_down),
                      items: ['Pending', 'Dispatched', 'In Transit', 'Delivered', 'Failed']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _deliveryStatus = newValue!;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 25),

                // Delivery Proof
                Text(
                  'Delivery Proof',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 15),
                GestureDetector(
                  onTap: _pickDeliveryProof,
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[50],
                    ),
                    child: _deliveryProofImage != null
                        ? Image.file(_deliveryProofImage!, fit: BoxFit.contain)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, size: 40, color: Colors.grey[600]),
                              SizedBox(height: 8),
                              Text(
                                'Tap to capture delivery proof',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              Text(
                                '(Photo of delivered item/receipt)',
                                style: TextStyle(color: Colors.grey[500], fontSize: 12),
                              ),
                            ],
                          ),
                  ),
                ),
                SizedBox(height: 25),

                // Remarks
                TextFormField(
                  controller: _remarksController,
                  decoration: InputDecoration(
                    labelText: 'Delivery Notes/Remarks',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                    hintText: 'Additional information about delivery...',
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 30),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitDelivery,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Submit Delivery Record',
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
        ),
      ),
    );
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerIdController.dispose();
    _deliveryAddressController.dispose();
    _vehicleDetailsController.dispose();
    _driverNameController.dispose();
    _driverContactController.dispose();
    _partIdController.dispose();
    _remarksController.dispose();
    super.dispose();
  }
}