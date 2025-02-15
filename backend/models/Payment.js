import mongoose from 'mongoose';

const PaymentSchema = new mongoose.Schema(
  {
    futsalId: { type: mongoose.Schema.Types.ObjectId, ref: 'Futsal', required: true },
    playerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    amount: { type: Number, required: true },
    paymentStatus: { type: String, enum: ['pending', 'completed', 'failed'], default: 'pending' },
    paymentDate: { type: Date, default: Date.now }, // Timestamp for when the payment was made
    ownerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true }, // Futsal owner who receives the payment
  },
  {
    timestamps: true, // Adds createdAt and updatedAt fields automatically
  }
);

// Create and export the Payment model
const Payment = mongoose.model('Payment', PaymentSchema);
export default Payment;
