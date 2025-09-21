const express = require('express');
const User = require('../models/User');
const Inspection = require('../models/Inspection');
const Finishing = require('../models/Finishing');
const QualityControl = require('../models/QualityControl');
const Delivery = require('../models/Delivery');
const { auth, adminAuth, supervisorAuth } = require('../middleware/auth');

const router = express.Router();

// Get admin dashboard data
router.get('/admin', auth, adminAuth, async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    // Get today's statistics
    const todayInspections = await Inspection.countDocuments({
      createdAt: { $gte: today, $lt: tomorrow }
    });

    const todayFinishing = await Finishing.countDocuments({
      createdAt: { $gte: today, $lt: tomorrow }
    });

    const todayQC = await QualityControl.countDocuments({
      createdAt: { $gte: today, $lt: tomorrow }
    });

    const todayDeliveries = await Delivery.countDocuments({
      createdAt: { $gte: today, $lt: tomorrow }
    });

    // Get quality rate
    const totalQC = await QualityControl.countDocuments();
    const passedQC = await QualityControl.countDocuments({ qcStatus: 'Pass' });
    const qualityRate = totalQC > 0 ? ((passedQC / totalQC) * 100).toFixed(1) : 0;

    // Get active users
    const activeUsers = await User.countDocuments({ isActive: true });
    const totalUsers = await User.countDocuments();

    // Get operations status
    const operationsStatus = {
      incomingInspection: {
        active: await Inspection.countDocuments({ isCompleted: false }),
        completed: todayInspections,
        performance: 85
      },
      finishing: {
        inProgress: await Finishing.countDocuments({ isCompleted: false }),
        completed: todayFinishing,
        performance: 73
      },
      qualityControl: {
        inspected: todayQC,
        passRate: qualityRate,
        performance: 98
      },
      delivery: {
        dispatched: todayDeliveries,
        inTransit: await Delivery.countDocuments({ deliveryStatus: 'In Transit' }),
        delivered: await Delivery.countDocuments({ 
          deliveryStatus: 'Delivered',
          actualDeliveryDate: { $gte: today, $lt: tomorrow }
        }),
        performance: 91
      }
    };

    // Get recent activity
    const recentActivity = [];

    // Recent QC failures
    const recentQCFailures = await QualityControl.find({ qcStatus: 'Fail' })
      .sort({ createdAt: -1 })
      .limit(2)
      .populate('inspectedBy', 'name');

    recentQCFailures.forEach(qc => {
      recentActivity.push({
        type: 'Quality Control Failed',
        description: `Part ID: ${qc.partId} exceeded tolerance`,
        time: qc.createdAt,
        icon: 'error',
        color: 'red'
      });
    });

    // Recent deliveries
    const recentDeliveries = await Delivery.find({ deliveryStatus: 'Delivered' })
      .sort({ actualDeliveryDate: -1 })
      .limit(2);

    recentDeliveries.forEach(delivery => {
      recentActivity.push({
        type: 'Delivery Completed',
        description: `Customer: ${delivery.customerName}`,
        time: delivery.actualDeliveryDate,
        icon: 'check_circle',
        color: 'green'
      });
    });

    // Sort recent activity by time
    recentActivity.sort((a, b) => new Date(b.time) - new Date(a.time));

    res.json({
      todayOverview: {
        totalUnits: todayInspections + todayFinishing,
        qualityRate: parseFloat(qualityRate),
        activeTasks: await User.aggregate([
          { $group: { _id: null, total: { $sum: '$totalAssigned' } } }
        ]).then(result => result[0]?.total || 0),
        deliveries: todayDeliveries
      },
      operationsStatus,
      recentActivity: recentActivity.slice(0, 4),
      teamOverview: {
        activeUsers,
        totalUsers,
        efficiency: activeUsers > 0 ? Math.round((activeUsers / totalUsers) * 100) : 0
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get supervisor dashboard data
router.get('/supervisor', auth, supervisorAuth, async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    // Get today's statistics
    const todayInspections = await Inspection.countDocuments({
      createdAt: { $gte: today, $lt: tomorrow }
    });

    const todayFinishing = await Finishing.countDocuments({
      createdAt: { $gte: today, $lt: tomorrow }
    });

    const todayQC = await QualityControl.countDocuments({
      createdAt: { $gte: today, $lt: tomorrow }
    });

    const todayDeliveries = await Delivery.countDocuments({
      createdAt: { $gte: today, $lt: tomorrow }
    });

    // Get assigned users
    const assignedUsers = await User.find({ assignedTask: { $ne: null } });
    const unassignedUsers = await User.find({ assignedTask: null, role: 'User' });

    res.json({
      processOverview: {
        totalUnitsProcessed: todayInspections + todayFinishing + todayQC + todayDeliveries,
        incomingInspection: todayInspections,
        finishing: todayFinishing,
        qualityControl: todayQC,
        delivery: todayDeliveries
      },
      userManagement: {
        assignedUsers: assignedUsers.length,
        unassignedUsers: unassignedUsers.length,
        totalUsers: assignedUsers.length + unassignedUsers.length
      },
      taskDistribution: await User.aggregate([
        { $match: { assignedTask: { $ne: null } } },
        { $group: { _id: '$assignedTask', count: { $sum: 1 } } }
      ])
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get user dashboard data
router.get('/user', auth, async (req, res) => {
  try {
    const userId = req.user._id;
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    // Get user's today's work
    const userInspections = await Inspection.countDocuments({
      inspectedBy: userId,
      createdAt: { $gte: today, $lt: tomorrow }
    });

    const userFinishing = await Finishing.countDocuments({
      processedBy: userId,
      createdAt: { $gte: today, $lt: tomorrow }
    });

    const userQC = await QualityControl.countDocuments({
      inspectedBy: userId,
      createdAt: { $gte: today, $lt: tomorrow }
    });

    const userDeliveries = await Delivery.countDocuments({
      managedBy: userId,
      createdAt: { $gte: today, $lt: tomorrow }
    });

    // Get user's assigned task
    const user = await User.findById(userId);

    res.json({
      assignedTask: user.assignedTask,
      todayWork: {
        incomingInspection: userInspections,
        finishing: userFinishing,
        qualityControl: userQC,
        delivery: userDeliveries,
        total: userInspections + userFinishing + userQC + userDeliveries
      },
      processOverview: {
        totalUnitsProcessed: 1500 // This could be calculated from all user's historical data
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get reports data
router.get('/reports/:type', auth, async (req, res) => {
  try {
    const { type } = req.params;
    const { startDate, endDate } = req.query;

    let dateFilter = {};
    if (startDate && endDate) {
      dateFilter = {
        createdAt: {
          $gte: new Date(startDate),
          $lte: new Date(endDate)
        }
      };
    }

    let reportData = {};

    switch (type) {
      case 'operations':
        reportData = {
          inspections: await Inspection.countDocuments(dateFilter),
          finishing: await Finishing.countDocuments(dateFilter),
          qualityControl: await QualityControl.countDocuments(dateFilter),
          deliveries: await Delivery.countDocuments(dateFilter)
        };
        break;

      case 'quality':
        const qcRecords = await QualityControl.find(dateFilter);
        const totalQC = qcRecords.length;
        const passedQC = qcRecords.filter(qc => qc.qcStatus === 'Pass').length;
        const failedQC = qcRecords.filter(qc => qc.qcStatus === 'Fail').length;

        reportData = {
          totalRecords: totalQC,
          passed: passedQC,
          failed: failedQC,
          passRate: totalQC > 0 ? ((passedQC / totalQC) * 100).toFixed(2) : 0,
          toleranceExceeded: qcRecords.filter(qc => qc.toleranceExceeded).length
        };
        break;

      case 'production':
        reportData = {
          totalProduction: await Inspection.countDocuments(dateFilter) + 
                          await Finishing.countDocuments(dateFilter),
          completedInspections: await Inspection.countDocuments({
            ...dateFilter,
            isCompleted: true
          }),
          completedFinishing: await Finishing.countDocuments({
            ...dateFilter,
            isCompleted: true
          }),
          toolUsage: await Finishing.aggregate([
            { $match: dateFilter },
            { $group: { _id: '$toolUsed', count: { $sum: 1 } } }
          ])
        };
        break;

      case 'users':
        reportData = {
          totalUsers: await User.countDocuments(),
          activeUsers: await User.countDocuments({ isActive: true }),
          userPerformance: await User.aggregate([
            {
              $project: {
                name: 1,
                role: 1,
                assignedTask: 1,
                completedToday: 1,
                totalAssigned: 1,
                efficiency: {
                  $cond: [
                    { $gt: ['$totalAssigned', 0] },
                    { $multiply: [{ $divide: ['$completedToday', '$totalAssigned'] }, 100] },
                    0
                  ]
                }
              }
            }
          ])
        };
        break;

      default:
        return res.status(400).json({ message: 'Invalid report type' });
    }

    res.json(reportData);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;