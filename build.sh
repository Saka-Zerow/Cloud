#!/bin/bash
cd /home/deployer/src-frontend
rm -rf .next node_modules
yarn cache clean
yarn install
yarn build
echo "=== SELESAI ==="
