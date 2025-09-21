const mongoose = require('mongoose');

const finishingSchema = new mongoose.Schema({
  toolUsed: {
    type: String,
    required: true,
    enum: ['AMS-141 COLUMN', 'AMS-915 COLUMN', 'AMS-103 COLUMN', 'AMS-477 BASE']
  },
  toolStatus: {
    type: String,
    enum: ['Working', 'Faulty'],
    default: 'Working'
  },
  partComponentId: {
    type: String,
    required: true,
    trim: true
  },
  operatorName: {
    type: String,
    required: true,
    trim: true
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
  processedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('Finishing', finishingSchema);