'use strict';

/**
 * JFrog + Azure DevOps demo application.
 *
 * A minimal Express.js API used to demonstrate:
 *  - Resolving npm dependencies through Artifactory (demo-npm)
 *  - Collecting and publishing build info
 *  - Scanning the build with Xray
 */

const express = require('express');
const morgan = require('morgan');
const healthRouter = require('./routes/health');
const infoRouter = require('./routes/info');

const app = express();
const PORT = Number(process.env.PORT) || 3000;

// Request logging (useful when validating the app locally during demos)
app.use(morgan('dev'));
app.use(express.json());

// REST routes
app.use('/health', healthRouter);
app.use('/api/info', infoRouter);

// Root welcome endpoint
app.get('/', (_req, res) => {
  res.json({
    message: 'JFrog Azure DevOps Pipeline Integration Demo',
    endpoints: {
      health: '/health',
      info: '/api/info',
    },
  });
});

// 404 handler
app.use((_req, res) => {
  res.status(404).json({ error: 'Not Found' });
});

// Centralized error handler
app.use((err, _req, res, _next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ error: 'Internal Server Error' });
});

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Demo app listening on http://localhost:${PORT}`);
  });
}

module.exports = app;
