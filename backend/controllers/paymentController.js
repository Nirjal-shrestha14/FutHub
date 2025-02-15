import Payment from '../models/Payment.js';

// Set futsal pricing
export const setPricing = async (req, res) => {
  try {
    const { futsalId } = req.params;
    const { price } = req.body;

    const futsal = await Futsal.findOneAndUpdate(
      { _id: futsalId, ownerId: req.user._id },
      { price },
      { new: true }
    );

    if (!futsal) return res.status(404).json({ message: 'Futsal not found' });

    res.status(200).json({ message: 'Pricing updated successfully', futsal });
  } catch (err) {
    res.status(500).json({ message: 'Error updating pricing', error: err.message });
  }
};

// View payment history
export const getPaymentHistory = async (req, res) => {
  try {
    const payments = await Payment.find({ ownerId: req.user._id }).populate('playerId', 'name email');
    res.status(200).json({ payments });
  } catch (err) {
    res.status(500).json({ message: 'Error fetching payments', error: err.message });
  }
};
