import express from 'express';
import { authenticateToken, checkFutsalOwner } from '../middleware/authMiddleware.js';
import { setPricing, getPaymentHistory } from '../controllers/paymentController.js';

const router = express.Router();

router.put('/pricing/:futsalId', authenticateToken, checkFutsalOwner, setPricing);
router.get('/history', authenticateToken, checkFutsalOwner, getPaymentHistory);

export default router;
