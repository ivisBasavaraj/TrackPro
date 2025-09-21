// File: lib/screens/quality_control_screen.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class QualityControlScreen extends StatefulWidget {
  @override
  _QualityControlScreenState createState() => _QualityControlScreenState();
}

class _QualityControlScreenState extends State<QualityControlScreen> {
  final _formKey = GlobalKey<FormState>();
  final _partIdController = TextEditingController();
  final _holeDimension1Controller = TextEditingController();
  final _holeDimension2Controller = TextEditingController();
  final _holeDimension3Controller = TextEditingController();
  final _levelReading1Controller = TextEditingController();
  final _levelReading2Controller = TextEditingController();
  final _levelReading3Controller = TextEditingController();
  final _inspectorNameController = TextEditingController();
  final _remarksController = TextEditingController();

  String _qcStatus = 'Pass';
  File? _signatureImage;
  final ImagePicker _picker = ImagePicker();

  // Tolerance limits
  final double _holeTolerance = 0.5;
  final double _levelTolerance = 1.0;

  bool _validateMeasurements() {
    // Auto-validation logic for tolerance
    List<double> holeDimensions = [
      double.tryParse(_holeDimension1Controller.text) ?? 0.0,
      double.tryParse(_holeDimension2Controller.text) ?? 0.0,
      double.tryParse(_holeDimension3Controller.text) ?? 0.0,
    ];
    
    List<double> levelReadings = [
      double.tryParse(_levelReading1Controller.text) ?? 0.0,
      double.tryParse(_levelReading2Controller.text) ?? 0.0,
      double.tryParse(_levelReading3Controller.text) ?? 0.0,
    ];

    // Check if any measurement exceeds tolerance
    for (double hole in holeDimensions) {
      if (hole > _holeTolerance) return false;
    }
    
    for (double level in levelReadings) {
      if (level > _levelTolerance) return false;
    }
    
    return true;
  }

  Future<void> _pickSignatureImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _signatureImage = File(image.path);
      });
    }
  }

  void _submitQualityControl() async {
    if (_formKey.currentState!.validate()) {
      bool isValid = _validateMeasurements();
      setState(() {
        _qcStatus = isValid ? 'Pass' : 'Fail';
      });

      final qcData = {
        'partId': _partIdController.text,
        'holeDimensions': {
          'hole1': double.tryParse(_holeDimension1Controller.text) ?? 0.0,
          'hole2': double.tryParse(_holeDimension2Controller.text) ?? 0.0,
          'hole3': double.tryParse(_holeDimension3Controller.text) ?? 0.0,
        },
        'levelReadings': {
          'level1': double.tryParse(_levelReading1Controller.text) ?? 0.0,
          'level2': double.tryParse(_levelReading2Controller.text) ?? 0.0,
          'level3': double.tryParse(_levelReading3Controller.text) ?? 0.0,
        },
        'inspectorName': _inspectorNameController.text,
        'remarks': _remarksController.text,
      };
      
      final result = await ApiService.createQualityControl(qcData, signature: _signatureImage);
      
      if (result['success']) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('QC Record Saved'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Part ID: ${_partIdController.text}'),
                Text('QC Status: $_qcStatus'),
                Text('Inspector: ${_inspectorNameController.text}'),
                SizedBox(height: 10),
                if (!isValid)
                  Text(
                    'Warning: Measurements exceed tolerance limits!',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
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
            content: Text('Failed to save QC record: ${result['message']}'),
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
          'Quality Control (QC)',
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
                // Part ID
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

                // Hole Dimensions
                Text(
                  'Hole Dimensions (Tolerance: ±${_holeTolerance}mm)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _holeDimension1Controller,
                        decoration: InputDecoration(
                          labelText: 'Hole 1 (mm)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                        controller: _holeDimension2Controller,
                        decoration: InputDecoration(
                          labelText: 'Hole 2 (mm)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                SizedBox(height: 15),
                TextFormField(
                  controller: _holeDimension3Controller,
                  decoration: InputDecoration(
                    labelText: 'Hole 3 (mm)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter hole dimension';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 25),

                // Level Readings
                Text(
                  'Level Readings (Tolerance: ±${_levelTolerance}mm)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _levelReading1Controller,
                        decoration: InputDecoration(
                          labelText: 'Level 1 (mm)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                        controller: _levelReading2Controller,
                        decoration: InputDecoration(
                          labelText: 'Level 2 (mm)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                SizedBox(height: 15),
                TextFormField(
                  controller: _levelReading3Controller,
                  decoration: InputDecoration(
                    labelText: 'Level 3 (mm)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter level reading';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 25),

                // QC Status
                Text(
                  'QC Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 15),
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                    color: _qcStatus == 'Pass' ? Colors.green[50] : Colors.red[50],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _qcStatus == 'Pass' ? Icons.check_circle : Icons.error,
                        color: _qcStatus == 'Pass' ? Colors.green : Colors.red,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Status: $_qcStatus',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _qcStatus == 'Pass' ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 25),

                // Inspector Information
                Text(
                  'Inspector Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _inspectorNameController,
                  decoration: InputDecoration(
                    labelText: 'Inspector Name *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter inspector name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),

                // Signature
                Text(
                  'Inspector Signature',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: _pickSignatureImage,
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[50],
                    ),
                    child: _signatureImage != null
                        ? Image.file(_signatureImage!, fit: BoxFit.contain)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, size: 40, color: Colors.grey[600]),
                              SizedBox(height: 8),
                              Text(
                                'Tap to capture signature',
                                style: TextStyle(color: Colors.grey[600]),
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
                    labelText: 'Remarks (Optional)',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 30),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitQualityControl,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Submit QC Report',
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
    _partIdController.dispose();
    _holeDimension1Controller.dispose();
    _holeDimension2Controller.dispose();
    _holeDimension3Controller.dispose();
    _levelReading1Controller.dispose();
    _levelReading2Controller.dispose();
    _levelReading3Controller.dispose();
    _inspectorNameController.dispose();
    _remarksController.dispose();
    super.dispose();
  }
}