import cors from 'cors'

// Build a flexible CORS configuration from env
export const buildCors = () => {
  const raw = process.env.CORS_ORIGIN?.trim()

  // Allow all if not set or set to '*'
  if (!raw || raw === '*' ) {
    return cors({ origin: true, credentials: true })
  }

  // Support multiple comma-separated origins
  const whitelist = raw.split(',').map(s => s.trim()).filter(Boolean)

  const isAllowed = (origin) => {
    if (!origin) return true // allow same-origin/non-browser clients
    return whitelist.includes(origin)
  }

  return cors({
    origin(origin, callback) {
      if (isAllowed(origin)) return callback(null, true)
      return callback(new Error('Not allowed by CORS'))
    },
    credentials: true,
    allowedHeaders: ['Content-Type', 'Authorization'],
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    exposedHeaders: ['Content-Length']
  })
}