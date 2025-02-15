import mongoose from 'mongoose';

const futsalSchema = new mongoose.Schema({
  owner: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true }, // Owner ID
  name: { type: String, required: true },
  location: { type: String, required: true },
  price: { type: Number, required: true },
  facilities: { type: [String], default: [] }, // e.g., ['Parking', 'Changing Rooms']
  timeSlots: { type: [String], required: true }, // e.g., ['8:00-9:00', '9:00-10:00']
  createdAt: { type: Date, default: Date.now },
  approvalStatus: { type: String, enum: ['pending', 'approved', 'rejected'], default: 'pending' }, // Added for approval
});

const Futsal = mongoose.model('Futsal', futsalSchema);
export default Futsal;
