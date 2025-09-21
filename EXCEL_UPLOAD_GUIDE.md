# Excel Upload Feature for Tool Lists

## Overview
Supervisors can now upload Excel files containing tool lists for finishing operations. The uploaded data is parsed and displayed in a structured table format.

## Features Added

### 🔧 Backend Components
- **Excel Upload Middleware**: Handles .xlsx and .xls file uploads
- **ToolList Model**: Stores tool data in MongoDB
- **Tools API Routes**: Upload, retrieve, and manage tool lists
- **XLSX Processing**: Parses Excel files and extracts tool data

### 📱 Frontend Components
- **File Picker Integration**: Select Excel files from device
- **Upload Interface**: User-friendly upload section in finishing screen
- **Dynamic Table Display**: Shows uploaded tool data in structured format
- **Real-time Updates**: Automatically loads custom tool data when available

## How It Works

### 1. Excel File Format
The Excel file should contain these columns:
- **SL NO**: Serial number
- **QTY**: Quantity
- **TOOL NAME**: Name of the tool
- **TOOL DER NAME**: Tool derivative name
- **TOOL NO**: Tool number
- **MAGAZINE**: Magazine location
- **POCKET**: Pocket location

### 2. Upload Process
1. Supervisor selects a tool from dropdown
2. Clicks "Upload Excel" button
3. Selects Excel file using file picker
4. File is uploaded and processed by backend
5. Tool data is stored in database
6. Table is automatically updated with new data

### 3. Data Display
- Custom uploaded data takes priority over default data
- If no custom data exists, shows default AMS-141 COLUMN data
- If no data available, shows message to upload Excel file

## API Endpoints

### Upload Tool List
```
POST /api/tools/upload
Content-Type: multipart/form-data
Authorization: Bearer <token>

Fields:
- toolName: string (required)
- excel: file (required)
```

### Get Tool Lists
```
GET /api/tools
Authorization: Bearer <token>
```

### Get Tool List by Name
```
GET /api/tools/:toolName
Authorization: Bearer <token>
```

## Usage Instructions

### For Supervisors:
1. Navigate to Finishing screen
2. Select desired tool from dropdown
3. Click "Upload Excel" button
4. Choose Excel file with proper format
5. File uploads and table updates automatically

### Excel File Requirements:
- Format: .xlsx or .xls
- Maximum size: 10MB
- Required columns as specified above
- Data should start from row 2 (row 1 for headers)

## Security & Permissions
- Only Supervisors and Admins can upload Excel files
- File type validation ensures only Excel files are accepted
- File size limits prevent large uploads
- All uploads are logged with user information

## Error Handling
- Invalid file format rejection
- File size limit enforcement
- Missing required fields validation
- Network error handling
- User-friendly error messages

## Database Schema
```javascript
{
  toolName: String,
  toolData: [{
    slNo: Number,
    qty: Number,
    toolName: String,
    toolDer: String,
    toolNo: String,
    magazine: String,
    pocket: String
  }],
  uploadedBy: ObjectId,
  fileName: String,
  filePath: String,
  createdAt: Date,
  updatedAt: Date
}
```

The feature is now fully integrated and ready for use by supervisors to manage custom tool lists for different finishing operations.