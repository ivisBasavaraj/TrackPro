const mongoose = require('mongoose');

const inspectionSchema = new mongoose.Schema({
  unitNumber: {
    type: Number,
    required: true
  },
  componentName: {
    type: String,
    required: true,
    trim: true
  },
  supplierDetails: {
    type: String,
    trim: true
  },
  imagePath: {
    type: String
  },
  remarks: {
    type: String,
    trim: true
  },
  startTime: {
    type: Date,
    default: Date.now
  },
  endTime: {
    type: Date
  },
  duration: {
    type: String // Format: "HH:MM:SS"
  },
  isCompleted: {
    type: Boolean,
    default: false
  },
  inspectedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('Inspection', inspectionSchema);