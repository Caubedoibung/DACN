const db = require('../db');
const axios = require('axios');
const fs = require('fs');
const path = require('path');
const FormData = require('form-data');

// Base URL của ChatbotAPI (Python FastAPI)
const CHATBOT_API_URL = process.env.CHATBOT_API_URL || 'http://localhost:8000';

/**
 * POST /api/ai-analyze-image
 * Phân tích hình ảnh thức ăn/đồ uống bằng Gemini Vision AI
 * 
 * Body:
 * - image: file upload (multipart/form-data)
 * 
 * Response:
 * {
 *   success: true,
 *   items: [
 *     {
 *       item_name: "Phở Bò",
 *       item_type: "food",
 *       confidence_score: 92.5,
 *       estimated_volume_ml: 500,
 *       estimated_weight_g: 600,
 *       water_ml: 400,
 *       nutrients: { enerc_kcal: 350, procnt: 25, ... },
 *       image_path: "uploads/ai_analysis/xxx.jpg"
 *     }
 *   ]
 * }
 */
async function analyzeImage(req, res) {
  const user = req.user;
  if (!user) return res.status(401).json({ error: 'Unauthorized' });

  try {
    // 1. Kiểm tra file upload
    if (!req.file) {
      return res.status(400).json({ error: 'Không có hình ảnh được gửi lên' });
    }

    const imagePath = req.file.path; // Đường dẫn file đã upload (multer)
    
    // 2. Gửi ảnh đến ChatbotAPI để phân tích
    const formData = new FormData();
    formData.append('file', fs.createReadStream(imagePath));
    
    const response = await axios.post(`${CHATBOT_API_URL}/analyze-image`, formData, {
      headers: formData.getHeaders(),
      timeout: 30000, // 30s timeout
    });

    const aiResult = response.data;

    // 3. Lưu từng món vào database (chưa chấp nhận - accepted=false)
    const savedItems = [];
    
    for (const item of aiResult.items) {
      const result = await db.query(
        `INSERT INTO AI_Analyzed_Meals (
          user_id, image_path, item_name, item_type, confidence_score,
          estimated_volume_ml, estimated_weight_g, water_ml,
          enerc_kcal, procnt, fat, chocdf,
          fibtg, fib_sol, fib_insol, fib_rs, fib_bglu,
          cholesterol,
          vita, vitd, vite, vitk, vitc, vitb1, vitb2, vitb3, vitb5, vitb6, vitb7, vitb9, vitb12,
          ca, p, mg, k, na, fe, zn, cu, mn, i, se, cr, mo, f,
          fams, fapu, fasat, fatrn, faepa, fadha, faepa_dha, fa18_2n6c, fa18_3n3,
          amino_his, amino_ile, amino_leu, amino_lys, amino_met, amino_phe, amino_thr, amino_trp, amino_val,
          ala, epa_dha, la,
          accepted, raw_ai_response
        ) VALUES (
          $1, $2, $3, $4, $5, $6, $7, $8,
          $9, $10, $11, $12,
          $13, $14, $15, $16, $17,
          $18,
          $19, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $30, $31,
          $32, $33, $34, $35, $36, $37, $38, $39, $40, $41, $42, $43, $44, $45,
          $46, $47, $48, $49, $50, $51, $52, $53, $54,
          $55, $56, $57, $58, $59, $60, $61, $62, $63,
          $64, $65, $66,
          $67, $68
        ) RETURNING id`,
        [
          user.user_id,
          req.file.path.replace(/\\/g, '/'), // Normalize path
          item.item_name,
          item.item_type,
          item.confidence_score || 0,
          item.estimated_volume_ml || 0,
          item.estimated_weight_g || 0,
          item.water_ml || 0,
          // Nutrients (76)
          item.nutrients.enerc_kcal || 0,
          item.nutrients.procnt || 0,
          item.nutrients.fat || 0,
          item.nutrients.chocdf || 0,
          item.nutrients.fibtg || 0,
          item.nutrients.fib_sol || 0,
          item.nutrients.fib_insol || 0,
          item.nutrients.fib_rs || 0,
          item.nutrients.fib_bglu || 0,
          item.nutrients.cholesterol || 0,
          item.nutrients.vita || 0,
          item.nutrients.vitd || 0,
          item.nutrients.vite || 0,
          item.nutrients.vitk || 0,
          item.nutrients.vitc || 0,
          item.nutrients.vitb1 || 0,
          item.nutrients.vitb2 || 0,
          item.nutrients.vitb3 || 0,
          item.nutrients.vitb5 || 0,
          item.nutrients.vitb6 || 0,
          item.nutrients.vitb7 || 0,
          item.nutrients.vitb9 || 0,
          item.nutrients.vitb12 || 0,
          item.nutrients.ca || 0,
          item.nutrients.p || 0,
          item.nutrients.mg || 0,
          item.nutrients.k || 0,
          item.nutrients.na || 0,
          item.nutrients.fe || 0,
          item.nutrients.zn || 0,
          item.nutrients.cu || 0,
          item.nutrients.mn || 0,
          item.nutrients.i || 0,
          item.nutrients.se || 0,
          item.nutrients.cr || 0,
          item.nutrients.mo || 0,
          item.nutrients.f || 0,
          item.nutrients.fams || 0,
          item.nutrients.fapu || 0,
          item.nutrients.fasat || 0,
          item.nutrients.fatrn || 0,
          item.nutrients.faepa || 0,
          item.nutrients.fadha || 0,
          item.nutrients.faepa_dha || 0,
          item.nutrients.fa18_2n6c || 0,
          item.nutrients.fa18_3n3 || 0,
          item.nutrients.amino_his || 0,
          item.nutrients.amino_ile || 0,
          item.nutrients.amino_leu || 0,
          item.nutrients.amino_lys || 0,
          item.nutrients.amino_met || 0,
          item.nutrients.amino_phe || 0,
          item.nutrients.amino_thr || 0,
          item.nutrients.amino_trp || 0,
          item.nutrients.amino_val || 0,
          item.nutrients.ala || 0,
          item.nutrients.epa_dha || 0,
          item.nutrients.la || 0,
          false, // accepted = false (chưa chấp nhận)
          JSON.stringify(item), // Raw AI response
        ]
      );

      savedItems.push({
        id: result.rows[0].id,
        ...item,
        image_path: req.file.path.replace(/\\/g, '/'),
      });
    }

    return res.status(200).json({
      success: true,
      items: savedItems,
    });

  } catch (err) {
    console.error('[aiAnalysisController] analyzeImage error:', err);
    
    // Xóa file upload nếu có lỗi
    if (req.file && fs.existsSync(req.file.path)) {
      fs.unlinkSync(req.file.path);
    }
    
    return res.status(500).json({
      error: 'Không thể phân tích hình ảnh. Vui lòng thử lại.',
      details: err.message,
    });
  }
}

