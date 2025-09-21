const express = require('express');
const { body, validationResult } = require('express-validator');
const Finishing = require('../models/Finishing');
const { auth } = require('../middleware/auth');

const router = express.Router();

// Create new finishing record
router.post('/', auth, [
  body('toolUsed').isIn(['AMS-141 COLUMN', 'AMS-915 COLUMN', 'AMS-103 COLUMN', 'AMS-477 BASE']).withMessage('Invalid tool'),
  body('toolStatus').isIn(['Working', 'Faulty']).withMessage('Invalid tool status'),
  body('partComponentId').notEmpty().withMessage('Part/Component ID is required'),
  body('operatorName').notEmpty().withMessage('Operator name is required'),
  body('remarks').optional().isString(),
  body('duration').optional().isString(),
  body('isCompleted').optional().isBoolean()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const finishingData = {
      ...req.body,
      processedBy: req.user._id
    };

    if (req.body.isCompleted === 'true') {
      finishingData.endTime = new Date();
    }

    const finishing = new Finishing(finishingData);
    await finishing.save();

    await finishing.populate('processedBy', 'name username');

    res.status(201).json(finishing);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get all finishing records
router.get('/', auth, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;

    const finishingRecords = await Finishing.find()
      .populate('processedBy', 'name username')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const total = await Finishing.countDocuments();

    res.json({
      finishingRecords,
      totalPages: Math.ceil(total / limit),
      currentPage: page,
      total
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get finishing record by ID
router.get('/:id', auth, async (req, res) => {
  try {
    const finishing = await Finishing.findById(req.params.id)
      .populate('processedBy', 'name username');

    if (!finishing) {
      return res.status(404).json({ message: 'Finishing record not found' });
    }

    res.json(finishing);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Update finishing record
router.put('/:id', auth, [
  body('toolUsed').optional().isIn(['AMS-141 COLUMN', 'AMS-915 COLUMN', 'AMS-103 COLUMN', 'AMS-477 BASE']).withMessage('Invalid tool'),
  body('toolStatus').optional().isIn(['Working', 'Faulty']).withMessage('Invalid tool status'),
  body('partComponentId').optional().notEmpty().withMessage('Part/Component ID cannot be empty'),
  body('operatorName').optional().notEmpty().withMessage('Operator name cannot be empty'),
  body('remarks').optional().isString(),
  body('duration').optional().isString(),
  body('isCompleted').optional().isBoolean()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const updateData = { ...req.body };

    if (req.body.isCompleted === 'true' && !updateData.endTime) {
      updateData.endTime = new Date();
    }

    const finishing = await Finishing.findByIdAndUpdate(
      req.params.id,
      updateData,
      { new: true }
    ).populate('processedBy', 'name username');

    if (!finishing) {
      return res.status(404).json({ message: 'Finishing record not found' });
    }

    res.json(finishing);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Delete finishing record
router.delete('/:id', auth, async (req, res) => {
  try {
    const finishing = await Finishing.findByIdAndDelete(req.params.id);

    if (!finishing) {
      return res.status(404).json({ message: 'Finishing record not found' });
    }

    res.json({ message: 'Finishing record deleted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get finishing records by user
router.get('/user/:userId', auth, async (req, res) => {
  try {
    const finishingRecords = await Finishing.find({ processedBy: req.params.userId })
      .populate('processedBy', 'name username')
      .sort({ createdAt: -1 });

    res.json(finishingRecords);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get tool usage statistics
router.get('/stats/tools', auth, async (req, res) => {
  try {
    const toolStats = await Finishing.aggregate([
      {
        $group: {
          _id: '$toolUsed',
          count: { $sum: 1 },
          workingCount: {
            $sum: { $cond: [{ $eq: ['$toolStatus', 'Working'] }, 1, 0] }
          },
          faultyCount: {
            $sum: { $cond: [{ $eq: ['$toolStatus', 'Faulty'] }, 1, 0] }
          }
        }
      },
      {
        $sort: { count: -1 }
      }
    ]);

    res.json(toolStats);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;