import mongoose from 'mongoose';

const BookingSchema = new mongoose.Schema({
  futsalId: {  type: mongoose.Schema.Types.ObjectId, ref: 'Futsal', required: true },  // String for futsal ID (frontend sends a string)
  user: {  type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },  // String for user identifier (frontend sends user info as string)
  bookingDate: { type: Date, required: true },  // Date for the booking (frontend sends selected date)
  timeSlot: { type: String, required: true },  // Time slot for the booking (frontend sends selected time slot)
  paymentMethod: { type: String, enum: ['eSewa', 'Khalti', 'Cash'], required: true },  // Payment method from frontend
  status: { type: String, enum: ['pending', 'confirmed', 'canceled'], default: 'pending' },  // Booking status
});

// Export the Booking model
const Booking = mongoose.model('Booking', BookingSchema);
export default Booking;
