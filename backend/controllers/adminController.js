import User from '../models/User.js';
import Booking from '../models/Booking.js';
import Futsal from '../models/Futsal.js';
// import bcrypt from 'bcryptjs'; // For password hashing

// -- USERS --

// Get all users (Players and Futsal Owners)
export const getAllUsers = async (req, res) => {
  try {
    const players = await User.find({ role: 'player' }, '-password');  // Exclude password
    const owners = await User.find({ role: 'futsal_owner' }, '-password');
    res.status(200).json({ players, owners });
  } catch (err) {
    res.status(500).json({ message: 'Error fetching users', error: err.message });
  }
};

// Get user details by ID
export const getUserById = async (req, res) => {
  const { userId } = req.params;
  try {
    const user = await User.findById(userId, '-password');
    if (!user) return res.status(404).json({ message: 'User not found' });
    
    res.status(200).json(user);
  } catch (err) {
    res.status(500).json({ message: 'Error fetching user', error: err.message });
  }
};

// Update user role (Admin can change roles)
export const updateUserRole = async (req, res) => {
  const { userId } = req.params;
  const { role } = req.body;

  if (!['player', 'futsal_owner'].includes(role)) {
    return res.status(400).json({ message: 'Invalid role' });
  }

  try {
    const updatedUser = await User.findByIdAndUpdate(userId, { role }, { new: true });
    if (!updatedUser) return res.status(404).json({ message: 'User not found' });

    res.status(200).json({ message: 'User role updated successfully', updatedUser });
  } catch (err) {
    res.status(500).json({ message: 'Error updating user role', error: err.message });
  }
};

// Lock a user
export const lockUser = async (req, res) => {
  const { userId } = req.params;
  try {
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    user.locked = true;
    await user.save();
    res.status(200).json({ message: 'User locked successfully' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Unlock a user
export const unlockUser = async (req, res) => {
  const { userId } = req.params;
  try {
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    user.locked = false;
    await user.save();
    res.status(200).json({ message: 'User unlocked successfully' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Reset user password
export const resetPassword = async (req, res) => {
  const { userId } = req.params;
  const { newPassword } = req.body;
  try {
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);
    user.password = hashedPassword;
    await user.save();
    res.status(200).json({ message: 'Password reset successfully' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Ban a user
export const banUser = async (req, res) => {
  const { userId } = req.params;
  try {
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    user.banned = true;
    await user.save();
    res.status(200).json({ message: 'User banned successfully' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Unban a user
export const unbanUser = async (req, res) => {
  const { userId } = req.params;
  try {
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    user.banned = false;
    await user.save();
    res.status(200).json({ message: 'User unbanned successfully' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Delete a user
export const deleteUser = async (req, res) => {
  try {
    const { userId } = req.params;
    const deletedUser = await User.findByIdAndDelete(userId);
    if (!deletedUser) return res.status(404).json({ message: 'User not found' });

    res.status(200).json({ message: 'User deleted successfully', deletedUser });
  } catch (err) {
    res.status(500).json({ message: 'Error deleting user', error: err.message });
  }
};

// -- FUTSALS --

// Get all futsals
export const getAllFutsals = async (req, res) => {
  try {
    const futsals = await Futsal.find().populate('owner', 'name email'); // Populate owner details
    res.status(200).json(futsals);
  } catch (err) {
    res.status(500).json({ message: 'Error fetching futsals', error: err.message });
  }
};

// Get futsal details by ID
export const getFutsalById = async (req, res) => {
  const { futsalId } = req.params;

  try {
    const futsals = await Futsal.findById(futsalId).populate('owner', 'name email');
    if (!futsals) return res.status(404).json({ message: 'Futsal not found' });

    res.status(200).json(futsals);
  } catch (err) {
    res.status(500).json({ message: 'Error fetching futsal details', error: err.message });
  }
};

// Delete a futsal
export const deleteFutsal = async (req, res) => {
  const { futsalId } = req.params;

  try {
    const deletedFutsal = await Futsal.findByIdAndDelete(futsalId);
    if (!deletedFutsal) return res.status(404).json({ message: 'Futsal not found' });

    res.status(200).json({ message: 'Futsal deleted successfully', deletedFutsal });
  } catch (err) {
    res.status(500).json({ message: 'Error deleting futsal', error: err.message });
  }
};

// -- BOOKINGS --

// Get all bookings
export const getAllBookings = async (req, res) => {
  try {
    const bookings = await Booking.find().populate('user', 'name email').populate('futsal', 'name location');
    res.status(200).json(bookings);
  } catch (err) {
    res.status(500).json({ message: 'Error fetching bookings', error: err.message });
  }
};

// -- Admin Analytics & Reports --
export const getAdminAnalytics = async (req, res) => {
  try {
    // Count total users
    const totalPlayers = await User.countDocuments({ role: 'player' });
    const totalOwners = await User.countDocuments({ role: 'futsal_owner' });

    // Count total futsals
    const totalFutsals = await Futsal.countDocuments();

    // Count total bookings
    const totalBookings = await Booking.countDocuments();

    // Calculate total revenue from bookings
    const revenueData = await Booking.aggregate([
      { 
        $lookup: {
          from: 'futsals',
          localField: 'futsal',
          foreignField: '_id',
          as: 'futsalDetails'
        }
      },
      { $unwind: '$futsalDetails' },
      { 
        $group: { 
          _id: null, 
          totalRevenue: { $sum: '$futsalDetails.price' } 
        }
      }
    ]);
    const totalRevenue = revenueData.length > 0 ? revenueData[0].totalRevenue : 0;

    // Get user growth over time (last 7 days)
    const userGrowth = await User.aggregate([
      { 
        $match: { createdAt: { $gte: new Date(new Date().setDate(new Date().getDate() - 7)) } }
      },
      { 
        $group: { 
          _id: { $dateToString: { format: "%Y-%m-%d", date: "$createdAt" } }, 
          count: { $sum: 1 }
        }
      },
      { $sort: { _id: 1 } }
    ]);

    // Get top 5 most booked futsals
    const topFutsals = await Booking.aggregate([
      { 
        $group: { 
          _id: '$futsal', 
          totalBookings: { $sum: 1 }
        }
      },
      { $sort: { totalBookings: -1 } },
      { $limit: 5 },
      { 
        $lookup: {
          from: 'futsals',
          localField: '_id',
          foreignField: '_id',
          as: 'futsalDetails'
        }
      },
      { $unwind: '$futsalDetails' },
      { 
        $project: { 
          futsalName: '$futsalDetails.name', 
          totalBookings: 1
        }
      }
    ]);

    res.status(200).json({
      totalPlayers,
      totalOwners,
      totalFutsals,
      totalBookings,
      totalRevenue,
      userGrowth,
      topFutsals
    });

  } catch (err) {
    res.status(500).json({ message: 'Error fetching analytics', error: err.message });
  }
};

// Approve a futsal
export const approveFutsal = async (req, res) => {
  const { futsalId } = req.params;
  try {
    const futsals = await Futsal.findById(futsalId);
    if (!futsals) {
      return res.status(404).json({ message: 'Futsal not found' });
    }

    futsals.approvalStatus = 'approved';
    await futsals.save();
    res.status(200).json({ message: 'Futsal approved successfully' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Reject a futsal
export const rejectFutsal = async (req, res) => {
  const { futsalId } = req.params;
  try {
    const futsals = await Futsal.findById(futsalId);
    if (!futsals) {
      return res.status(404).json({ message: 'Futsal not found' });
    }

    futsals.approvalStatus = 'rejected';
    await futsals.save();
    res.status(200).json({ message: 'Futsal rejected' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};


