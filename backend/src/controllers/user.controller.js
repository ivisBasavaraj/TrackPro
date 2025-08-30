import User from '../models/User.js'

export const listUsers = async (req, res, next) => {
  try {
    const users = await User.find().select('-password')
    res.json({ users })
  } catch (err) { next(err) }
}

export const getUser = async (req, res, next) => {
  try {
    const user = await User.findById(req.params.id).select('-password')
    if (!user) return res.status(404).json({ message: 'User not found' })
    res.json({ user })
  } catch (err) { next(err) }
}

export const updateUserRole = async (req, res, next) => {
  try {
    const { role, isActive } = req.body
    const user = await User.findByIdAndUpdate(req.params.id, { role, isActive }, { new: true })
    if (!user) return res.status(404).json({ message: 'User not found' })
    res.json({ user })
  } catch (err) { next(err) }
}

export const removeUser = async (req, res, next) => {
  try {
    const user = await User.findByIdAndDelete(req.params.id)
    if (!user) return res.status(404).json({ message: 'User not found' })
    res.json({ success: true })
  } catch (err) { next(err) }
}