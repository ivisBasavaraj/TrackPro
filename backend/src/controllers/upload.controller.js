import path from 'path'

export const uploadedFile = async (req, res) => {
  if (!req.file) return res.status(400).json({ message: 'No file uploaded' })
  const filePath = `/uploads/${req.file.filename}`
  res.status(201).json({ file: { filename: req.file.filename, url: filePath, mimetype: req.file.mimetype, size: req.file.size } })
}