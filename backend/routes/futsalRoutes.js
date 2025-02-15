import express from 'express';
import { authenticateToken, checkFutsalOwner, checkPlayer } from '../middleware/authMiddleware.js';
import { addFutsal, editFutsal, deleteFutsal, getFutsals, getFutsalDetails, getAllFutsalsByOwner } from '../controllers/futsalController.js';

const router = express.Router();

// Add a futsal (Futsal Owner)
router.post('/add', authenticateToken, checkFutsalOwner, addFutsal);
router.put('/edit/:futsalId', authenticateToken, checkFutsalOwner, editFutsal);
router.delete('/delete/:futsalId', authenticateToken, checkFutsalOwner, deleteFutsal);
router.get('/view-futsal', authenticateToken, checkFutsalOwner, getAllFutsalsByOwner);

// View all futsals (For Player)
router.get('/view', authenticateToken, checkPlayer, getFutsals);

// Get futsal details by ID
router.get('/:futsalId', authenticateToken, getFutsalDetails);

export default router;
