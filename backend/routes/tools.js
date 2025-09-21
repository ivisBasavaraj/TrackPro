const express = require('express');
const XLSX = require('xlsx');
const ToolList = require('../models/ToolList');
const { auth, supervisorAuth } = require('../middleware/auth');
const excelUpload = require('../middleware/excelUpload');

const router = express.Router();

// Upload Excel tool list (Supervisor only)
router.post('/upload', auth, supervisorAuth, excelUpload.single('excel'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'No Excel file uploaded' });
    }

    const { toolName } = req.body;
    if (!toolName) {
      return res.status(400).json({ message: 'Tool name is required' });
    }

    // Read Excel file
    const workbook = XLSX.readFile(req.file.path);
    const sheetName = workbook.SheetNames[0];
    const worksheet = workbook.Sheets[sheetName];
    const jsonData = XLSX.utils.sheet_to_json(worksheet);

    // Process Excel data
    const toolData = jsonData.map((row, index) => ({
      slNo: row['SL NO'] || row['slNo'] || index + 1,
      qty: row['QTY'] || row['qty'] || 0,
      toolName: row['TOOL NAME'] || row['toolName'] || '',
      toolDer: row['TOOL DER NAME'] || row['toolDer'] || '',
      toolNo: row['TOOL NO'] || row['toolNo'] || '',
      magazine: row['MAGAZINE'] || row['magazine'] || '',
      pocket: row['POCKET'] || row['pocket'] || ''
    }));

    // Save to database
    const toolList = new ToolList({
      toolName,
      toolData,
      uploadedBy: req.user._id,
      fileName: req.file.originalname,
      filePath: req.file.path
    });

    await toolList.save();
    await toolList.populate('uploadedBy', 'name username');

    res.status(201).json({
      success: true,
      toolList,
      message: 'Tool list uploaded successfully'
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get all tool lists
router.get('/', auth, async (req, res) => {
  try {
    const toolLists = await ToolList.find()
      .populate('uploadedBy', 'name username')
      .sort({ createdAt: -1 });

    res.json(toolLists);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get tool list by name
router.get('/:toolName', auth, async (req, res) => {
  try {
    const toolList = await ToolList.findOne({ toolName: req.params.toolName })
      .populate('uploadedBy', 'name username');

    if (!toolList) {
      return res.status(404).json({ message: 'Tool list not found' });
    }

    res.json(toolList);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Delete tool list (Supervisor only)
router.delete('/:id', auth, supervisorAuth, async (req, res) => {
  try {
    const toolList = await ToolList.findByIdAndDelete(req.params.id);

    if (!toolList) {
      return res.status(404).json({ message: 'Tool list not found' });
    }

    res.json({ message: 'Tool list deleted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;