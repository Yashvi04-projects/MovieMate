const express = require('express');
const { v4: uuidv4 } = require('uuid');
const { readJSON, writeJSON } = require('../utils/db');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

// POST /booking - BUG-11: Same seat can be booked multiple times
router.post('/', authMiddleware, (req, res) => {
  try {
    const { userId, movieId, seat, seats, amount } = req.body;
    console.log('[BOOKING] Request:', { userId, movieId, seat, seats });

    if (!userId || !movieId || (!seat && !seats)) {
      return res.status(400).json({
        success: false,
        message: 'userId, movieId and seat(s) are required',
      });
    }

    const seatList = seats || [seat];
    const movies = readJSON('movies.json');
    const movie = movies.find((m) => m.id === movieId);

    if (!movie) {
      return res.status(404).json({
        success: false,
        message: 'Movie not found',
      });
    }

    // BUG-11: No check for already booked seats
    const bookings = readJSON('bookings.json');
    const bookedSeats = readJSON('bookedSeats.json');

    seatList.forEach((s) => {
      bookedSeats.push({
        movieId,
        seat: s,
        userId,
        bookedAt: new Date().toISOString(),
      });
    });

    const newBooking = {
      id: uuidv4(),
      userId,
      movieId,
      movieName: movie.name,
      seats: seatList,
      amount: amount || seatList.length * 250,
      status: 'confirmed',
      bookingDate: new Date().toISOString(),
    };

    bookings.push(newBooking);
    writeJSON('bookings.json', bookings);
    writeJSON('bookedSeats.json', bookedSeats);

    console.log('[BOOKING] Created:', newBooking.id);
    return res.status(201).json({
      success: true,
      message: 'Booking confirmed',
      data: newBooking,
    });
  } catch (err) {
    console.error('[BOOKING] Error:', err.message);
    return res.status(500).json({
      success: false,
      message: 'Internal server error',
    });
  }
});

// GET /booking/user/:userId - BUG-18: Latest booking sometimes missing
router.get('/user/:userId', authMiddleware, (req, res) => {
  try {
    const bookings = readJSON('bookings.json');
    let userBookings = bookings.filter((b) => b.userId === req.params.userId);

    // BUG-18: Randomly skip the latest booking ~30% of the time
    if (userBookings.length > 1 && Math.random() < 0.3) {
      userBookings = userBookings.slice(0, -1);
      console.log('[BOOKING] BUG-18 triggered: latest booking omitted');
    }

    userBookings.sort(
      (a, b) => new Date(b.bookingDate) - new Date(a.bookingDate)
    );

    console.log('[BOOKING] Returning', userBookings.length, 'bookings for user', req.params.userId);
    return res.status(200).json({
      success: true,
      count: userBookings.length,
      data: userBookings,
    });
  } catch (err) {
    console.error('[BOOKING] Error:', err.message);
    return res.status(500).json({
      success: false,
      message: 'Internal server error',
    });
  }
});

// GET /booking/:id
router.get('/:id', authMiddleware, (req, res) => {
  try {
    const bookings = readJSON('bookings.json');
    const booking = bookings.find((b) => b.id === req.params.id);

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: 'Booking not found',
      });
    }

    return res.status(200).json({
      success: true,
      data: booking,
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

// DELETE /booking/:id
router.delete('/:id', authMiddleware, (req, res) => {
  try {
    const bookings = readJSON('bookings.json');
    const index = bookings.findIndex((b) => b.id === req.params.id);

    if (index === -1) {
      return res.status(404).json({ success: false, message: 'Booking not found' });
    }

    const deleted = bookings.splice(index, 1);
    writeJSON('bookings.json', bookings);

    return res.status(200).json({
      success: true,
      message: 'Booking cancelled',
      data: deleted[0],
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

module.exports = router;
