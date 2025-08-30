// Placeholder generic CRUD for a resource. Replace with your custom models later.
import mongoose from 'mongoose'

const ResourceSchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: { type: String },
  owner: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }
}, { timestamps: true })

const Resource = mongoose.models.Resource || mongoose.model('Resource', ResourceSchema)

export const createResource = async (req, res, next) => {
  try {
    const resource = await Resource.create({ ...req.body, owner: req.user?.id })
    res.status(201).json({ resource })
  } catch (err) { next(err) }
}

export const listResources = async (req, res, next) => {
  try {
    const resources = await Resource.find().populate('owner', 'name email')
    res.json({ resources })
  } catch (err) { next(err) }
}

export const getResource = async (req, res, next) => {
  try {
    const resource = await Resource.findById(req.params.id)
    if (!resource) return res.status(404).json({ message: 'Not found' })
    res.json({ resource })
  } catch (err) { next(err) }
}

export const updateResource = async (req, res, next) => {
  try {
    const resource = await Resource.findByIdAndUpdate(req.params.id, req.body, { new: true })
    if (!resource) return res.status(404).json({ message: 'Not found' })
    res.json({ resource })
  } catch (err) { next(err) }
}

export const deleteResource = async (req, res, next) => {
  try {
    const resource = await Resource.findByIdAndDelete(req.params.id)
    if (!resource) return res.status(404).json({ message: 'Not found' })
    res.json({ success: true })
  } catch (err) { next(err) }
}