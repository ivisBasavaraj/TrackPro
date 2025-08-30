import jwt from 'jsonwebtoken'
import User from '../models/User.js'

export const authRequired = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization || ''
    const token = authHeader.startsWith('Bearer ') ? authHeader.slice(7) : null
    if (!token) return res.status(401).json({ message: 'Unauthorized' })

    const payload = jwt.verify(token, process.env.JWT_SECRET || 'dev_secret')
    const user = await User.findById(payload.sub)
    if (!user || !user.isActive) return res.status(401).json({ message: 'Unauthorized' })

    req.user = { id: user._id.toString(), role: user.role }
    next()
  } catch (err) {
    return res.status(401).json({ message: 'Unauthorized' })
  }
}

export const requireRole = (roles = []) => (req, res, next) => {
  const allowed = Array.isArray(roles) ? roles : [roles]
  if (!req.user || !allowed.includes(req.user.role)) {
    return res.status(403).json({ message: 'Forbidden' })
  }
  next()
}