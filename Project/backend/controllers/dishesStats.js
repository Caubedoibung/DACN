// dishesStats.js - Controller for dish statistics
const db = require("../db");

async function getDishCategories(req, res) {
  try {
    const result = await db.query("SELECT DISTINCT category FROM dish");
    res.json({ categories: result.rows.map((r) => r.category) });
  } catch (err) {
    console.error("Error getting dish categories:", err);
    res
      .status(500)
      .json({ error: "Failed to get dish categories", details: err.message });
  }
}

module.exports = { getDishCategories };
