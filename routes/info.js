'use strict';

const express = require('express');
const packageJson = require('../package.json');

const router = express.Router();

/**
 * GET /api/info
 * Returns application metadata useful during customer demos.
 */
router.get('/', (_req, res) => {
  res.status(200).json({
    name: packageJson.name,
    version: packageJson.version,
    description: packageJson.description,
    node: process.version,
    platform: process.platform,
    artifactoryRepo: 'demo-npm',
    jfrogPlatform: 'https://mdk96.jfrog.io/',
  });
});

module.exports = router;
