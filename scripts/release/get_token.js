#!/usr/bin/env node

const secretPrefix = 'general/sdk-release-bot/github';

const app = require('@mapbox/github-apps');

async function run() {
    const token = await app.token(secretPrefix);
    console.log(token);
};

run();
