import jwt from 'jsonwebtoken';
import User from '../models/User.js';

// Middleware to authenticate the token
export const authenticateToken = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', ''); // Extract token
    if (!token) {
      return res.status(401).json({ message: 'Access denied. No token provided.' });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET); // Verify token
    const user = await User.findById(decoded.id);

    if (!user || !user.tokens.includes(token)) {
      return res.status(401).json({ message: 'Invalid or expired token. Please log in again.' });
    }

    req.user = user; // Attach user data
    req.token = token;
    next();
  } catch (err) {
    console.error('Token verification failed:', err.message);
    return res.status(401).json({ message: 'Invalid or expired token.' });
  }
};

// Middleware to store token when user logs in
export const storeToken = async (userId, token) => {
  try {
    const user = await User.findById(userId);
    if (user) {
      user.tokens.push(token); // Store active token
      await user.save();
    }
  } catch (err) {
    console.error('Error storing token:', err.message);
  }
};

// Middleware to logout user (removes token)
export const logoutUser = async (req, res) => {
  try {
    req.user.tokens = req.user.tokens.filter(t => t !== req.token); // Remove token
    await req.user.save();
    res.status(200).json({ message: 'Logout successful' });
  } catch (err) {
    console.error('Logout failed:', err.message);
    res.status(500).json({ message: 'Error logging out' });
  }
};

// Generalized Middleware to check if authenticated user has required role
export const authorizeRole = (...roles) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ message: `Access forbidden. Required roles: ${roles.join(', ')}` });
    }
    next();
  };
};

// Middleware to check if the authenticated user is a futsal owner
export const checkFutsalOwner = (req, res, next) => {
  try {
    if (req.user.role !== 'futsal_owner') {
      return res.status(403).json({ message: 'Access forbidden. Only futsal owners can perform this action.' });
    }
    next();
  } catch (err) {
    console.error('Role check for futsal owner failed:', err.message);
    return res.status(500).json({ message: 'An error occurred while checking permissions.' });
  }
};

// Middleware to check if the authenticated user is an admin
export const checkAdmin = (req, res, next) => {
  try {
    if (req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Access forbidden. Only admins can perform this action.' });
    }
    next();
  } catch (err) {
    console.error('Role check for admin failed:', err.message);
    return res.status(500).json({ message: 'An error occurred while checking permissions.' });
  }
};

// Middleware to check if the authenticated user is a player
export const checkPlayer = (req, res, next) => {
  try {
    if (req.user.role !== 'player') {
      return res.status(403).json({ message: 'Access forbidden. Only players can perform this action.' });
    }
    next();
  } catch (err) {
    console.error('Role check for player failed:', err.message);
    return res.status(500).json({ message: 'An error occurred while checking permissions.' });
  }
};
