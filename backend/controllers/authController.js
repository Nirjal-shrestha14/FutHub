import jwt from 'jsonwebtoken';
import bcrypt from 'bcrypt';
import User from '../models/User.js';

// 🔹 Register a user
export const registerUser = async (req, res) => {
  const { name, email, password, role, phone, profilePicture } = req.body;

  if (!name || !email || !password || !role || !phone) {
    return res.status(400).json({ message: 'All fields are required' });
  }

  try {
    // Check if email is already registered
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(409).json({ message: 'Email is already registered' }); // 409 Conflict
    }

    // Hash the password before saving
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create and save user
    const newUser = new User({
      name,
      email,
      password: hashedPassword,
      role,
      phone,
      profilePicture,
    });

    await newUser.save();

    res.status(201).json({
      message: 'User registered successfully',
      user: {
        id: newUser._id,
        name: newUser.name,
        email: newUser.email,
        role: newUser.role,
        phone: newUser.phone,
        profilePicture: newUser.profilePicture,
      },
    });
  } catch (err) {
    console.error('Registration error:', err);
    res.status(500).json({ message: 'Server error, try again later' });
  }
};

// 🔹 Login a user
export const loginUser = async (req, res) => {
  const { email, password } = req.body;

  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    // Generate JWT token
    const token = jwt.sign({ id: user._id, role: user.role }, process.env.JWT_SECRET, { expiresIn: '1d' });

    // Prevent duplicate tokens
    if (!user.tokens.includes(token)) {
      user.tokens.push(token);
      await user.save();
    }

    res.status(200).json({
      message: 'Login successful',
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
        phone: user.phone,
        profilePicture: user.profilePicture,
      },
    });
  } catch (err) {
    console.error('Login error:', err);
    res.status(500).json({ message: 'Server error, try again later' });
  }
};

// 🔹 Logout from current device
export const logoutUser = async (req, res) => {
  try {
    if (!req.token || !req.user) {
      return res.status(401).json({ message: 'Unauthorized' });
    }

    // Remove only the current token
    req.user.tokens = req.user.tokens.filter(t => t !== req.token);
    await req.user.save();

    res.status(200).json({ message: 'Logout successful' });
  } catch (err) {
    console.error('Logout error:', err);
    res.status(500).json({ message: 'Error logging out' });
  }
};

// 🔹 Logout from all devices
export const logoutAllDevices = async (req, res) => {
  try {
    if (!req.user) {
      return res.status(401).json({ message: 'Unauthorized' });
    }

    req.user.tokens = []; // Clear all tokens
    await req.user.save();

    res.status(200).json({ message: 'Logged out from all devices' });
  } catch (err) {
    console.error('Logout all error:', err);
    res.status(500).json({ message: 'Error logging out from all devices' });
  }
};

export const changePassword = async (req, res) => {
  try {
    const { oldPassword, newPassword } = req.body;

    // Add password strength validation
    if (newPassword.length < 8) {
      return res.status(400).json({ 
        message: 'New password must be at least 8 characters long' 
      });
    }

    // if (!/[A-Z]/.test(newPassword)) {
    //   return res.status(400).json({ 
    //     message: 'New password must contain at least one uppercase letter' 
    //   });
    // }

    // if (!/[0-9]/.test(newPassword)) {
    //   return res.status(400).json({ 
    //     message: 'New password must contain at least one number' 
    //   });
    // }

    const user = await User.findById(req.user.id);
    
    // Verify old password
    const isMatch = await bcrypt.compare(oldPassword, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Current password is incorrect' });
    }
    
    // Hash new password
    const hashedPassword = await bcrypt.hash(newPassword, 10);
    user.password = hashedPassword;
    
    // Optionally invalidate all existing tokens
    user.tokens = [];
    
    await user.save();
    
    res.status(200).json({ message: 'Password updated successfully' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
