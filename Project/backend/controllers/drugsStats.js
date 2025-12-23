// drugsStats.js - Controller for drug statistics
const db = require("../db");

async function getDrugs(req, res) {
  try {
    const result = await db.query(
      "SELECT drug_id, name_vi, name_en, generic_name FROM drug"
    );
    res.json({ drugs: result.rows });
  } catch (err) {
    console.error("Error getting drugs:", err);
    res
      .status(500)
      .json({ error: "Failed to get drugs", details: err.message });
  }
}

module.exports = { getDrugs };
