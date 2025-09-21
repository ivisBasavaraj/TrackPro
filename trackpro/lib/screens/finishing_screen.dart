// File: lib/screens/finishing_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';

class FinishingScreen extends StatefulWidget {
  @override
  _FinishingScreenState createState() => _FinishingScreenState();
}

class _FinishingScreenState extends State<FinishingScreen> {
  String? selectedTool;
  String toolStatus = 'Working';
  String partComponentId = '';
  String operatorName = '';
  String remarks = '';
  
  List<Map<String, dynamic>> customToolData = [];
  bool showUploadSection = false;
  
  // Timer variables
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  String _elapsedTime = '00:00:00';
  bool _isRunning = false;

  final List<String> tools = [
    'AMS-141 COLUMN',
    'AMS-915 COLUMN',
    'AMS-103 COLUMN',
    'AMS-477 BASE',
  ];

  final List<String> statusOptions = ['Working', 'Faulty'];

  // AMS-141 COLUMN tool data
  List<Map<String, dynamic>> ams141Tools = [
    {'slNo': 1, 'qty': 1, 'toolName': '125 ROUGHING FACEMILL', 'toolDer': 'SLAB3 150SFL', 'toolNo': '5', 'magazine': '', 'pocket': ''},
    {'slNo': 2, 'qty': 1, 'toolName': '20 ROUGHING SHORT ENDMILL', 'toolDer': 'FABEZ 150EM', 'toolNo': '6', 'magazine': '', 'pocket': ''},
    {'slNo': 3, 'qty': 1, 'toolName': '12 FINISHING ENDMILL', 'toolDer': 'FABEZ 150EM', 'toolNo': '5', 'magazine': '63', 'pocket': '35'},
    {'slNo': 4, 'qty': 1, 'toolName': '6 CHAMFER DRILL', 'toolDer': 'FABEZ 160EM', 'toolNo': '1', 'magazine': '44', 'pocket': ''},
    {'slNo': 5, 'qty': 1, 'toolName': '8.5 CARBIDE DRILL', 'toolDer': 'FABZ 205SFL', 'toolNo': '5', 'magazine': '73', 'pocket': '37'},
    {'slNo': 6, 'qty': 1, 'toolName': '10.5 CARBIDE DRILL', 'toolDer': 'FABZ 160EM', 'toolNo': '3', 'magazine': '44', 'pocket': '35'},
    {'slNo': 7, 'qty': 1, 'toolName': '14 CARBIDE DRILL', 'toolDer': 'FABZ 150EM', 'toolNo': '5', 'magazine': '26', 'pocket': '40'},
    {'slNo': 8, 'qty': 1, 'toolName': '19 ROUGHING ENDMILL', 'toolDer': 'FABZ 160EM', 'toolNo': '6', 'magazine': '', 'pocket': ''},
    {'slNo': 9, 'qty': 10, 'toolName': '5.5 CARBIDE DRILL', 'toolDer': 'FENZ 150SFL', 'toolNo': '5', 'magazine': '2', 'pocket': '15'},
    {'slNo': 10, 'qty': 11, 'toolName': '6.5 CARBIDE DRILL', 'toolDer': 'FENZ 150EM', 'toolNo': '6', 'magazine': '2', 'pocket': '39'},
    {'slNo': 11, 'qty': 12, 'toolName': '13.5 CARBIDE DRILL', 'toolDer': 'FENZ 160EM', 'toolNo': '5', 'magazine': '2', 'pocket': '30'},
    {'slNo': 12, 'qty': 14, 'toolName': '', 'toolDer': 'FENZ 150EM', 'toolNo': '5', 'magazine': '', 'pocket': ''},
    {'slNo': 13, 'qty': 15, 'toolName': '54 ENDMILL', 'toolDer': 'FENZ 160EM', 'toolNo': '5', 'magazine': '', 'pocket': ''},
    {'slNo': 14, 'qty': 16, 'toolName': '16.5 CARBIDE DRILL', 'toolDer': 'FENZ 150EM', 'toolNo': '3', 'magazine': '2', 'pocket': '30'},
    {'slNo': 15, 'qty': 17, 'toolName': '125 FINISHING FACEMILL', 'toolDer': 'SLAB3 150SFL', 'toolNo': '5', 'magazine': '', 'pocket': ''},
    {'slNo': 16, 'qty': 18, 'toolName': '', 'toolDer': 'FENZ 150EM', 'toolNo': '5', 'magazine': '2', 'pocket': '10'},
    {'slNo': 17, 'qty': 19, 'toolName': 'SPOT REAMER', 'toolDer': 'FENZ 150EM', 'toolNo': '6', 'magazine': '4', 'pocket': '28'},
    {'slNo': 18, 'qty': 21, 'toolName': 'M8 ST TAP', 'toolDer': 'FENZ 150EM', 'toolNo': '3', 'magazine': '40', 'pocket': '18'},
    {'slNo': 19, 'qty': 22, 'toolName': 'M8 ST TAP', 'toolDer': 'FENZ 160EM', 'toolNo': '6', 'magazine': '73', 'pocket': '29'},
    {'slNo': 20, 'qty': 23, 'toolName': 'M8 ST TAP', 'toolDer': 'SLAN2 150EM', 'toolNo': '2', 'magazine': '46', 'pocket': '30'},
    {'slNo': 21, 'qty': 24, 'toolName': 'M12 ST TAP', 'toolDer': 'FENZ 150EM', 'toolNo': '5', 'magazine': '29', 'pocket': '39'},
    {'slNo': 22, 'qty': 25, 'toolName': 'M12 ST TAP', 'toolDer': 'SLAN2 150SFL', 'toolNo': '1', 'magazine': '1', 'pocket': '43'},
    {'slNo': 23, 'qty': 26, 'toolName': '8.5 CARBIDE DRILL', 'toolDer': 'SLAN2 150SFL', 'toolNo': '3', 'magazine': '14', 'pocket': '30'},
    {'slNo': 24, 'qty': 27, 'toolName': '20.8 REAMER', 'toolDer': 'SLAN2 150EM', 'toolNo': '3', 'magazine': '', 'pocket': ''},
    {'slNo': 25, 'qty': 28, 'toolName': 'M12 ST TAP', 'toolDer': 'FENZ 150EM', 'toolNo': '5', 'magazine': '14', 'pocket': '29'},
    {'slNo': 26, 'qty': 30, 'toolName': '', 'toolDer': 'FENZ 150EM', 'toolNo': '1', 'magazine': '3', 'pocket': '25'},
    {'slNo': 27, 'qty': 30, 'toolName': '49 DEGREE CHAMFER TOOL', 'toolDer': 'FENZ 150EM', 'toolNo': '5', 'magazine': '', 'pocket': ''},
    {'slNo': 28, 'qty': 31, 'toolName': '', 'toolDer': 'FENZ 150EM', 'toolNo': '3', 'magazine': '', 'pocket': ''},
    {'slNo': 29, 'qty': 33, 'toolName': 'M3 FORMING SPOTFACEDRILL', 'toolDer': 'FABEZ 150SFL', 'toolNo': '3', 'magazine': '', 'pocket': ''},
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
    _loadToolData();
  }
  
