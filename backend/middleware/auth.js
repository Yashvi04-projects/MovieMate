const jwt = require('jsonwebtoken');

const JWT_SECRET = 'moviemate_qa_secret_key_2026';

function generateToken(user) {
  return jwt.sign(
    { id: user.id, email: user.email, name: user.name },
    JWT_SECRET,
    { expiresIn: '24h' }
  );
}

function authMiddleware(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    console.log('[AUTH] Missing or invalid authorization header');
    return res.status(401).json({
      success: false,
      message: 'Unauthorized - Token required',
    });
  }

  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded;
    next();
  } catch (err) {
    console.log('[AUTH] Invalid token:', err.message);
    return res.status(401).json({
      success: false,
      message: 'Unauthorized - Invalid token',
    });
  }
}

module.exports = { generateToken, authMiddleware, JWT_SECRET };
