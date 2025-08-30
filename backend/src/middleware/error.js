export const notFoundHandler = (err, req, res, next) => {
  if (err.status === 404) {
    return res.status(404).json({ message: err.message || 'Not Found' })
  }
  next(err)
}

export const errorHandler = (err, req, res, next) => {
  const status = err.status || 500
  const message = err.message || 'Internal Server Error'
  const details = process.env.NODE_ENV === 'development' ? err.stack : undefined
  res.status(status).json({ message, details })
}