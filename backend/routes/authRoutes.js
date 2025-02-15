import express from 'express';
import { registerUser, loginUser, logoutUser, logoutAllDevices } from '../controllers/authController.js';
import { authenticateToken } from '../middleware/authMiddleware.js';

const router = express.Router();

// User Registration
router.post('/register', registerUser);

// User Login
router.post('/login', loginUser);

// User Logout (Single Device)
router.post('/logout', authenticateToken, logoutUser);

// User Logout from All Devices
router.post('/logout/all',authenticateToken, logoutAllDevices);

export default router; // Use ES module export
