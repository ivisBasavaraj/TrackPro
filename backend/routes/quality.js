const express = require('express');
const { body, validationResult } = require('express-validator');
const QualityControl = require('../models/QualityControl');
const { auth } = require('../middleware/auth');
const upload = require('../middleware/upload');

const router = express.Router();

// Create new quality control record
router.post('/', auth, upload.single('signatureImage'), [
  body('partId').notEmpty().withMessage('Part ID is required'),
  body('holeDimensions.hole1').isNumeric().withMessage('Hole 1 dimension must be numeric'),
  body('holeDimensions.hole2').isNumeric().withMessage('Hole 2 dimension must be numeric'),
  body('holeDimensions.hole3').isNumeric().withMessage('Hole 3 dimension must be numeric'),
  body('levelReadings.level1').isNumeric().withMessage('Level 1 reading must be numeric'),
  body('levelReadings.level2').isNumeric().withMessage('Level 2 reading must be numeric'),
  body('levelReadings.level3').isNumeric().withMessage('Level 3 reading must be numeric'),
  body('inspectorName').notEmpty().withMessage('Inspector name is required'),
  body('remarks').optional().isString()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const qcData = {
      ...req.body,
      inspectedBy: req.user._id
    };

    if (req.file) {
      qcData.signatureImage = req.file.path;
    }

    const qualityControl = new QualityControl(qcData);
    await qualityControl.save();

    await qualityControl.populate('inspectedBy', 'name username');

    res.status(201).json(qualityControl);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get all quality control records
router.get('/', auth, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;

    const qcRecords = await QualityControl.find()
      .populate('inspectedBy', 'name username')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const total = await QualityControl.countDocuments();

    res.json({
      qcRecords,
      totalPages: Math.ceil(total / limit),
      currentPage: page,
      total
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get quality control record by ID
router.get('/:id', auth, async (req, res) => {
  try {
    const qcRecord = await QualityControl.findById(req.params.id)
      .populate('inspectedBy', 'name username');

    if (!qcRecord) {
      return res.status(404).json({ message: 'Quality control record not found' });
    }

    res.json(qcRecord);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Update quality control record
router.put('/:id', auth, upload.single('signatureImage'), [
  body('partId').optional().notEmpty().withMessage('Part ID cannot be empty'),
  body('holeDimensions.hole1').optional().isNumeric().withMessage('Hole 1 dimension must be numeric'),
  body('holeDimensions.hole2').optional().isNumeric().withMessage('Hole 2 dimension must be numeric'),
  body('holeDimensions.hole3').optional().isNumeric().withMessage('Hole 3 dimension must be numeric'),
  body('levelReadings.level1').optional().isNumeric().withMessage('Level 1 reading must be numeric'),
  body('levelReadings.level2').optional().isNumeric().withMessage('Level 2 reading must be numeric'),
  body('levelReadings.level3').optional().isNumeric().withMessage('Level 3 reading must be numeric'),
  body('inspectorName').optional().notEmpty().withMessage('Inspector name cannot be empty'),
  body('remarks').optional().isString()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const updateData = { ...req.body };

    if (req.file) {
      updateData.signatureImage = req.file.path;
    }

    const qcRecord = await QualityControl.findByIdAndUpdate(
      req.params.id,
      updateData,
      { new: true }
    ).populate('inspectedBy', 'name username');

    if (!qcRecord) {
      return res.status(404).json({ message: 'Quality control record not found' });
    }

    res.json(qcRecord);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Delete quality control record
router.delete('/:id', auth, async (req, res) => {
  try {
    const qcRecord = await QualityControl.findByIdAndDelete(req.params.id);

    if (!qcRecord) {
      return res.status(404).json({ message: 'Quality control record not found' });
    }

    res.json({ message: 'Quality control record deleted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get quality control records by user
router.get('/user/:userId', auth, async (req, res) => {
  try {
    const qcRecords = await QualityControl.find({ inspectedBy: req.params.userId })
      .populate('inspectedBy', 'name username')
      .sort({ createdAt: -1 });

    res.json(qcRecords);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get quality statistics
router.get('/stats/quality', auth, async (req, res) => {
  try {
    const stats = await QualityControl.aggregate([
      {
        $group: {
          _id: null,
          totalRecords: { $sum: 1 },
          passCount: {
            $sum: { $cond: [{ $eq: ['$qcStatus', 'Pass'] }, 1, 0] }
          },
          failCount: {
            $sum: { $cond: [{ $eq: ['$qcStatus', 'Fail'] }, 1, 0] }
          },
          toleranceExceededCount: {
            $sum: { $cond: ['$toleranceExceeded', 1, 0] }
          }
        }
      }
    ]);

    const result = stats[0] || {
      totalRecords: 0,
      passCount: 0,
      failCount: 0,
      toleranceExceededCount: 0
    };

    result.passRate = result.totalRecords > 0 ? 
      ((result.passCount / result.totalRecords) * 100).toFixed(2) : 0;

    res.json(result);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get recent failed QC records
router.get('/stats/recent-failures', auth, async (req, res) => {
  try {
    const recentFailures = await QualityControl.find({ qcStatus: 'Fail' })
      .populate('inspectedBy', 'name username')
      .sort({ createdAt: -1 })
      .limit(10);

    res.json(recentFailures);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;