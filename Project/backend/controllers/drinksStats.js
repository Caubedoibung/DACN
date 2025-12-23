// drinksStats.js - Controller for drink statistics
const db = require("../db");

async function getDrinkCategories(req, res) {
  try {
    const result = await db.query("SELECT DISTINCT category FROM drink");
    res.json({ categories: result.rows.map((r) => r.category) });
  } catch (err) {
    console.error("Error getting drink categories:", err);
    res.status(500).json({ error: "Failed to get drink categories" });
  }
}

// Thêm hàm trả về danh sách đồ uống
async function getDrinks(req, res) {
  try {
    const result = await db.query("SELECT drink_id, name, category FROM drink");
    res.json({ drinks: result.rows });
  } catch (err) {
    console.error("Error getting drinks:", err);
    res.status(500).json({ error: "Failed to get drinks" });
  }
}

module.exports = { getDrinkCategories, getDrinks };
