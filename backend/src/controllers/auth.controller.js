import jwt from 'jsonwebtoken'
import createError from 'http-errors'
import User from '../models/User.js'

const signTokens = (user) => {
  const payload = { sub: user._id.toString(), role: user.role }
  const accessToken = jwt.sign(payload, process.env.JWT_SECRET || 'dev_secret', {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d'
  })
  return { accessToken }
}

export const register = async (req, res, next) => {
  try {
    const { name, email, password } = req.body
    if (!email || !password) throw createError(400, 'Email and password are required')

    const exists = await User.findOne({ email })
    if (exists) throw createError(409, 'Email already in use')

    const user = await User.create({ name, email, password })
    const tokens = signTokens(user)
    res.status(201).json({ user: { id: user._id, name: user.name, email: user.email, role: user.role }, ...tokens })
  } catch (err) { next(err) }
}

export const login = async (req, res, next) => {
  try {
    const { email, password } = req.body
    const user = await User.findOne({ email }).select('+password')
    if (!user) throw createError(401, 'Invalid credentials')

    const ok = await user.comparePassword(password)
    if (!ok) throw createError(401, 'Invalid credentials')

    const tokens = signTokens(user)
    res.json({ user: { id: user._id, name: user.name, email: user.email, role: user.role }, ...tokens })
  } catch (err) { next(err) }
}

export const me = async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id)
    res.json({ user })
  } catch (err) { next(err) }
}