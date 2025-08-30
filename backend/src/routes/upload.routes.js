import { Router } from 'express'
import multer from 'multer'
import path from 'path'
import fs from 'fs'
import { authRequired } from '../middleware/auth.js'
import { uploadedFile } from '../controllers/upload.controller.js'

const uploadDir = process.env.UPLOAD_DIR || 'uploads'
if (!fs.existsSync(uploadDir)) fs.mkdirSync(uploadDir, { recursive: true })

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadDir)
  },
  filename: function (req, file, cb) {
    const unique = Date.now() + '-' + Math.round(Math.random() * 1e9)
    cb(null, unique + path.extname(file.originalname))
  }
})

const maxSize = (parseInt(process.env.MAX_FILE_SIZE_MB || '10', 10)) * 1024 * 1024
const upload = multer({ storage, limits: { fileSize: maxSize } })

const router = Router()
router.use(authRequired)
router.post('/', upload.single('file'), uploadedFile)

export default router