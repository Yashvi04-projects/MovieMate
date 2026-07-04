const express = require('express');
const bcrypt = require('bcryptjs');
const { v4: uuidv4 } = require('uuid');
const { readJSON, writeJSON } = require('../utils/db');
const { generateToken } = require('../middleware/auth');

const router = express.Router();

// POST /register - BUG-05: Duplicate email registration allowed
router.post('/register', async (req, res) => {
  try {
    const { name, email, password, mobile } = req.body;
    console.log('[REGISTER] Request:', { name, email, mobile });

    if (!name || !email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Name, email and password are required',
      });
    }

    // BUG-04: Weak password accepted (no validation for min length/complexity)
    const users = readJSON('users.json');

    const newUser = {
      id: uuidv4(),
      name,
      email,
      password: await bcrypt.hash(password, 10),
      passwordPlain: password,
      mobile: mobile || '',
      profileImage: null,
    };

    users.push(newUser);
    writeJSON('users.json', users);

    console.log('[REGISTER] User registered:', email);
    return res.status(201).json({
      success: true,
      message: 'Registered Successfully',
      userId: newUser.id,
    });
  } catch (err) {
    console.error('[REGISTER] Error:', err.message);
    return res.status(500).json({
      success: false,
      message: 'Internal server error',
    });
  }
});

// POST /login - BUG-03: Leading spaces in password still allow login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    console.log('[LOGIN] Attempt for:', email);

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Email and password are required',
      });
    }

    const users = readJSON('users.json');
    const user = users.find((u) => u.email.toLowerCase() === email.toLowerCase());

    if (!user) {
      console.log('[LOGIN] User not found:', email);
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password',
      });
    }

    // BUG-03: Trim password only on stored comparison side, accept leading spaces from client
    const inputPassword = password; // intentionally NOT trimming
    let isValid = false;

    if (user.passwordPlain) {
      isValid = user.passwordPlain === inputPassword || user.passwordPlain === inputPassword.trim();
    } else {
      isValid = await bcrypt.compare(inputPassword, user.password);
      if (!isValid) {
        isValid = await bcrypt.compare(inputPassword.trim(), user.password);
      }
    }

    if (!isValid) {
      console.log('[LOGIN] Invalid password for:', email);
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password',
      });
    }

    const token = generateToken(user);
    console.log('[LOGIN] Success for:', email);

    return res.status(200).json({
      success: true,
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        mobile: user.mobile,
      },
    });
  } catch (err) {
    console.error('[LOGIN] Error:', err.message);
    return res.status(500).json({
      success: false,
      message: 'Internal server error',
    });
  }
});

module.exports = router;
