import Futsal from '../models/Futsal.js';

// -- Futsal Owner --
// Add Futsal
export const addFutsal = async (req, res) => {
  try {
    const { name, location, facilities, price, timeSlots } = req.body;
    const ownerId = req.user._id;
    console.log(req.body);

    const newFutsal = new Futsal({
      owner:ownerId,
      name,
      location,
      facilities,
      price,
      timeSlots
    });

    await newFutsal.save();
    res.status(201).json({ message: 'Futsal added successfully', futsal: newFutsal });
  } catch (err) {
    res.status(500).json({ message: 'Error adding futsal', error: err.message });
  }
};

// Edit futsal details
export const editFutsal = async (req, res) => {
  try {
    const { futsalId } = req.params;
    console.log("Futsal Details:",req.body)
    const updates = req.body;
    const futsal = await Futsal.findOneAndUpdate(
      { _id: futsalId, owner: req.user._id },
      updates,
      { new: true }
    );

    if (!futsal) return res.status(404).json({ message: 'Futsal not found' });

    res.status(200).json({ message: 'Futsal updated successfully', futsal });
  } catch (err) {
    res.status(500).json({ message: 'Error updating futsal', error: err.message });
  }
};

// Delete futsal
export const deleteFutsal = async (req, res) => {
  try {
    const { futsalId } = req.params;
    const futsal = await Futsal.findOneAndDelete({ _id: futsalId, owner: req.user._id });

    if (!futsal) return res.status(404).json({ message: 'Futsal not found' });

    res.status(200).json({ message: 'Futsal deleted successfully' });
  } catch (err) {
    res.status(500).json({ message: 'Error deleting futsal', error: err.message });
  }
};



export const getAllFutsalsByOwner = async (req, res) => {
  try {
    const futsal = await Futsal.find({owner:req.user._id});

    if (!futsal) return res.status(404).json({ message: 'No Futsal Found' });

    res.status(200).json({message:"All Futals",futsals: futsal});
  } catch (err) {
    res.status(500).json({ message: 'Error deleting futsal', error: err.message });
  }
};



// -- Player --
// Get All Futsals
export const getFutsals = async (req, res) => {
  try {
    // Fetch all futsals from the database
    const futsals = await Futsal.find();
    console.log(futsals);
    res.status(200).json(futsals);
  } catch (err) {
    // Handle errors
    res.status(500).json({ message: err.message });
  }
};

// Get Futsal Details
export const getFutsalDetails = async (req, res) => {
  const { futsalId } = req.params;

  try {
    // Find the futsal by its ID
    const futsal = await Futsal.findById(futsalId);

    // If the futsal doesn't exist
    if (!futsal) {
      return res.status(404).json({ message: 'Futsal not found' });
    }

    // Respond with the futsal details
    res.status(200).json(futsal);
  } catch (err) {
    // Handle errors
    res.status(500).json({ message: err.message });
  }
};