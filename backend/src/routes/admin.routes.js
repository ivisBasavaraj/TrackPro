import { Router } from 'express'
import { authRequired, requireRole } from '../middleware/auth.js'
import User from '../models/User.js'

const router = Router()

// Require authentication and admin role for all admin routes
router.use(authRequired, requireRole(['admin']))

// Simple dashboard stats example
router.get('/stats', async (req, res, next) => {
  try {
    const [users, admins] = await Promise.all([
      User.countDocuments(),
      User.countDocuments({ role: 'admin' })
    ])
    res.json({ stats: { users, admins } })
  } catch (err) { next(err) }
})

// Toggle user activation
router.patch('/users/:id/toggle-active', async (req, res, next) => {
  try {
    const user = await User.findById(req.params.id)
    if (!user) return res.status(404).json({ message: 'User not found' })
    user.isActive = !user.isActive
    await user.save()
    res.json({ user })
  } catch (err) { next(err) }
})

// Promote/Demote user role
router.patch('/users/:id/role', async (req, res, next) => {
  try {
    const { role } = req.body
    if (!['user', 'admin'].includes(role)) {
      return res.status(400).json({ message: 'Invalid role' })
    }
    const user = await User.findByIdAndUpdate(req.params.id, { role }, { new: true })
    if (!user) return res.status(404).json({ message: 'User not found' })
    res.json({ user })
  } catch (err) { next(err) }
})

export default router