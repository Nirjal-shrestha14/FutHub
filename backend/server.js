import express from "express";
import dotenv from "dotenv";
import cors from "cors";
import connectDB from "./config/db.js"; // Ensure the correct path to your db.js file

// Load environment variables from .env file
dotenv.config();

// Initialize the app
const app = express();

// Middleware
app.use(cors()); // Handle CORS issues
app.use(express.json()); // Parse incoming JSON requests

// Connect to MongoDB
connectDB();

// Import routes
import adminRoutes from "./routes/adminRoutes.js";
import authRoutes from "./routes/authRoutes.js";
import userRoutes from "./routes/userRoutes.js";
import futsalRoutes from "./routes/futsalRoutes.js";
import bookingRoutes from "./routes/bookingRoutes.js";
// Use routes
app.use("/api/admin", adminRoutes);
app.use("/api/auth", authRoutes);
app.use("/api/users", userRoutes);
app.use("/api/futsals", futsalRoutes);
app.use("/api/bookings", bookingRoutes);

// Basic health check route
app.get("/", (req, res) => {
  res.send("Futhub API is up and running!");
});

// Server Port
const PORT = process.env.PORT || 4001;

// Start the server
// app.listen(PORT, () => {
//   console.log(`Server running on port ${PORT}`);
// });
app.listen(PORT, "0.0.0.0", () => {
  console.log(`Server running on port ${PORT}`);
});

