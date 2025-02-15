import User from '../models/User.js';

// Get User Details
export const getUserDetails = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);  // Assuming the user is authenticated and the id is in req.user
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    res.status(200).json(user);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Update User Details
export const updateUserDetails = async (req, res) => {
  const { name, phone, profilePicture } = req.body;

  try {
    const user = await User.findById(req.user.id);  // Assuming the user is authenticated and the id is in req.user
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    if (name) user.name = name;
    if (phone) user.phone = phone;
    if (profilePicture) user.profilePicture = profilePicture;

    user.name = name || user.name;
    user.phone = phone || user.phone;
    user.profilePicture = profilePicture || user.profilePicture;

    await user.save();
    res.status(200).json(user);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
