#!/usr/bin/env node
require("dotenv").config();
const { Pool } = require("pg");
const fs = require("fs");
const path = require("path");

const pool = new Pool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT),
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

// Các file seed data theo thứ tự
const SEED_FILES = [
  // Core nutrients
  "2025_seed_core_vitamins_minerals.sql",
  "2025_seed_vitamins.sql",
  "2025_seed_minerals.sql",
  "2025_seed_vitamin_rda_who_standards.sql",
  "2025_seed_mineral_rda_who_standards.sql",
  "2025_seed_amino_acid_requirements.sql",
  "2025_seed_amino_acid_requirements_by_age.sql",
  "2025_seed_fiber_fatty_rda_standards.sql",
  "2025_seed_app_nutrients.sql",

  // Foods and dishes
  "seed_sample_foods.sql",
  "seed_comprehensive_test_food.sql",
  "2025_seed_vietnamese_dishes.sql",
  "seed_vietnamese_dishes.sql",
  "seed_vietnamese_dishes_v2.sql",
  "2025_seed_20_more_vietnamese_dishes.sql",
  "seed_30_vietnamese_dishes_simple.sql",

  // Drinks
  "2025_seed_drink_templates.sql",
  "2025_seed_drink_ingredients.sql",
  "2025_seed_super_food_drink.sql",

  // Drugs and health conditions
  "2025_seed_drug_medication_data.sql",
  "seed_nutrients_and_conditions.sql",

  // Admin and permissions
  "2025_seed_admin_roles.sql",
  "2025_seed_advanced_features.sql",

  // Data from dataset folder
  "../../../dataset/drugbank_full_real/drug.sql",
  "../../../dataset/drugbank_full_real/healthcondition.sql",
  "../../../dataset/drugbank_full_real/drughealthcondition.sql",
  "../../../dataset/drugbank_full_real/drugnutrientcontraindication.sql",
  "../../../dataset/drugbank_full_real/food.sql",
  "../../../dataset/drugbank_full_real/foodnutrient.sql",
];

async function runSeedFile(fileName) {
  const filePath = path.join(__dirname, "../migrations", fileName);

  if (!fs.existsSync(filePath)) {
    console.log(`   ⊘ Bỏ qua ${fileName} (không tìm thấy)`);
    return { skipped: true };
  }

  try {
    const sql = fs.readFileSync(filePath, "utf8");

    if (sql.trim().length === 0) {
      console.log(`   ⊘ Bỏ qua ${fileName} (file rỗng)`);
      return { skipped: true };
    }

    await pool.query(sql);
    console.log(`   ✓ ${fileName}`);
    return { success: true };
  } catch (err) {
    // Skip if data already exists or conflicts
    if (
      err.code === "23505" || // unique violation
      err.code === "23503" || // foreign key violation
      err.message.includes("duplicate key") ||
      err.message.includes("already exists")
    ) {
      console.log(`   ⊘ ${fileName} (dữ liệu đã tồn tại)`);
      return { skipped: true };
    }

    console.log(`   ✗ ${fileName}`);
    console.log(`      Lỗi: ${err.message.substring(0, 100)}`);
    return { error: err.message };
  }
}

async function seedDatabase() {
  console.log("🌱 Bắt đầu seed dữ liệu mẫu...\n");

  let successCount = 0;
  let skipCount = 0;
  let errorCount = 0;
  const errors = [];

  for (const fileName of SEED_FILES) {
    const result = await runSeedFile(fileName);

    if (result.success) successCount++;
    else if (result.skipped) skipCount++;
    else if (result.error) {
      errorCount++;
      errors.push({ file: fileName, error: result.error });
    }
  }

  console.log(`\n📊 Kết quả:`);
  console.log(`   ✓ Thành công: ${successCount}`);
  console.log(`   ⊘ Bỏ qua: ${skipCount}`);
  console.log(`   ✗ Lỗi: ${errorCount}`);

  if (errors.length > 0 && errors.length <= 10) {
    console.log(`\n⚠️  Chi tiết lỗi:`);
    errors.forEach((e) => {
      console.log(`   - ${e.file}`);
      console.log(`     ${e.error.substring(0, 150)}`);
    });
  }

  if (errorCount === 0) {
    console.log("\n🎉 Seed dữ liệu hoàn tất!");
  } else {
    console.log("\n✓ Seed dữ liệu hoàn tất (một số lỗi có thể bỏ qua)");
  }

  // Show statistics
  console.log("\n📈 Thống kê dữ liệu:");
  try {
    const stats = await Promise.all([
      pool.query("SELECT COUNT(*) as count FROM Food"),
      pool.query("SELECT COUNT(*) as count FROM Nutrient"),
      pool.query("SELECT COUNT(*) as count FROM FoodNutrient"),
      pool.query("SELECT COUNT(*) as count FROM Dish"),
      pool.query("SELECT COUNT(*) as count FROM Drink"),
      pool.query("SELECT COUNT(*) as count FROM Drug"),
      pool.query("SELECT COUNT(*) as count FROM HealthCondition"),
    ]);

    console.log(`   - Food: ${stats[0].rows[0].count} records`);
    console.log(`   - Nutrient: ${stats[1].rows[0].count} records`);
    console.log(`   - FoodNutrient: ${stats[2].rows[0].count} records`);
    console.log(`   - Dish: ${stats[3].rows[0].count} records`);
    console.log(`   - Drink: ${stats[4].rows[0].count} records`);
    console.log(`   - Drug: ${stats[5].rows[0].count} records`);
    console.log(`   - HealthCondition: ${stats[6].rows[0].count} records`);
  } catch (err) {
    console.log("   (Không thể lấy thống kê)");
  }

  pool.end();
}

seedDatabase();
