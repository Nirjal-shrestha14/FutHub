//user routes 

import express from 'express';
import { authenticateToken } from '../middleware/authMiddleware.js';
import { getUserDetails, updateUserDetails } from '../controllers/userController.js';
import { changePassword } from '../controllers/authController.js';

const router = express.Router();

// Get user details
router.get('/:userId', authenticateToken, getUserDetails);

// Update user details (for player or futsal owner)
router.put('/:userId', authenticateToken, updateUserDetails);
router.post('/auth/change-password', authenticateToken, changePassword);

export default router;
