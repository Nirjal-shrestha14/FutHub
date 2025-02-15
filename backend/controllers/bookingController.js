import Booking from '../models/Booking.js';
import Futsal from '../models/Futsal.js';
import User from '../models/User.js';

// Create Booking
export const createBooking = async (req, res) => {
  const { futsalId, bookingDate, timeSlot, paymentMethod, status } = req.body;
  const userId=req.user._id;
  console.log(req.body);

  try {
    // Check if the futsal exists
    const futsalExists = await Futsal.findById(futsalId);
    if (!futsalExists) {
      return res.status(404).json({ message: 'Futsal not found' });
    }

    // Check if the user exists
    const userExists = await User.findById(userId);
    if (!userExists) {
      return res.status(404).json({ message: 'User not found' });
    }
    const existingBooking= await Booking.findOne({futsalId,bookingDate,timeSlot});
    if(existingBooking){
      return res.status(400).json({message:'Booking already exists for this time slot'});
    }


    // Create a new booking in the database
    const booking = await Booking.create({
      futsalId,
      user:userId,
      bookingDate,
      timeSlot,
      paymentMethod,
      status: status || 'pending', // Set to 'pending' if no status is provided
    });

    // Respond with the created booking
    res.status(201).json(booking);
  } catch (err) {
    console.log(err);
    // Handle errors
    res.status(400).json({ message: err.message });
  }
};

// Get Bookings for a Specific User
export const getBookingsForUser = async (req, res) => {
  const { userId } = req.params; // Get userId from the route params

  try {
    // Fetch all bookings for the given user
    const bookings = await Booking.find({ user: userId }).populate('futsal', 'name location')
      .select('bookingDate timeSlot paymentMethod status'); // Adjusted fields to send

    if (bookings.length === 0) {
      return res.status(404).json({ message: 'No bookings found for this user' });
    }

    // Respond with the bookings
    res.status(200).json(bookings);
  } catch (err) {
    // Handle errors
    res.status(500).json({ message: err.message });
  }
};

// Get Booking Details
export const getBookingDetails = async (req, res) => {
  const { bookingId } = req.params; // Get bookingId from the route params

  try {
    // Fetch the booking by ID
    const booking = await Booking.findById(bookingId)
      .populate('futsal', 'name location description')
      .populate('user', 'name email')
      .select('bookingDate timeSlot paymentMethod status'); // Adjusted fields to send

    if (!booking) {
      return res.status(404).json({ message: 'Booking not found' });
    }

    // Respond with the booking details
    res.status(200).json(booking);
  } catch (err) {
    // Handle errors
    res.status(500).json({ message: err.message });
  }
};

// Get Bookings for a Futsal Owner
export const getBookingsForOwner = async (req, res) => {
  const { futsalId } = req.params; // Get futsalId from the route params

  try {
    // Fetch all bookings for the futsal owned by the authenticated owner
    const futsalBookings = await Booking.find({ futsal: futsalId })
      .populate('user', 'name email')
      .populate('futsal', 'name location')
      .select('bookingDate timeSlot paymentMethod status'); // Adjusted fields to send

    if (!futsalBookings || futsalBookings.length === 0) {
      return res.status(404).json({ message: 'No bookings found for this futsal' });
    }

    res.status(200).json(futsalBookings);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Update Booking Status (Approve/Reject/Cancel)
export const updateBookingStatus = async (req, res) => {
  const { bookingId } = req.params;
  const { status } = req.body;

  try {
    // Check if the booking exists
    const booking = await Booking.findById(bookingId);

    if (!booking) {
      return res.status(404).json({ message: 'Booking not found' });
    }

    // Ensure that the futsal in the booking belongs to the authenticated user (futsal owner)
    const futsal = await Futsal.findById(booking.futsal);

    if (futsal.owner.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'You are not authorized to update this booking' });
    }

    // Update the booking status
    booking.status = status;
    await booking.save();

    res.status(200).json({ message: `Booking status updated to ${status}`, booking });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Get All Bookings
export const getAllBookings = async (req, res) => {
  try {
    // Fetch all bookings from the database
    const allBookings = await Booking.find()
      .populate('user', 'name email')  
      .populate('futsalId', 'name location')  // Populate futsal details
      .select('bookingDate timeSlot paymentMethod status');  // Select relevant fields
      console.log(allBookings);

    if (allBookings.length === 0) {
      return res.status(404).json({ message: 'No bookings found' });
    }

    // Respond with the fetched bookings
    res.status(200).json(allBookings);
  } catch (err) {
    // Handle errors
    res.status(500).json({ message: err.message });
  }
};

