// File: lib/screens/incoming_inspection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';
import '../services/api_service.dart';

class IncomingInspectionScreen extends StatefulWidget {
  @override
  _IncomingInspectionScreenState createState() => _IncomingInspectionScreenState();
}

class _IncomingInspectionScreenState extends State<IncomingInspectionScreen> {
  List<InspectionUnit> inspectionUnits = [InspectionUnit()];

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
        title: Text(
          'Incoming Inspection',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Colors.black),
            onPressed: _saveAllInspections,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              itemCount: inspectionUnits.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: InspectionUnitWidget(
                    unit: inspectionUnits[index],
                    unitNumber: index + 1,
                    onRemove: inspectionUnits.length > 1 
                        ? () => _removeUnit(index)
                        : null,
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _addNewUnit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: Icon(Icons.add, color: Colors.white),
                label: Text(
                  'Add New Unit',
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
    );
  }

  void _addNewUnit() {
    setState(() {
      inspectionUnits.add(InspectionUnit());
    });
  }

  void _removeUnit(int index) {
    setState(() {
      inspectionUnits.removeAt(index);
    });
  }

  void _saveAllInspections() async {
    bool isValid = true;
    for (int i = 0; i < inspectionUnits.length; i++) {
      if (inspectionUnits[i].componentName.isEmpty) {
        isValid = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please fill component name for Unit ${i + 1}'),
            backgroundColor: Colors.red,
          ),
        );
        break;
      }
    }

    if (isValid) {
      for (int i = 0; i < inspectionUnits.length; i++) {
        final unit = inspectionUnits[i];
        final inspectionData = {
          'unitNumber': i + 1,
          'componentName': unit.componentName,
          'supplierDetails': unit.supplierDetails,
          'remarks': unit.remarks,
          'duration': unit.completedDuration ?? '00:00:00',
          'isCompleted': unit.isCompleted,
        };
        
        File? imageFile;
        if (unit.imagePath != null) {
          imageFile = File(unit.imagePath!);
        }
        
        final result = await ApiService.createInspection(inspectionData, image: imageFile);
        if (!result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save Unit ${i + 1}: ${result['message']}'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('All inspections saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

class InspectionUnit {
  String componentName = '';
  String supplierDetails = '';
  DateTime dateTime = DateTime.now();
  String remarks = '';
  String? imagePath;
  
  // Timer properties
  Stopwatch stopwatch = Stopwatch();
  bool isTimerRunning = false;
  String? completedDuration;
  bool isCompleted = false;

  InspectionUnit();
}

class InspectionUnitWidget extends StatefulWidget {
  final InspectionUnit unit;
  final int unitNumber;
  final VoidCallback? onRemove;

  InspectionUnitWidget({
    required this.unit,
    required this.unitNumber,
    this.onRemove,
  });

  @override
  _InspectionUnitWidgetState createState() => _InspectionUnitWidgetState();
}

class _InspectionUnitWidgetState extends State<InspectionUnitWidget> {
  final TextEditingController _componentNameController = TextEditingController();
  final TextEditingController _supplierController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  
  Timer? _timer;
  String _currentElapsedTime = '00:00:00';

  @override
  void initState() {
    super.initState();
    _componentNameController.text = widget.unit.componentName;
    _supplierController.text = widget.unit.supplierDetails;
    _remarksController.text = widget.unit.remarks;
    
    // Removed automatic timer start - timer now starts only when user clicks "Start"
    
    // Update timer display
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (widget.unit.stopwatch.isRunning && mounted) {
        setState(() {
          _currentElapsedTime = _formatTime(widget.unit.stopwatch.elapsed);
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

  void _startTimer() {
    setState(() {
      widget.unit.stopwatch.start();
      widget.unit.isTimerRunning = true;
    });
  }

  void _pauseTimer() {
    setState(() {
      widget.unit.stopwatch.stop();
      widget.unit.isTimerRunning = false;
    });
  }

  void _stopTimer() {
    setState(() {
      widget.unit.stopwatch.stop();
      widget.unit.isTimerRunning = false;
      widget.unit.isCompleted = true;
      widget.unit.completedDuration = _formatTime(widget.unit.stopwatch.elapsed);
    });
  }

  @override
  Widget build(BuildContext context) {
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
          // Header with unit number and remove button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Unit ${widget.unitNumber}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              if (widget.onRemove != null)
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: widget.onRemove,
                ),
            ],
          ),
          SizedBox(height: 15),

          // Timer Section for this unit
          _buildTimerSection(),
          SizedBox(height: 20),

          // Camera Section
          _buildCameraSection(),
          SizedBox(height: 20),

          // Component Name Field
          _buildTextField(
            'Component Name *',
            _componentNameController,
            (value) => widget.unit.componentName = value,
          ),
          SizedBox(height: 15),

          // Supplier Details Field
          _buildTextField(
            'Supplier Details',
            _supplierController,
            (value) => widget.unit.supplierDetails = value,
          ),
          SizedBox(height: 15),

          // Date & Time Display
          _buildDateTimeSection(),
          SizedBox(height: 15),

          // Remarks Field
          _buildTextField(
            'Remarks/Comments',
            _remarksController,
            (value) => widget.unit.remarks = value,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildTimerSection() {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: widget.unit.isCompleted ? Colors.green[50] : Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.unit.isCompleted ? Colors.green[200]! : Colors.blue[200]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.unit.isCompleted ? 'Inspection Completed' : 'Inspection Timer',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: widget.unit.isCompleted ? Colors.green[700] : Colors.blue[700],
                ),
              ),
              if (widget.unit.isCompleted)
                Icon(
                  Icons.check_circle,
                  color: Colors.green[600],
                  size: 20,
                ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            widget.unit.isCompleted 
                ? widget.unit.completedDuration! 
                : _currentElapsedTime,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: widget.unit.isCompleted ? Colors.green[700] : Colors.blue[700],
              fontFamily: 'monospace',
            ),
          ),
          if (!widget.unit.isCompleted) ...[
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimerButton(
                  'Start',
                  Icons.play_arrow,
                  Colors.green,
                  widget.unit.isTimerRunning ? null : _startTimer,
                ),
                _buildTimerButton(
                  'Pause',
                  Icons.pause,
                  Colors.orange,
                  widget.unit.isTimerRunning ? _pauseTimer : null,
                ),
                _buildTimerButton(
                  'Complete',
                  Icons.stop,
                  Colors.red,
                  _stopTimer,
                ),
              ],
            ),
          ],
          if (widget.unit.isCompleted)
            Container(
              margin: EdgeInsets.only(top: 10),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                'Duration: ${widget.unit.completedDuration}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
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
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      icon: Icon(icon, size: 14),
      label: Text(label, style: TextStyle(fontSize: 11)),
    );
  }

  Widget _buildCameraSection() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: widget.unit.imagePath != null
          ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(widget.unit.imagePath!),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        widget.unit.imagePath = null;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : GestureDetector(
              onTap: _openCamera,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt,
                    size: 50,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Tap to Capture Photo',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Live camera only',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
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
          controller: controller,
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

  Widget _buildDateTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date & Time of Inspection',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${widget.unit.dateTime.day}/${widget.unit.dateTime.month}/${widget.unit.dateTime.year} at ${widget.unit.dateTime.hour}:${widget.unit.dateTime.minute.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }

  void _openCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No cameras available')),
        );
        return;
      }

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraScreen(camera: cameras.first),
        ),
      );

      if (result != null) {
        setState(() {
          widget.unit.imagePath = result;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening camera: $e')),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _componentNameController.dispose();
    _supplierController.dispose();
    _remarksController.dispose();
    super.dispose();
  }
}

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  CameraScreen({required this.camera});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  GlobalKey _repaintBoundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller!.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Capture Photo',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                Expanded(
                  child: RepaintBoundary(
                    key: _repaintBoundaryKey,
                    child: Stack(
                      children: [
                        CameraPreview(_controller!),
                        // Watermark overlay
                        Positioned(
                          bottom: 20,
                          right: 20,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _getCurrentDate(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _getCurrentTime(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 120,
                  child: Center(
                    child: FloatingActionButton(
                      backgroundColor: Colors.white,
                      onPressed: _takePictureWithWatermark,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          }
        },
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  void _takePictureWithWatermark() async {
    try {
      await _initializeControllerFuture;
      
      // Capture the widget with watermark as image
      RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save the image with watermark
      final directory = await getTemporaryDirectory();
      final imagePath = path.join(
        directory.path,
        '${DateTime.now().millisecondsSinceEpoch}.png',
      );
      
      File imageFile = File(imagePath);
      await imageFile.writeAsBytes(pngBytes);

      Navigator.pop(context, imagePath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error taking picture: $e')),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}