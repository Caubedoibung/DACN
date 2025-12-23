// Script tạo superadmin cho bảng admin
const bcrypt = require("bcryptjs");
const { Pool } = require("pg");

const pool = new Pool(); // Sử dụng biến môi trường DB_*

async function createSuperAdmin() {
  const username = "huymt0401@gmail.com";
  const password = "123456";
  const password_hash = await bcrypt.hash(password, 10);
  try {
    await pool.query(
      `INSERT INTO admin (username, password_hash) VALUES ($1, $2) ON CONFLICT (username) DO NOTHING`,
      [username, password_hash]
    );
    console.log("Superadmin đã được tạo hoặc đã tồn tại!");
  } catch (err) {
    console.error("Lỗi khi tạo superadmin:", err);
  } finally {
    await pool.end();
  }
}

createSuperAdmin();
