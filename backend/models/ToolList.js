const mongoose = require('mongoose');

const toolListSchema = new mongoose.Schema({
  toolName: {
    type: String,
    required: true,
    trim: true
  },
  toolData: [{
    slNo: Number,
    qty: Number,
    toolName: String,
    toolDer: String,
    toolNo: String,
    magazine: String,
    pocket: String
  }],
  uploadedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  fileName: String,
  filePath: String
}, {
  timestamps: true
});

module.exports = mongoose.model('ToolList', toolListSchema);