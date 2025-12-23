const db = require("../db");

// GET /api/foods - Danh sách thực phẩm
async function getFoods(req, res) {
  try {
    const result = await db.query(
      "SELECT food_id, name_vi, name_en, category, image_url FROM food"
    );
    res.json({ foods: result.rows });
  } catch (err) {
    console.error("Error getting foods:", err);
    res
      .status(500)
      .json({ error: "Failed to get foods", details: err.message });
  }
}

// GET /api/foods/stats - Tổng hợp số lượng thực phẩm
async function getFoodStats(req, res) {
  try {
    const totalFoods = await db.query("SELECT COUNT(*) FROM food");
    const totalCategories = await db.query(
      "SELECT COUNT(DISTINCT category) FROM food"
    );
    res.json({
      totalFoods: parseInt(totalFoods.rows[0].count, 10),
      totalCategories: parseInt(totalCategories.rows[0].count, 10),
    });
  } catch (err) {
    console.error("Error getting food stats:", err);
    res
      .status(500)
      .json({ error: "Failed to get food stats", details: err.message });
  }
}

module.exports = { getFoods, getFoodStats };