  void _loadToolData() async {
    if (selectedTool != null) {
      try {
        final toolData = await ApiService.getToolListByName(selectedTool!);
        setState(() {
          customToolData = List<Map<String, dynamic>>.from(toolData['toolData'] ?? []);
        });
      } catch (e) {
        print('No custom tool data found for $selectedTool');
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (_stopwatch.isRunning) {
        setState(() {
          _elapsedTime = _formatTime(_stopwatch.elapsed);
        });
      }
    });
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  void _startStopwatch() {
    setState(() {
      _stopwatch.start();
      _isRunning = true;
    });
  }

  void _pauseStopwatch() {
    setState(() {
      _stopwatch.stop();
      _isRunning = false;
    });
  }

  void _stopStopwatch() {
    setState(() {
      _stopwatch.stop();
      _stopwatch.reset();
      _isRunning = false;
      _elapsedTime = '00:00:00';
    });
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
          'Finishing',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Colors.black),
            onPressed: _saveFinishingData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timer Section
            _buildTimerSection(),
            SizedBox(height: 30),

            // Tools Monitoring Section
            _buildSectionTitle('Tools Monitoring'),
            SizedBox(height: 15),
            
            // Tool Selection Dropdown
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    'Tool Used *',
                    selectedTool,
                    tools,
                    (value) {
                      setState(() {
                        selectedTool = value;
                        _loadToolData();
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => setState(() => showUploadSection = !showUploadSection),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: Text('Upload Excel', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
            
            if (showUploadSection) ...[
              SizedBox(height: 15),
              _buildExcelUploadSection(),
            ],
            SizedBox(height: 15),

            // Tool Status
            _buildDropdown(
              'Status',
              toolStatus,
              statusOptions,
              (value) => setState(() => toolStatus = value!),
            ),
            SizedBox(height: 30),

            // Data Entry Fields Section
            _buildSectionTitle('Data Entry Fields'),
            SizedBox(height: 15),

            _buildTextField(
              'Part/Component ID *',
              (value) => partComponentId = value,
            ),
            SizedBox(height: 15),

            _buildTextField(
              'Operator Name *',
              (value) => operatorName = value,
            ),
            SizedBox(height: 15),

            _buildTextField(
              'Remarks/Comments',
              (value) => remarks = value,
              maxLines: 3,
            ),
            SizedBox(height: 30),

            // Tool Details Section (conditional)
            if (selectedTool != null) ...[
              _buildSectionTitle('Tool Details'),
              SizedBox(height: 15),
              _buildToolDetails(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimerSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Process Timer',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 15),
          Center(
            child: Text(
              _elapsedTime,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'monospace',
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimerButton(
                'Start',
                Icons.play_arrow,
                Colors.green,
                _isRunning ? null : _startStopwatch,
              ),
              _buildTimerButton(
                'Pause',
                Icons.pause,
                Colors.orange,
                _isRunning ? _pauseStopwatch : null,
              ),
              _buildTimerButton(
                'Stop',
                Icons.stop,
                Colors.red,
                _stopStopwatch,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimerButton(String label, IconData icon, Color color, VoidCallback? onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: onPressed != null ? color : Colors.grey[300],
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label, style: TextStyle(fontSize: 14)),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
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
        SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
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
              borderSide: BorderSide(color: Colors.black, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            fillColor: Colors.white,
            filled: true,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    Function(String) onChanged, {
    int maxLines = 1,
  }) {
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
        SizedBox(height: 5),
        TextField(
          maxLines: maxLines,
          onChanged: onChanged,
          decoration: InputDecoration(
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
              borderSide: BorderSide(color: Colors.black, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            fillColor: Colors.white,
            filled: true,
          ),
        ),
      ],
    );
  }

  Widget _buildToolDetails() {
    if (customToolData.isNotEmpty) {
      return _buildCustomToolTable();
    } else if (selectedTool == 'AMS-141 COLUMN') {
      return _buildAms141Table();
    } else {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: Center(
          child: Text(
            'No tool data available. Upload Excel file to add custom tool data.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  Widget _buildAms141Table() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Expanded(child: Text('SL NO', style: _headerStyle())),
                Expanded(child: Text('QTY', style: _headerStyle())),
                Expanded(flex: 3, child: Text('TOOL NAME', style: _headerStyle())),
                Expanded(flex: 2, child: Text('TOOL DER NAME', style: _headerStyle())),
                Expanded(child: Text('TOOL NO', style: _headerStyle())),
                Expanded(child: Text('MAGAZINE', style: _headerStyle())),
                Expanded(child: Text('POCKET', style: _headerStyle())),
              ],
            ),
          ),
          // Table Rows
          ...ams141Tools.map((tool) => _buildTableRow(tool)).toList(),
        ],
      ),
    );
  }

  TextStyle _headerStyle() {
    return TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );
  }

  Widget _buildTableRow(Map<String, dynamic> tool) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: Text('${tool['slNo']}', style: _cellStyle())),
          Expanded(child: Text('${tool['qty']}', style: _cellStyle())),
          Expanded(flex: 3, child: Text('${tool['toolName']}', style: _cellStyle())),
          Expanded(flex: 2, child: Text('${tool['toolDer']}', style: _cellStyle())),
          Expanded(child: Text('${tool['toolNo']}', style: _cellStyle())),
          Expanded(child: Text('${tool['magazine']}', style: _cellStyle())),
          Expanded(child: Text('${tool['pocket']}', style: _cellStyle())),
        ],
      ),
    );
  }

