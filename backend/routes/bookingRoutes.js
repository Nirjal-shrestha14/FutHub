import express from 'express';
import { authenticateToken, checkPlayer, checkFutsalOwner } from '../middleware/authMiddleware.js';
import { 
    createBooking, 
    getBookingsForUser, 
    getBookingDetails,
    getBookingsForOwner,
    updateBookingStatus,
    getAllBookings
} from '../controllers/bookingController.js';

const router = express.Router();

// Create a new booking (Player)
router.post('/', authenticateToken, checkPlayer, createBooking);

// Get all bookings for a user (Player)
router.get('/:userId', authenticateToken, checkPlayer, getBookingsForUser);

// Get booking details (All users)
router.get('/:bookingId', authenticateToken, getBookingDetails);

router.get('/', getAllBookings);

// Get all bookings for a futsal owner
router.get('/owner/:futsalId', authenticateToken, checkFutsalOwner, getBookingsForOwner);

// Update booking status (Futsal Owner)
router.put('/status/:bookingId', authenticateToken, checkFutsalOwner, updateBookingStatus);


export default router;
