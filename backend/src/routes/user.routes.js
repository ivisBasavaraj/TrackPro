import { Router } from 'express'
import { listUsers, getUser, updateUserRole, removeUser } from '../controllers/user.controller.js'
import { authRequired, requireRole } from '../middleware/auth.js'

const router = Router()

router.use(authRequired)
router.get('/', requireRole(['admin']), listUsers)
router.get('/:id', requireRole(['admin']), getUser)
router.patch('/:id', requireRole(['admin']), updateUserRole)
router.delete('/:id', requireRole(['admin']), removeUser)

export default router