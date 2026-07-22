'use strict';

const express = require('express');
const _ = require('lodash');
const packageJson = require('../package.json');

const router = express.Router();

/**
 * GET /api/info
 * Returns application metadata useful during customer demos.
 */
router.get('/', (_req, res) => {
  // lodash is used here so the (intentionally vulnerable) dependency is exercised
  const info = _.pick(packageJson, ['name', 'version', 'description']);
  res.status(200).json({
    ..._.merge(info, {
      node: process.version,
      platform: process.platform,
      artifactoryRepo: 'demo-npm',
      jfrogPlatform: 'https://mdk96.jfrog.io/',
    }),
  });
});

module.exports = router;
