import mongoose from 'mongoose';

const NotificationSchema = new mongoose.Schema(
  {
    senderId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    receiverId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    message: { type: String, required: true },
    read: { type: Boolean, default: false }, // Track if the notification has been read by the receiver
    createdAt: { type: Date, default: Date.now }, // Timestamp when notification was created
  },
  {
    timestamps: true, // Adds createdAt and updatedAt fields automatically
  }
);

// Create and export Notification model
const Notification = mongoose.model('Notification', NotificationSchema);
export default Notification;
