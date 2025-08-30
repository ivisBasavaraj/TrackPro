import dotenv from 'dotenv'
import path from 'path'
import express from 'express'
import helmet from 'helmet'
import morgan from 'morgan'
import cookieParser from 'cookie-parser'
import createError from 'http-errors'
import { fileURLToPath } from 'url'

import { connectDB } from './config/db.js'
import authRoutes from './routes/auth.routes.js'
import userRoutes from './routes/user.routes.js'
import resourceRoutes from './routes/resource.routes.js'
import uploadRoutes from './routes/upload.routes.js'
import adminRoutes from './routes/admin.routes.js'
import { errorHandler, notFoundHandler } from './middleware/error.js'
import { buildCors } from './utils/cors.js'

// Setup env
dotenv.config()

// Paths
const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

// Connect DB
await connectDB()

const app = express()

// Security & Basic Middleware
app.use(helmet())
app.use(morgan(process.env.NODE_ENV === 'production' ? 'combined' : 'dev'))
app.use(express.json({ limit: '1mb' }))
app.use(express.urlencoded({ extended: true }))
app.use(cookieParser())

// CORS
app.use(buildCors())

// Static uploads
app.use('/uploads', express.static(path.join(__dirname, '../uploads')))

// Routes
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', time: new Date().toISOString() })
})
app.use('/api/auth', authRoutes)
app.use('/api/users', userRoutes)
app.use('/api/resource', resourceRoutes)
app.use('/api/upload', uploadRoutes)
app.use('/api/admin', adminRoutes)

// 404 handler
app.use((req, res, next) => {
  next(createError(404, 'Not Found'))
})

// Error handler
app.use(notFoundHandler)
app.use(errorHandler)

export default app