// healthConditionsStats.js - Controller for health conditions statistics
const db = require("../db");

async function getHealthConditions(req, res) {
  try {
    const result = await db.query(
      "SELECT condition_id, name_vi, category, description FROM healthcondition"
    );
    res.json({ healthConditions: result.rows });
  } catch (err) {
    console.error("Error getting health conditions:", err);
    res
      .status(500)
      .json({ error: "Failed to get health conditions", details: err.message });
  }
}

module.exports = { getHealthConditions };
