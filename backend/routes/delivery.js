const express = require('express');
const { body, validationResult } = require('express-validator');
const Delivery = require('../models/Delivery');
const { auth } = require('../middleware/auth');
const upload = require('../middleware/upload');

const router = express.Router();

// Create new delivery record
router.post('/', auth, upload.single('deliveryProofImage'), [
  body('customerName').notEmpty().withMessage('Customer name is required'),
  body('customerId').optional().isString(),
  body('deliveryAddress').notEmpty().withMessage('Delivery address is required'),
  body('partId').notEmpty().withMessage('Part ID is required'),
  body('vehicleDetails').notEmpty().withMessage('Vehicle details are required'),
  body('driverName').notEmpty().withMessage('Driver name is required'),
  body('driverContact').notEmpty().withMessage('Driver contact is required'),
  body('scheduledDate').isISO8601().withMessage('Invalid scheduled date'),
  body('scheduledTime').notEmpty().withMessage('Scheduled time is required'),
  body('deliveryStatus').isIn(['Pending', 'Dispatched', 'In Transit', 'Delivered', 'Failed']).withMessage('Invalid delivery status'),
  body('remarks').optional().isString()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const deliveryData = {
      ...req.body,
      managedBy: req.user._id
    };

    if (req.file) {
      deliveryData.deliveryProofImage = req.file.path;
    }

    if (req.body.deliveryStatus === 'Delivered') {
      deliveryData.actualDeliveryDate = new Date();
    }

    const delivery = new Delivery(deliveryData);
    await delivery.save();

    await delivery.populate('managedBy', 'name username');

    res.status(201).json(delivery);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get all delivery records
router.get('/', auth, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const skip = (page - 1) * limit;

    const deliveries = await Delivery.find()
      .populate('managedBy', 'name username')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const total = await Delivery.countDocuments();

    res.json({
      deliveries,
      totalPages: Math.ceil(total / limit),
      currentPage: page,
      total
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get delivery record by ID
router.get('/:id', auth, async (req, res) => {
  try {
    const delivery = await Delivery.findById(req.params.id)
      .populate('managedBy', 'name username');

    if (!delivery) {
      return res.status(404).json({ message: 'Delivery record not found' });
    }

    res.json(delivery);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Update delivery record
router.put('/:id', auth, upload.single('deliveryProofImage'), [
  body('customerName').optional().notEmpty().withMessage('Customer name cannot be empty'),
  body('customerId').optional().isString(),
  body('deliveryAddress').optional().notEmpty().withMessage('Delivery address cannot be empty'),
  body('partId').optional().notEmpty().withMessage('Part ID cannot be empty'),
  body('vehicleDetails').optional().notEmpty().withMessage('Vehicle details cannot be empty'),
  body('driverName').optional().notEmpty().withMessage('Driver name cannot be empty'),
  body('driverContact').optional().notEmpty().withMessage('Driver contact cannot be empty'),
  body('scheduledDate').optional().isISO8601().withMessage('Invalid scheduled date'),
  body('scheduledTime').optional().notEmpty().withMessage('Scheduled time cannot be empty'),
  body('deliveryStatus').optional().isIn(['Pending', 'Dispatched', 'In Transit', 'Delivered', 'Failed']).withMessage('Invalid delivery status'),
  body('remarks').optional().isString()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const updateData = { ...req.body };

    if (req.file) {
      updateData.deliveryProofImage = req.file.path;
    }

    if (req.body.deliveryStatus === 'Delivered' && !updateData.actualDeliveryDate) {
      updateData.actualDeliveryDate = new Date();
    }

    const delivery = await Delivery.findByIdAndUpdate(
      req.params.id,
      updateData,
      { new: true }
    ).populate('managedBy', 'name username');

    if (!delivery) {
      return res.status(404).json({ message: 'Delivery record not found' });
    }

    res.json(delivery);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Delete delivery record
router.delete('/:id', auth, async (req, res) => {
  try {
    const delivery = await Delivery.findByIdAndDelete(req.params.id);

    if (!delivery) {
      return res.status(404).json({ message: 'Delivery record not found' });
    }

    res.json({ message: 'Delivery record deleted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get delivery records by user
router.get('/user/:userId', auth, async (req, res) => {
  try {
    const deliveries = await Delivery.find({ managedBy: req.params.userId })
      .populate('managedBy', 'name username')
      .sort({ createdAt: -1 });

    res.json(deliveries);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get delivery statistics
router.get('/stats/delivery', auth, async (req, res) => {
  try {
    const stats = await Delivery.aggregate([
      {
        $group: {
          _id: '$deliveryStatus',
          count: { $sum: 1 }
        }
      }
    ]);

    const totalDeliveries = await Delivery.countDocuments();
    const deliveredCount = await Delivery.countDocuments({ deliveryStatus: 'Delivered' });
    const pendingCount = await Delivery.countDocuments({ deliveryStatus: 'Pending' });
    const inTransitCount = await Delivery.countDocuments({ deliveryStatus: 'In Transit' });
    const failedCount = await Delivery.countDocuments({ deliveryStatus: 'Failed' });

    const deliveryRate = totalDeliveries > 0 ? 
      ((deliveredCount / totalDeliveries) * 100).toFixed(2) : 0;

    res.json({
      totalDeliveries,
      deliveredCount,
      pendingCount,
      inTransitCount,
      failedCount,
      deliveryRate,
      statusBreakdown: stats
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get upcoming deliveries
router.get('/stats/upcoming', auth, async (req, res) => {
  try {
    const today = new Date();
    const nextWeek = new Date(today.getTime() + 7 * 24 * 60 * 60 * 1000);

    const upcomingDeliveries = await Delivery.find({
      scheduledDate: { $gte: today, $lte: nextWeek },
      deliveryStatus: { $in: ['Pending', 'Dispatched', 'In Transit'] }
    })
      .populate('managedBy', 'name username')
      .sort({ scheduledDate: 1 });

    res.json(upcomingDeliveries);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;