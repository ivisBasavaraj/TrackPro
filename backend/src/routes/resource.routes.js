import { Router } from 'express'
import { authRequired } from '../middleware/auth.js'
import { createResource, listResources, getResource, updateResource, deleteResource } from '../controllers/resource.controller.js'

const router = Router()

router.use(authRequired)
router.post('/', createResource)
router.get('/', listResources)
router.get('/:id', getResource)
router.patch('/:id', updateResource)
router.delete('/:id', deleteResource)

export default router