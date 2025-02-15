import express from 'express';
import { authenticateToken, checkAdmin } from '../middleware/authMiddleware.js';
import { 
  getAllUsers, getUserById, updateUserRole, deleteUser, 
  getAllBookings, getAllFutsals, deleteFutsal, getFutsalById,
  getAdminAnalytics
} from '../controllers/adminController.js';

const router = express.Router();

router.use(authenticateToken, checkAdmin);

router.get('/users', getAllUsers);
router.get('/users/:userId', getUserById);
router.put('/users/:userId', updateUserRole);
router.delete('/users/:userId', deleteUser);

router.get('/futsals', getAllFutsals);
router.get('/futsals/:futsalId', getFutsalById);
router.delete('/futsals/:futsalId', deleteFutsal);

router.get('/bookings', getAllBookings);
router.get('/analytics', getAdminAnalytics);

export default router;
