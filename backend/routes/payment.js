const express = require('express');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

// POST /payment - accepts any card/UPI (validation bugs are on frontend)
router.post('/', authMiddleware, (req, res) => {
  try {
    const { amount, method, cardNumber, cvv, upiId, bookingId } = req.body;
    console.log('[PAYMENT] Request:', { amount, method, bookingId });

    if (!amount) {
      return res.status(400).json({
        success: false,
        message: 'Amount is required',
      });
    }

    if (amount <= 0) {
      return res.status(400).json({
        success: false,
        message: 'Invalid amount',
      });
    }

    // Simulate processing delay for BUG-15 testing
    const transactionId = 'TXN' + Date.now();

    console.log('[PAYMENT] Success:', transactionId);
    return res.status(200).json({
      success: true,
      message: 'Payment successful',
      transactionId,
      amount,
      method: method || 'unknown',
    });
  } catch (err) {
    console.error('[PAYMENT] Error:', err.message);
    return res.status(500).json({
      success: false,
      message: 'Payment failed - Internal server error',
    });
  }
});

module.exports = router;
