const fs = require('fs');
const path = require('path');

const DATA_DIR = path.join(__dirname, '..', 'data');

function readJSON(filename) {
  const filePath = path.join(DATA_DIR, filename);
  try {
    const data = fs.readFileSync(filePath, 'utf8');
    return JSON.parse(data);
  } catch (err) {
    console.error(`[DB] Error reading ${filename}:`, err.message);
    return [];
  }
}

function writeJSON(filename, data) {
  const filePath = path.join(DATA_DIR, filename);
  try {
    fs.writeFileSync(filePath, JSON.stringify(data, null, 2), 'utf8');
    console.log(`[DB] Saved ${filename}`);
    return true;
  } catch (err) {
    console.error(`[DB] Error writing ${filename}:`, err.message);
    return false;
  }
}

module.exports = { readJSON, writeJSON };