  TextStyle _cellStyle() {
    return TextStyle(
      fontSize: 9,
      color: Colors.black87,
    );
  }

  void _saveFinishingData() async {
    if (selectedTool == null || selectedTool!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a tool'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (partComponentId.isEmpty || operatorName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final finishingData = {
      'toolUsed': selectedTool!,
      'toolStatus': toolStatus,
      'partComponentId': partComponentId,
      'operatorName': operatorName,
      'remarks': remarks,
      'duration': _formatTime(_stopwatch.elapsed),
      'isCompleted': !_isRunning,
    };
    
    final result = await ApiService.createFinishing(finishingData);
    
    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Finishing data saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save: ${result['message']}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildExcelUploadSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload Tool List Excel',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Upload an Excel file with columns: SL NO, QTY, TOOL NAME, TOOL DER NAME, TOOL NO, MAGAZINE, POCKET',
            style: TextStyle(fontSize: 12, color: Colors.blue[700]),
          ),
          SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _uploadExcelFile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            icon: Icon(Icons.upload_file, color: Colors.white, size: 16),
            label: Text('Select Excel File', style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }
  
  void _uploadExcelFile() async {
    if (selectedTool == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a tool first'), backgroundColor: Colors.red),
      );
      return;
    }
    
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );
    
    if (result != null) {
      File file = File(result.files.single.path!);
      
      final uploadResult = await ApiService.uploadToolList(selectedTool!, file);
      
      if (uploadResult['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Excel file uploaded successfully!'), backgroundColor: Colors.green),
        );
        _loadToolData();
        setState(() => showUploadSection = false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${uploadResult['message']}'), backgroundColor: Colors.red),
        );
      }
    }
  }
  
  Widget _buildCustomToolTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Expanded(child: Text('SL NO', style: _headerStyle())),
                Expanded(child: Text('QTY', style: _headerStyle())),
                Expanded(flex: 3, child: Text('TOOL NAME', style: _headerStyle())),
                Expanded(flex: 2, child: Text('TOOL DER NAME', style: _headerStyle())),
                Expanded(child: Text('TOOL NO', style: _headerStyle())),
                Expanded(child: Text('MAGAZINE', style: _headerStyle())),
                Expanded(child: Text('POCKET', style: _headerStyle())),
              ],
            ),
          ),
          ...customToolData.map((tool) => _buildTableRow(tool)).toList(),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}