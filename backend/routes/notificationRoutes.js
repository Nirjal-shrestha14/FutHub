import express from 'express';
import { authenticateToken, checkFutsalOwner } from '../middleware/authMiddleware.js';
import { sendNotification } from '../controllers/notificationController.js';

const router = express.Router();

router.post('/send', authenticateToken, checkFutsalOwner, sendNotification);

export default router;
