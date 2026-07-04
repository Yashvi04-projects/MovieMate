const express = require('express');
const { readJSON, writeJSON } = require('../utils/db');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

// GET /profile
router.get('/', authMiddleware, (req, res) => {
  try {
    const users = readJSON('users.json');
    const user = users.find((u) => u.id === req.user.id);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    console.log('[PROFILE] Returning profile for:', user.email);
    return res.status(200).json({
      success: true,
      data: {
        id: user.id,
        name: user.name,
        email: user.email,
        mobile: user.mobile,
        profileImage: user.profileImage,
      },
    });
  } catch (err) {
    console.error('[PROFILE] Error:', err.message);
    return res.status(500).json({
      success: false,
      message: 'Internal server error',
    });
  }
});

// PUT /profile
router.put('/', authMiddleware, (req, res) => {
  try {
    const { name, email, mobile, profileImage } = req.body;
    const users = readJSON('users.json');
    const index = users.findIndex((u) => u.id === req.user.id);

    if (index === -1) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    if (name) users[index].name = name;
    if (email) users[index].email = email;
    if (mobile) users[index].mobile = mobile;
    if (profileImage !== undefined) users[index].profileImage = profileImage;

    writeJSON('users.json', users);

    console.log('[PROFILE] Updated for:', users[index].email);
    return res.status(200).json({
      success: true,
      message: 'Profile updated successfully',
      data: {
        id: users[index].id,
        name: users[index].name,
        email: users[index].email,
        mobile: users[index].mobile,
        profileImage: users[index].profileImage,
      },
    });
  } catch (err) {
    console.error('[PROFILE] Error:', err.message);
    return res.status(500).json({
      success: false,
      message: 'Internal server error',
    });
  }
});

// DELETE /profile - for Postman testing
router.delete('/', authMiddleware, (req, res) => {
  try {
    const users = readJSON('users.json');
    const index = users.findIndex((u) => u.id === req.user.id);

    if (index === -1) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const deleted = users.splice(index, 1);
    writeJSON('users.json', users);

    return res.status(200).json({
      success: true,
      message: 'Account deleted',
      data: { id: deleted[0].id, email: deleted[0].email },
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

module.exports = router;
