const os = require('os');
const express = require('express');
const cors = require('cors');
const swaggerUi = require('swagger-ui-express');
const swaggerDocument = require('./swagger/swagger.json');

const authRoutes = require('./routes/auth');
const movieRoutes = require('./routes/movies');
const bookingRoutes = require('./routes/bookings');
const paymentRoutes = require('./routes/payment');
const profileRoutes = require('./routes/profile');

const app = express();
const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || '0.0.0.0';

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  next();
});

app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));

app.get('/', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'MovieMate API Server',
    version: '1.0.0',
    documentation: '/api-docs',
    endpoints: {
      auth: '/api/register, /api/login',
      movies: '/api/movies',
      booking: '/api/booking',
      payment: '/api/payment',
      profile: '/api/profile',
    },
  });
});

app.use('/api', authRoutes);
app.use('/api/movies', movieRoutes);
app.use('/api/booking', bookingRoutes);
app.use('/api/payment', paymentRoutes);
app.use('/api/profile', profileRoutes);

app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found',
  });
});

app.use((err, req, res, next) => {
  console.error('[ERROR]', err.stack);
  res.status(500).json({
    success: false,
    message: 'Internal server error',
  });
});

function getNetworkAddresses() {
  const addresses = [];
  for (const interfaces of Object.values(os.networkInterfaces())) {
    for (const iface of interfaces) {
      if (iface.family === 'IPv4' && !iface.internal) {
        addresses.push(iface.address);
      }
    }
  }
  return addresses;
}

app.listen(PORT, HOST, () => {
  const networkIps = getNetworkAddresses();
  console.log('='.repeat(50));
  console.log('  MovieMate API Server');
  console.log(`  Local:   http://localhost:${PORT}`);
  if (networkIps.length > 0) {
    networkIps.forEach((ip) => {
      console.log(`  Network: http://${ip}:${PORT}`);
    });
  } else {
    console.log(`  Network: http://<YOUR_PC_IP>:${PORT}`);
  }
  console.log(`  Swagger: http://localhost:${PORT}/api-docs`);
  console.log('  Tip: Phone and PC must be on the same Wi-Fi/hotspot');
  console.log('='.repeat(50));
});

module.exports = app;
