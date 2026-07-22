'use strict';

const express = require('express');

const router = express.Router();

/**
 * GET /health
 * Liveness probe used by demos and local verification.
 */
router.get('/', (_req, res) => {
  res.status(200).json({
    status: 'ok',
    service: 'jfrog-azure-devops-demo',
    timestamp: new Date().toISOString(),
  });
});

module.exports = router;