/**
 * POST /api/ai-analyzed-meals/:id/accept
 * Chấp nhận kết quả phân tích AI và cập nhật vào hệ thống
 */
async function acceptAnalysis(req, res) {
  const user = req.user;
  if (!user) return res.status(401).json({ error: 'Unauthorized' });

  const { id } = req.params;

  try {
    // 1. Lấy thông tin meal
    const meal = await db.query(
      `SELECT * FROM AI_Analyzed_Meals WHERE id = $1 AND user_id = $2`,
      [id, user.user_id]
    );

    if (meal.rows.length === 0) {
      return res.status(404).json({ error: 'Không tìm thấy meal' });
    }

    const mealData = meal.rows[0];

    // 2. Đánh dấu accepted = true
    await db.query(
      `UPDATE AI_Analyzed_Meals SET accepted = true, accepted_at = NOW() WHERE id = $1`,
      [id]
    );

    // 3. Trigger sẽ tự động cập nhật Water_Intake (đã có trong migration)
    // 4. Cập nhật DailySummary (calories, protein, carbs, fat)
    const today = new Date().toISOString().split('T')[0];
    
    await db.query(
      `INSERT INTO DailySummary (user_id, date, total_calories, total_protein, total_carbs, total_fat)
       VALUES ($1, $2, $3, $4, $5, $6)
       ON CONFLICT (user_id, date)
       DO UPDATE SET
         total_calories = DailySummary.total_calories + EXCLUDED.total_calories,
         total_protein = DailySummary.total_protein + EXCLUDED.total_protein,
         total_carbs = DailySummary.total_carbs + EXCLUDED.total_carbs,
         total_fat = DailySummary.total_fat + EXCLUDED.total_fat`,
      [
        user.user_id,
        today,
        mealData.enerc_kcal || 0,
        mealData.procnt || 0,
        mealData.chocdf || 0,
        mealData.fat || 0,
      ]
    );

    // 5. Cập nhật Nutrient Tracking (Mediterranean Diet, Vitamins, Minerals...)
    await updateNutrientTracking(user.user_id, mealData, today);

    return res.status(200).json({
      success: true,
      message: 'Đã chấp nhận và cập nhật vào hệ thống',
    });

  } catch (err) {
    console.error('[aiAnalysisController] acceptAnalysis error:', err);
    return res.status(500).json({
      error: 'Không thể chấp nhận meal',
      details: err.message,
    });
  }
}

