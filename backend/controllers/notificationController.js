import Notification from '../models/Notification.js';

// Send notification to player
export const sendNotification = async (req, res) => {
  try {
    const { playerId, message } = req.body;

    const notification = new Notification({
      senderId: req.user._id,
      receiverId: playerId,
      message,
    });

    await notification.save();
    res.status(201).json({ message: 'Notification sent successfully', notification });
  } catch (err) {
    res.status(500).json({ message: 'Error sending notification', error: err.message });
  }
};
