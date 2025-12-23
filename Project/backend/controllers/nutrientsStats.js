// nutrientsStats.js - Controller for nutrient statistics
const db = require('../db');

async function getNutrients(req, res) {
  try {
    const result = await db.query('SELECT nutrient_id, name, unit FROM nutrient');
    res.json({ nutrients: result.rows });
  } catch (err) {
    console.error('Error getting nutrients:', err);
    res.status(500).json({ error: 'Failed to get nutrients' });
  }
}

module.exports = { getNutrients };