/**
 * DELETE /api/ai-analyzed-meals/:id
 * Từ chối kết quả phân tích AI (xóa)
 */
async function rejectAnalysis(req, res) {
  const user = req.user;
  if (!user) return res.status(401).json({ error: 'Unauthorized' });

  const { id } = req.params;

  try {
    // Xóa record
    const result = await db.query(
      `DELETE FROM AI_Analyzed_Meals WHERE id = $1 AND user_id = $2 RETURNING image_path`,
      [id, user.user_id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Không tìm thấy meal' });
    }

    // Có thể xóa ảnh nếu muốn (optional)
    // const imagePath = result.rows[0].image_path;
    // if (fs.existsSync(imagePath)) {
    //   fs.unlinkSync(imagePath);
    // }

    return res.status(200).json({
      success: true,
      message: 'Đã từ chối và xóa meal',
    });

  } catch (err) {
    console.error('[aiAnalysisController] rejectAnalysis error:', err);
    return res.status(500).json({
      error: 'Không thể xóa meal',
      details: err.message,
    });
  }
}

/**
 * GET /api/ai-analyzed-meals
 * Lấy danh sách các meals đã phân tích bởi AI
 */
async function getAnalyzedMeals(req, res) {
  const user = req.user;
  if (!user) return res.status(401).json({ error: 'Unauthorized' });

  const { accepted, limit = 50, offset = 0 } = req.query;

  try {
    let query = `
      SELECT * FROM AI_Analyzed_Meals
      WHERE user_id = $1
    `;
    const params = [user.user_id];

    if (accepted !== undefined) {
      query += ` AND accepted = $2`;
      params.push(accepted === 'true');
    }

    query += ` ORDER BY analyzed_at DESC LIMIT $${params.length + 1} OFFSET $${params.length + 2}`;
    params.push(parseInt(limit), parseInt(offset));

    const result = await db.query(query, params);

    return res.status(200).json({
      success: true,
      meals: result.rows,
      total: result.rows.length,
    });

  } catch (err) {
    console.error('[aiAnalysisController] getAnalyzedMeals error:', err);
    return res.status(500).json({
      error: 'Không thể lấy danh sách meals',
      details: err.message,
    });
  }
}

// ============================================================
// HELPER FUNCTIONS
// ============================================================

/**
 * Cập nhật Nutrient Tracking (Mediterranean Diet, Vitamins, Minerals...)
 */
async function updateNutrientTracking(userId, mealData, date) {
  // 1. Mediterranean Diet (calories, protein, carbs, fat, water)
  await db.query(
    `INSERT INTO nutrient_tracking (user_id, nutrient_id, date, amount)
     VALUES 
       ($1, 1, $2, $3),  -- Calories
       ($1, 2, $2, $4),  -- Protein
       ($1, 4, $2, $5),  -- Carbs
       ($1, 3, $2, $6)   -- Fat
     ON CONFLICT (user_id, nutrient_id, date)
     DO UPDATE SET
       amount = nutrient_tracking.amount + EXCLUDED.amount`,
    [userId, date, mealData.enerc_kcal, mealData.procnt, mealData.chocdf, mealData.fat]
  );

  // 2. Water (nếu có nutrient_id cho water)
  // Hoặc đã được trigger tự động cập nhật vào Water_Intake

  // 3. Vitamins & Minerals (tùy thuộc vào bảng nutrient_tracking)
  // TODO: Thêm logic cập nhật vitamins, minerals nếu cần
}

module.exports = {
  analyzeImage,
  acceptAnalysis,
  rejectAnalysis,
  getAnalyzedMeals,
};
